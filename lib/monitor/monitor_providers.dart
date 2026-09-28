import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../ssh/reach.dart';
import 'background.dart';
import 'checker.dart';
import 'monitor_log.dart';

typedef MonitorScheduler = Future<void> Function(List<ServerProfile> servers);
typedef MonitorRunner = Future<(MonitorLog, List<MonitorEvent>)> Function({
  bool force,
});

/// Registers or cancels the background task; a no-op in the demo and tests.
final monitorSchedulerProvider = Provider<MonitorScheduler>(
  (ref) => scheduleMonitoring,
);

/// Checks the monitored servers now, in the foreground.
final monitorRunnerProvider = Provider<MonitorRunner>(
  (ref) =>
      ({bool force = false}) => runMonitorOnce(force: force),
);

final monitorLogFileProvider = Provider<MonitorLogFile>(
  (ref) => MonitorLogFile(),
);

/// What the background has found so far. Read again on refresh and when the
/// app comes back to the front.
final monitorLogProvider = FutureProvider.autoDispose<MonitorLog>(
  (ref) => ref.read(monitorLogFileProvider).load(),
);

/// Whether the phone is on the internet at all; the demo says always.
final internetProbeProvider = Provider<Future<bool> Function()>(
  (ref) => internetReachable,
);
