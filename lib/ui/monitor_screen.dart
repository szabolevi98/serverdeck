import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/app_data.dart';
import '../data/models.dart';
import '../monitor/monitor_log.dart';
import '../monitor/monitor_providers.dart';
import '../monitor/notify.dart';
import 'server_edit_screen.dart';
import 'theme.dart';
import 'widgets.dart';

/// What the background monitor has found: every monitored server's state
/// and uptime, and the outages.
class MonitorScreen extends ConsumerStatefulWidget {
  const MonitorScreen({super.key});

  @override
  ConsumerState<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends ConsumerState<MonitorScreen> {
  late final AppLifecycleListener _lifecycle;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // The background may have written while the app was away.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(monitorLogProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _checkNow() async {
    setState(() => _checking = true);
    try {
      await ref.read(monitorRunnerProvider)(force: true);
      if (mounted) showMessage(context, context.l.monitorChecked);
    } catch (e) {
      if (mounted) showMessage(context, e.toString(), error: true);
    } finally {
      ref.invalidate(monitorLogProvider);
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _clear() async {
    final ok = await confirm(
      context,
      title: context.l.monitorClearTitle,
      message: context.l.monitorClearMessage,
      action: context.l.delete,
      destructive: true,
    );
    if (!ok) return;
    await ref.read(monitorLogFileProvider).save(const MonitorLog());
    ref.invalidate(monitorLogProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final servers = (ref.watch(appDataProvider).value?.servers ?? const [])
        .where((s) => s.monitor.enabled)
        .toList();
    final log = ref.watch(monitorLogProvider).value ?? const MonitorLog();
    final now = DateTime.now();
    final down = servers.where((s) => log.last(s.id)?.up == false).length;
    final lastCheck = servers
        .map((s) => log.last(s.id)?.at)
        .whereType<DateTime>()
        .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);
    final ids = servers.map((s) => s.id).toSet();
    final incidents = log.incidents
        .where((i) => ids.contains(i.serverId))
        .toList()
        .reversed
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.monitorTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (_) => _clear(),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'clear', child: Text(l.monitorClear)),
            ],
          ),
        ],
      ),
      body: servers.isEmpty
          ? EmptyState(
              icon: Icons.monitor_heart_rounded,
              title: l.monitorEmptyTitle,
              message: l.monitorEmpty,
            )
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(monitorLogProvider),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  _Summary(
                    down: down,
                    total: servers.length,
                    lastCheck: lastCheck,
                    now: now,
                    checking: _checking,
                    onCheck: _checkNow,
                  ),
                  SectionLabel(l.monitorServers),
                  for (final s in servers) ...[
                    _ServerMonitorCard(server: s, log: log, now: now),
                    const SizedBox(height: 12),
                  ],
                  SectionLabel(l.monitorIncidents),
                  if (incidents.isEmpty)
                    Text(
                      l.monitorNoIncidents,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    )
                  else
                    Card(
                      child: Column(
                        children: [
                          for (final (i, inc)
                              in incidents.take(50).indexed) ...[
                            if (i > 0) const Divider(indent: 44),
                            _IncidentRow(
                              incident: inc,
                              server: servers.firstWhere(
                                (s) => s.id == inc.serverId,
                              ),
                              now: now,
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    l.monitorTimingHint,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// "5 perce", "3 órája", or the date: when a check happened.
String ago(BuildContext context, DateTime at, DateTime now) {
  final d = now.difference(at);
  final l = context.l;
  if (d.inMinutes < 1) return l.agoNow;
  if (d.inHours < 1) return l.agoMinutes(d.inMinutes);
  if (d.inDays < 1) return l.agoHours(d.inHours);
  return DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag())
      .add_Hm()
      .format(at);
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.down,
    required this.total,
    required this.lastCheck,
    required this.now,
    required this.checking,
    required this.onCheck,
  });

  final int down;
  final int total;
  final DateTime? lastCheck;
  final DateTime now;
  final bool checking;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final color = lastCheck == null
        ? context.status.idle
        : down > 0
        ? context.status.bad
        : context.status.ok;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                TintedIcon(
                  down > 0 ? Icons.error_rounded : Icons.check_circle_rounded,
                  color: color,
                  size: 48,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lastCheck == null
                            ? l.monitorWaiting
                            : down > 0
                            ? l.monitorSomeDown(down)
                            : l.monitorAllUp,
                        style: context.text.titleMedium?.copyWith(
                          color: down > 0 ? color : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lastCheck == null
                            ? l.monitorCount(total)
                            : '${l.monitorCount(total)} · ${l.monitorLast(ago(context, lastCheck!, now))}',
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton.tonalIcon(
              onPressed: checking ? null : onCheck,
              icon: checking
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
              label: Text(checking ? l.monitorChecking : l.monitorCheckNow),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerMonitorCard extends StatelessWidget {
  const _ServerMonitorCard({
    required this.server,
    required this.log,
    required this.now,
  });

  final ServerProfile server;
  final MonitorLog log;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final status = context.status;
    final last = log.last(server.id);
    final open = log.openIncident(server.id);
    final (Color color, String label) = switch (last) {
      null => (status.idle, l.monitorStateUnknown),
      CheckRecord(up: true) => (status.ok, l.sessionOnline),
      _ => (
        status.bad,
        open == null
            ? l.statusDown
            : l.monitorDownFor(_short(context, open.lengthUntil(now))),
      ),
    };
    final checks = log.checks[server.id] ?? const <CheckRecord>[];

    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ServerEditScreen(server: server)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      server.name,
                      style: context.text.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusPill(label: label, color: color),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                [
                  server.monitor.minutes < 60
                      ? l.everyNMinutes(server.monitor.minutes)
                      : l.everyNHours(server.monitor.minutes ~/ 60),
                  server.monitor.mode == MonitorMode.ssh
                      ? l.monitorModeSsh
                      : l.monitorModePort,
                  if (last != null) ago(context, last.at, now),
                  if (last?.latencyMs != null) '${last!.latencyMs} ms',
                ].join(' · '),
                style: mono(size: 11.5, color: context.colors.onSurfaceVariant),
              ),
              if (last != null && !last.up) ...[
                const SizedBox(height: 6),
                Text(
                  describeProblem(l, last.problem),
                  style: context.text.bodySmall?.copyWith(color: status.bad),
                ),
              ],
              const SizedBox(height: 14),
              _CheckStrip(checks: checks),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final (name, window) in [
                    (l.window24h, const Duration(days: 1)),
                    (l.window7d, const Duration(days: 7)),
                    (l.window30d, const Duration(days: 30)),
                  ])
                    Expanded(
                      child: _Uptime(
                        label: name,
                        value: log.uptime(server.id, window, now),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _short(BuildContext context, Duration d) {
  final l = context.l;
  if (d.inHours < 1) return l.shortMinutes(d.inMinutes);
  if (d.inDays < 1) return l.shortHours(d.inHours);
  return l.shortDays(d.inDays);
}

/// The last checks as a row of little bars, oldest on the left.
class _CheckStrip extends StatelessWidget {
  const _CheckStrip({required this.checks});
  final List<CheckRecord> checks;

  static const slots = 40;

  @override
  Widget build(BuildContext context) {
    final shown = checks.length > slots
        ? checks.sublist(checks.length - slots)
        : checks;
    final empty = slots - shown.length;
    return SizedBox(
      height: 22,
      child: Row(
        children: [
          for (var i = 0; i < slots; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.2),
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: i < empty
                        ? context.colors.surfaceContainerHigh
                        : shown[i - empty].up
                        ? context.status.ok
                        : context.status.bad,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Uptime extends StatelessWidget {
  const _Uptime({required this.label, required this.value});
  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) {
    final v = value;
    final text = v == null
        ? '–'
        : v == 1
        ? '100%'
        : '${(v * 100).toStringAsFixed(v >= 0.999 ? 2 : 1)}%';
    final color = v == null
        ? context.colors.onSurfaceVariant
        : v >= 0.99
        ? context.status.ok
        : v >= 0.95
        ? context.status.warn
        : context.status.bad;
    return Column(
      children: [
        Text(
          text,
          style: mono(size: 15, weight: FontWeight.w700, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _IncidentRow extends StatelessWidget {
  const _IncidentRow({
    required this.incident,
    required this.server,
    required this.now,
  });

  final Incident incident;
  final ServerProfile server;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final open = incident.open;
    final color = open ? context.status.bad : context.status.idle;
    final when = DateFormat.MMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm().format(incident.start);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        server.name,
                        style: mono(size: 13.5, weight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      open
                          ? l.monitorOngoing
                          : describeDuration(l, incident.lengthUntil(now)),
                      style: mono(
                        size: 12,
                        weight: FontWeight.w600,
                        color: open ? context.status.bad : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$when · ${describeProblem(l, incident.problem)}',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
