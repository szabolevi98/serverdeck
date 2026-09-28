import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../data/models.dart';
import '../data/storage.dart';
import '../ssh/connection.dart';
import '../ssh/reach.dart';
import 'checker.dart';
import 'monitor_log.dart';
import 'notify.dart';

/// One periodic task checks every monitored server that is due. Its name is
/// also the iOS BGTaskScheduler identifier (Info.plist, AppDelegate).
const monitorTask = 'net.levente.serverdeck.monitor';

bool get monitoringSupported => Platform.isAndroid || Platform.isIOS;

/// Where the background task starts, in an isolate of its own with no app
/// running: it reads the data file and the secure store itself.
@pragma('vm:entry-point')
void monitorDispatcher() {
  Workmanager().executeTask((task, input) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await runMonitorOnce();
    } catch (_) {
      // A crash here would only make the system back off; the next run tries
      // again.
    }
    return true;
  });
}

/// Checks the monitored servers that are due (or all of them with [force]),
/// saves the log and notifies what changed. Used by the background task and
/// by "check now".
Future<(MonitorLog, List<MonitorEvent>)> runMonitorOnce({
  bool force = false,
  DataFile? dataFile,
  SecretStore? secrets,
  MonitorLogFile? logFile,
}) async {
  final data = await (dataFile ?? JsonDataFile()).load();
  final store = secrets ?? const PlatformSecretStore();
  final file = logFile ?? MonitorLogFile();
  final log = await file.load();

  final (next, events) = await runChecks(
    servers: data.servers,
    log: log,
    force: force,
    online: internetReachable,
    check: (s) async {
      final keyId = s.keyId;
      return checkServer(
        s,
        known: data.knownHost(s.hostKeyId),
        connect: ServerConnection.open,
        knock: knock,
        privateKeyPem: s.auth == AuthMethod.key && keyId != null
            ? await store.read(Secrets.privateKey(keyId))
            : null,
        password: s.auth == AuthMethod.password
            ? await store.read(Secrets.password(s.id))
            : null,
      );
    },
  );
  await file.save(next);
  await notifyEvents(events);
  return (next, events);
}

Future<void> initMonitoring() async {
  if (!monitoringSupported) return;
  await Workmanager().initialize(monitorDispatcher);
  await initNotifications();
}

/// Runs the periodic task as often as the most frequent monitored server
/// needs, never under Android's 15 minutes, only with a network (so a phone
/// in a tunnel does not report every server down), or cancels it when no
/// server is monitored.
Future<void> scheduleMonitoring(List<ServerProfile> servers) async {
  if (!monitoringSupported) return;
  final minutes = [
    for (final s in servers)
      if (s.monitor.enabled) s.monitor.minutes,
  ];
  if (minutes.isEmpty) {
    await Workmanager().cancelByUniqueName(monitorTask);
    return;
  }
  await Workmanager().registerPeriodicTask(
    monitorTask,
    monitorTask,
    frequency: Duration(minutes: max(15, minutes.reduce(min))),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );
}
