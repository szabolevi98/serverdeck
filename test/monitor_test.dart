import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverdeck/data/models.dart';
import 'package:serverdeck/demo/demo.dart';
import 'package:serverdeck/monitor/checker.dart';
import 'package:serverdeck/monitor/monitor_log.dart';
import 'package:serverdeck/ssh/connection.dart';
import 'package:serverdeck/ssh/reach.dart';

const web = ServerProfile(
  id: 'web',
  name: 'web',
  host: '203.0.113.10',
  username: 'deploy',
  monitor: MonitorConfig(enabled: true, minutes: 30),
);
const off = ServerProfile(id: 'off', name: 'off', host: 'x', username: 'u');

final t0 = DateTime(2026, 9, 28, 12);
final known = KnownHost(
  host: web.hostKeyId,
  type: 'ssh-ed25519',
  fingerprint: 'SHA256:x',
  added: t0,
);

void main() {
  group('MonitorLog', () {
    test('an outage opens on the first failure and closes on recovery', () {
      var log = const MonitorLog();
      log = log.record('web', CheckRecord(at: t0, up: true));
      log = log.record(
        'web',
        CheckRecord(
          at: t0.add(const Duration(minutes: 30)),
          up: false,
          problem: 'timeout',
        ),
      );
      log = log.record(
        'web',
        CheckRecord(at: t0.add(const Duration(minutes: 60)), up: false),
      );
      expect(log.incidents, hasLength(1));
      expect(log.openIncident('web')!.problem, 'timeout');
      log = log.record(
        'web',
        CheckRecord(at: t0.add(const Duration(minutes: 90)), up: true),
      );
      expect(log.openIncident('web'), isNull);
      expect(log.incidents.single.lengthUntil(t0), const Duration(minutes: 60));
    });

    test('uptime counts the checks in the window', () {
      var log = const MonitorLog();
      for (var i = 0; i < 10; i++) {
        log = log.record(
          'web',
          CheckRecord(
            at: t0.add(Duration(hours: i)),
            up: i != 3,
          ),
        );
      }
      final now = t0.add(const Duration(hours: 9, minutes: 1));
      expect(log.uptime('web', const Duration(days: 1), now), 0.9);
      expect(log.uptime('web', const Duration(hours: 5), now), 1.0);
      expect(log.uptime('nope', const Duration(days: 1), now), isNull);
    });

    test('checks older than 30 days are dropped, and it survives JSON', () {
      var log = const MonitorLog().record(
        'web',
        CheckRecord(at: t0, up: false, problem: 'timeout'),
      );
      log = log.record(
        'web',
        CheckRecord(
          at: t0.add(const Duration(days: 31)),
          up: true,
          latencyMs: 120,
        ),
      );
      expect(log.checks['web'], hasLength(1));
      final back = MonitorLog.fromJson(log.toJson());
      expect(back.last('web')!.latencyMs, 120);
      expect(back.incidents.single.end, isNotNull);
      expect(back.without('web').incidents, isEmpty);
    });

    test('the file is written and read back', () async {
      final dir = await Directory.systemTemp.createTemp('sd-mon');
      try {
        final file = MonitorLogFile(dir);
        expect((await file.load()).incidents, isEmpty);
        await file.save(
          const MonitorLog().record('web', CheckRecord(at: t0, up: false)),
        );
        expect((await MonitorLogFile(dir).load()).incidents, hasLength(1));
      } finally {
        await dir.delete(recursive: true);
      }
    });
  });

  group('runChecks', () {
    test('only enabled servers that are due get checked', () {
      var log = const MonitorLog();
      expect(isDue(web, log, t0), isTrue);
      expect(isDue(off, log, t0), isFalse);
      log = log.record('web', CheckRecord(at: t0, up: true));
      expect(isDue(web, log, t0.add(const Duration(minutes: 20))), isFalse);
      // A little early is fine: background work does not run to the second.
      expect(isDue(web, log, t0.add(const Duration(minutes: 29))), isTrue);
    });

    test('a blip is retried and is not an outage', () async {
      var calls = 0;
      final (log, events) = await runChecks(
        servers: const [web, off],
        log: const MonitorLog(),
        now: () => t0,
        retryAfter: Duration.zero,
        check: (_) async => ++calls == 1
            ? const CheckOutcome.down('timeout')
            : const CheckOutcome.up(Duration(milliseconds: 90)),
      );
      expect(calls, 2);
      expect(log.last('web')!.up, isTrue);
      expect(events, isEmpty);
      expect(log.last('off'), isNull);
    });

    test('down is told once, recovery with how long it lasted', () async {
      var now = t0;
      var up = true;
      Future<(MonitorLog, List<MonitorEvent>)> run(MonitorLog log) => runChecks(
        servers: const [web],
        log: log,
        now: () => now,
        retryAfter: Duration.zero,
        force: true,
        check: (_) async => up
            ? const CheckOutcome.up(Duration(milliseconds: 80))
            : const CheckOutcome.down('unreachable'),
      );

      var (log, events) = await run(const MonitorLog());
      expect(events, isEmpty);

      up = false;
      now = t0.add(const Duration(minutes: 30));
      (log, events) = await run(log);
      expect(events.single.kind, MonitorEventKind.down);
      expect(events.single.problem, 'unreachable');

      now = t0.add(const Duration(minutes: 60));
      (log, events) = await run(log);
      expect(events, isEmpty, reason: 'still down: no second alarm');

      up = true;
      now = t0.add(const Duration(minutes: 95));
      (log, events) = await run(log);
      expect(events.single.kind, MonitorEventKind.recovered);
      expect(events.single.downFor, const Duration(minutes: 65));
    });

    test('a changed host key is not retried and has its own alarm', () async {
      var calls = 0;
      final (_, events) = await runChecks(
        servers: const [web],
        log: const MonitorLog(),
        now: () => t0,
        check: (_) async {
          calls++;
          return const CheckOutcome.down('hostKeyChanged');
        },
      );
      expect(calls, 1);
      expect(events.single.kind, MonitorEventKind.hostKeyChanged);
    });
  });

  group('checkServer', () {
    Future<Reachability> noKnock(String h, int p) async =>
        throw StateError('no knock');

    Connector connecting(Object? error) =>
        ({
          required ServerProfile server,
          required KnownHost? known,
          required HostKeyPrompt prompt,
          required Future<void> Function(String, String) onTrust,
          String? privateKeyPem,
          String? password,
        }) async {
          if (error != null) throw error;
          return DemoConnection(server);
        };

    test('signing in and running true is up', () async {
      final o = await checkServer(
        web,
        known: known,
        connect: connecting(null),
        knock: noKnock,
      );
      expect(o.up, isTrue);
      expect(o.latency, isNotNull);
    });

    test('failures are named', () async {
      Future<String?> problem(Object error) async => (await checkServer(
        web,
        known: known,
        connect: connecting(error),
        knock: noKnock,
      )).problem;

      expect(await problem(SSHAuthFailError('no')), 'authFailed');
      expect(
        await problem(const SocketException('Connection refused')),
        'unreachable',
      );
      expect(
        await problem(HostKeyChanged(known, 'ssh-ed25519', 'SHA256:y')),
        'hostKeyChanged',
      );
    });

    test('a host never accepted in the app cannot be checked', () async {
      final o = await checkServer(
        web,
        known: null,
        connect: connecting(null),
        knock: noKnock,
      );
      expect(o.problem, 'hostKeyUnknown');
    });

    test('port mode only knocks', () async {
      final port = web.copyWith(
        monitor: web.monitor.copyWith(mode: MonitorMode.port),
      );
      final upO = await checkServer(
        port,
        known: null,
        connect: connecting(StateError('no ssh')),
        knock: (h, p) async =>
            const Reachability.up(Duration(milliseconds: 30), null),
      );
      expect(upO.up, isTrue);
      final downO = await checkServer(
        port,
        known: null,
        connect: connecting(StateError('no ssh')),
        knock: (h, p) async => const Reachability.down('timeout'),
      );
      expect(downO.problem, 'timeout');
    });
  });
}
