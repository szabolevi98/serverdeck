import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// One background check of one server.
class CheckRecord {
  const CheckRecord({
    required this.at,
    required this.up,
    this.latencyMs,
    this.problem,
  });

  final DateTime at;
  final bool up;
  final int? latencyMs;

  /// A [ConnectionProblem] name, or `hostKeyChanged`, when down.
  final String? problem;

  Map<String, Object?> toJson() => {
    'at': at.toIso8601String(),
    'up': up,
    if (latencyMs != null) 'ms': latencyMs,
    if (problem != null) 'problem': problem,
  };

  factory CheckRecord.fromJson(Map<String, Object?> j) => CheckRecord(
    at: DateTime.parse(j['at'] as String),
    up: j['up'] as bool,
    latencyMs: j['ms'] as int?,
    problem: j['problem'] as String?,
  );
}

/// A stretch of time a server was found down, open while it still is.
class Incident {
  const Incident({
    required this.serverId,
    required this.start,
    this.end,
    required this.problem,
  });

  final String serverId;

  /// The first check that failed.
  final DateTime start;

  /// The first check that succeeded again; null while it is still down.
  final DateTime? end;
  final String problem;

  bool get open => end == null;
  Duration lengthUntil(DateTime now) => (end ?? now).difference(start);

  Incident close(DateTime at) =>
      Incident(serverId: serverId, start: start, end: at, problem: problem);

  Map<String, Object?> toJson() => {
    'server': serverId,
    'start': start.toIso8601String(),
    if (end != null) 'end': end!.toIso8601String(),
    'problem': problem,
  };

  factory Incident.fromJson(Map<String, Object?> j) => Incident(
    serverId: j['server'] as String,
    start: DateTime.parse(j['start'] as String),
    end: j['end'] == null ? null : DateTime.parse(j['end'] as String),
    problem: j['problem'] as String? ?? 'other',
  );
}

/// Everything the background checks have found, newest last.
class MonitorLog {
  const MonitorLog({this.checks = const {}, this.incidents = const []});

  /// Per server, its checks from the last [keep].
  final Map<String, List<CheckRecord>> checks;
  final List<Incident> incidents;

  static const keep = Duration(days: 30);
  static const maxIncidents = 500;

  CheckRecord? last(String serverId) => checks[serverId]?.lastOrNull;

  Incident? openIncident(String serverId) =>
      incidents.where((i) => i.serverId == serverId && i.open).lastOrNull;

  List<Incident> incidentsOf(String serverId) =>
      incidents.where((i) => i.serverId == serverId).toList();

  /// Share of the time within [window] before [now] that the server was up,
  /// counting from its first check when that is later; null before any.
  /// Down time is the outages', from the first failed check to the first
  /// good one after it.
  double? uptime(String serverId, Duration window, DateTime now) {
    final first = checks[serverId]?.firstOrNull?.at;
    if (first == null) return null;
    final windowStart = now.subtract(window);
    final from = first.isAfter(windowStart) ? first : windowStart;
    final observed = now.difference(from);
    if (observed <= Duration.zero) return null;
    var down = Duration.zero;
    for (final i in incidentsOf(serverId)) {
      final start = i.start.isAfter(from) ? i.start : from;
      final end = i.end ?? now;
      if (end.isAfter(start)) down += end.difference(start);
    }
    return (1 - down.inMilliseconds / observed.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Adds [record] for [serverId], opening or closing an incident when the
  /// state flips, and dropping what is older than [keep].
  MonitorLog record(String serverId, CheckRecord record) {
    final cutoff = record.at.subtract(keep);
    final list = [
      ...(checks[serverId] ?? const <CheckRecord>[]).where(
        (c) => c.at.isAfter(cutoff),
      ),
      record,
    ];
    var incidents = [...this.incidents];
    final open = openIncident(serverId);
    if (!record.up && open == null) {
      incidents.add(
        Incident(
          serverId: serverId,
          start: record.at,
          problem: record.problem ?? 'other',
        ),
      );
    } else if (record.up && open != null) {
      incidents = [
        for (final i in incidents) identical(i, open) ? i.close(record.at) : i,
      ];
    }
    if (incidents.length > maxIncidents) {
      incidents = incidents.sublist(incidents.length - maxIncidents);
    }
    return MonitorLog(
      checks: {...checks, serverId: list},
      incidents: incidents,
    );
  }

  /// The log without [incident] and the failed checks inside it, for an
  /// outage that was not one (the phone was offline, say). Only a closed one:
  /// an ongoing outage is still being watched.
  MonitorLog withoutIncident(Incident incident) {
    final end = incident.end;
    if (end == null) return this;
    bool inside(CheckRecord c) =>
        !c.up && !c.at.isBefore(incident.start) && c.at.isBefore(end);
    return MonitorLog(
      checks: {
        ...checks,
        incident.serverId: (checks[incident.serverId] ?? const [])
            .where((c) => !inside(c))
            .toList(),
      },
      incidents: incidents
          .where(
            (i) =>
                !(i.serverId == incident.serverId && i.start == incident.start),
          )
          .toList(),
    );
  }

  /// The log without [serverId], after the server was deleted.
  MonitorLog without(String serverId) => MonitorLog(
    checks: {...checks}..remove(serverId),
    incidents: incidents.where((i) => i.serverId != serverId).toList(),
  );

  Map<String, Object?> toJson() => {
    'version': 1,
    'checks': {
      for (final e in checks.entries)
        e.key: [for (final c in e.value) c.toJson()],
    },
    'incidents': [for (final i in incidents) i.toJson()],
  };

  factory MonitorLog.fromJson(Map<String, Object?> j) => MonitorLog(
    checks: {
      for (final e
          in (j['checks'] as Map<String, Object?>? ?? const {}).entries)
        e.key: [
          for (final c in e.value! as List<Object?>)
            CheckRecord.fromJson(c! as Map<String, Object?>),
        ],
    },
    incidents: [
      for (final i in j['incidents'] as List<Object?>? ?? const [])
        Incident.fromJson(i! as Map<String, Object?>),
    ],
  );
}

/// For tests and the demo: a log that lives in memory.
class MemoryMonitorLogFile extends MonitorLogFile {
  MemoryMonitorLogFile([this.log = const MonitorLog()]);
  MonitorLog log;

  @override
  Future<MonitorLog> load() async => log;

  @override
  Future<void> save(MonitorLog log) async => this.log = log;
}

/// monitor.json next to the app's data file. The background task writes it;
/// the app reads it, and writes it only to clear it or drop a server.
class MonitorLogFile {
  MonitorLogFile([this._directory]);
  Directory? _directory;

  Future<File> _file() async {
    final dir = _directory ??= await getApplicationSupportDirectory();
    return File('${dir.path}${Platform.pathSeparator}monitor.json');
  }

  Future<MonitorLog> load() async {
    final file = await _file();
    if (!await file.exists()) return const MonitorLog();
    try {
      return MonitorLog.fromJson(
        jsonDecode(await file.readAsString()) as Map<String, Object?>,
      );
    } on FormatException {
      return const MonitorLog();
    }
  }

  Future<void> save(MonitorLog log) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(jsonEncode(log.toJson()), flush: true);
    await temp.rename(file.path);
  }
}
