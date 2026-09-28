import 'dart:async';

import '../data/models.dart';
import '../ssh/connection.dart';
import '../ssh/reach.dart';
import 'monitor_log.dart';

/// What one check found.
class CheckOutcome {
  const CheckOutcome.up(this.latency) : problem = null;
  const CheckOutcome.down(this.problem) : latency = null;

  final Duration? latency;

  /// A [ConnectionProblem] name, `hostKeyChanged` or `hostKeyUnknown`.
  final String? problem;

  bool get up => problem == null;
}

typedef Knock = Future<Reachability> Function(String host, int port);

/// Checks [server] the way its [MonitorConfig] says: by signing in and
/// running `true`, or by opening its port.
///
/// A background check cannot ask about a host key, so a server whose key was
/// never accepted in the app fails with `hostKeyUnknown`, and one whose key
/// changed with `hostKeyChanged`, which is worth an alarm of its own.
Future<CheckOutcome> checkServer(
  ServerProfile server, {
  required KnownHost? known,
  required Connector connect,
  required Knock knock,
  String? privateKeyPem,
  String? password,
}) async {
  final watch = Stopwatch()..start();
  if (server.monitor.mode == MonitorMode.port) {
    final r = await knock(server.host, server.port);
    return r.isUp
        ? CheckOutcome.up(r.latency!)
        : CheckOutcome.down(
            r.error == 'timeout'
                ? ConnectionProblem.timeout.name
                : ConnectionProblem.unreachable.name,
          );
  }
  if (known == null) return const CheckOutcome.down('hostKeyUnknown');
  try {
    final connection = await connect(
      server: server,
      known: known,
      prompt: (_, _, _) async => false,
      onTrust: (_, _) async {},
      privateKeyPem: privateKeyPem,
      password: password,
    );
    try {
      await connection.run('true', timeout: const Duration(seconds: 20));
    } finally {
      connection.close();
    }
    return CheckOutcome.up(watch.elapsed);
  } on HostKeyChanged {
    return const CheckOutcome.down('hostKeyChanged');
  } catch (e) {
    return CheckOutcome.down(classify(e).name);
  }
}

enum MonitorEventKind { down, recovered, hostKeyChanged }

/// Something worth a notification: a server went down, came back, or showed
/// a different host key.
class MonitorEvent {
  const MonitorEvent(this.kind, this.server, {this.problem, this.downFor});
  final MonitorEventKind kind;
  final ServerProfile server;
  final String? problem;

  /// How long it was down, for [MonitorEventKind.recovered].
  final Duration? downFor;
}

/// Whether [server] should be checked at [now]. A little early counts:
/// background work does not run to the second.
bool isDue(ServerProfile server, MonitorLog log, DateTime now) {
  if (!server.monitor.enabled) return false;
  final last = log.last(server.id);
  if (last == null) return true;
  final slack = const Duration(minutes: 2);
  return now.difference(last.at) >=
      Duration(minutes: server.monitor.minutes) - slack;
}

/// Failures the phone's own network can cause. A refused key or a changed
/// host key came from the server, so the phone was online.
const _networkProblems = {'unreachable', 'timeout', 'disconnected', 'other'};

/// Checks every monitored server that is due, once more after [retryAfter]
/// when a check fails (a blip is not an outage), records the results, and
/// says what changed.
///
/// A failure that could be the phone's rather than the server's is kept
/// only when [online] says the phone can reach the internet: a phone out of
/// Wi-Fi and data, or asleep with its network cut, finds every server
/// unreachable, and must not log that as an outage.
Future<(MonitorLog, List<MonitorEvent>)> runChecks({
  required List<ServerProfile> servers,
  required MonitorLog log,
  required Future<CheckOutcome> Function(ServerProfile) check,
  Future<bool> Function()? online,
  DateTime Function() now = DateTime.now,
  Duration retryAfter = const Duration(seconds: 30),
  bool force = false,
}) async {
  final due = [
    for (final s in servers)
      if (s.monitor.enabled && (force || isDue(s, log, now()))) s,
  ];
  // All at once: a slow server must not hold the others back.
  final checked = await Future.wait(
    due.map((s) async {
      var outcome = await check(s);
      if (!outcome.up && outcome.problem != 'hostKeyChanged') {
        await Future<void>.delayed(retryAfter);
        outcome = await check(s);
      }
      return (s, outcome, now());
    }),
  );

  // Asked once per run, and only when something failed the network's way.
  bool? phoneOnline;
  final outcomes = <(ServerProfile, CheckOutcome, DateTime)>[];
  for (final c in checked) {
    final (_, outcome, _) = c;
    if (!outcome.up &&
        _networkProblems.contains(outcome.problem) &&
        online != null) {
      phoneOnline ??= await online();
      if (!phoneOnline) continue;
    }
    outcomes.add(c);
  }

  var next = log;
  final events = <MonitorEvent>[];
  for (final (server, outcome, at) in outcomes) {
    final before = next.last(server.id);
    final open = next.openIncident(server.id);
    next = next.record(
      server.id,
      CheckRecord(
        at: at,
        up: outcome.up,
        latencyMs: outcome.latency?.inMilliseconds,
        problem: outcome.problem,
      ),
    );
    final wasUp = before == null || before.up;
    if (!outcome.up && wasUp) {
      events.add(
        MonitorEvent(
          outcome.problem == 'hostKeyChanged'
              ? MonitorEventKind.hostKeyChanged
              : MonitorEventKind.down,
          server,
          problem: outcome.problem,
        ),
      );
    } else if (outcome.up && !wasUp) {
      events.add(
        MonitorEvent(
          MonitorEventKind.recovered,
          server,
          downFor: open?.lengthUntil(at),
        ),
      );
    }
  }
  return (next, events);
}
