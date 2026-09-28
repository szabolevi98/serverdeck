import 'dart:io';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../l10n/generated/app_localizations.dart';
import 'checker.dart';

final _plugin = FlutterLocalNotificationsPlugin();
var _ready = false;

const _channel = AndroidNotificationDetails(
  'monitor',
  'Server monitoring',
  channelDescription: 'A server went down or came back up',
  importance: Importance.high,
  priority: Priority.high,
  icon: 'ic_notification',
  color: Color(0xFF3DDC97),
);

Future<void> initNotifications() async {
  if (_ready) return;
  await _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
  );
  _ready = true;
}

/// Asks for leave to notify, where the system wants it asked (Android 13+,
/// iOS). True when notifications may be shown.
Future<bool> requestNotificationPermission() async {
  await initNotifications();
  if (Platform.isAndroid) {
    return await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;
  }
  if (Platform.isIOS) {
    return await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, sound: true) ??
        false;
  }
  return false;
}

/// The phone's language, or English: the background has no widget tree to
/// ask.
AppLocalizations _strings() {
  final code = Platform.localeName.split(RegExp('[_-]')).first;
  final supported = AppLocalizations.supportedLocales.map(
    (l) => l.languageCode,
  );
  return lookupAppLocalizations(Locale(supported.contains(code) ? code : 'en'));
}

String describeProblem(AppLocalizations l, String? problem) =>
    switch (problem) {
      'unreachable' => l.monitorProblemUnreachable,
      'timeout' => l.monitorProblemTimeout,
      'authFailed' => l.monitorProblemAuth,
      'disconnected' => l.monitorProblemDisconnected,
      'hostKeyChanged' => l.monitorProblemHostKeyChanged,
      'hostKeyUnknown' => l.monitorProblemHostKeyUnknown,
      'missingCredentials' => l.monitorProblemMissing,
      _ => l.monitorProblemOther,
    };

String describeDuration(AppLocalizations l, Duration d) {
  if (d.inMinutes < 1) return l.durationSeconds(d.inSeconds);
  if (d.inHours < 1) return l.durationMinutes(d.inMinutes);
  if (d.inDays < 1) return l.durationHours(d.inHours, d.inMinutes % 60);
  return l.durationDays(d.inDays, d.inHours % 24);
}

/// One notification per server, so "back up" replaces "down".
int _idFor(String serverId) => serverId.hashCode & 0x7fffffff;

Future<void> notifyEvents(List<MonitorEvent> events) async {
  if (events.isEmpty) return;
  await initNotifications();
  final l = _strings();
  for (final e in events) {
    final name = e.server.name;
    final (title, body) = switch (e.kind) {
      MonitorEventKind.down => (
        l.monitorDownTitle(name),
        describeProblem(l, e.problem),
      ),
      MonitorEventKind.recovered => (
        l.monitorUpTitle(name),
        e.downFor == null
            ? l.monitorUpBody
            : l.monitorUpBodyFor(describeDuration(l, e.downFor!)),
      ),
      MonitorEventKind.hostKeyChanged => (
        l.monitorHostKeyTitle(name),
        l.monitorHostKeyBody,
      ),
    };
    await _plugin.show(
      id: _idFor(e.server.id),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: _channel,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
