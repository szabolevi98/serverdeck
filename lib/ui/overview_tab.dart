import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../probes/stats.dart';
import '../probes/stats_provider.dart';
import 'charts.dart';
import 'theme.dart';
import 'widgets.dart';

/// The server at a glance: the three rings, the last three minutes, the
/// network, the load and every disk.
class OverviewTab extends ConsumerStatefulWidget {
  const OverviewTab({super.key, required this.serverId, required this.active});
  final String serverId;
  final bool active;

  @override
  ConsumerState<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends ConsumerState<OverviewTab> {
  late final AppLifecycleListener _lifecycle;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        _foreground = state == AppLifecycleState.resumed;
        _sync();
      },
    );
  }

  @override
  void didUpdateWidget(OverviewTab old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) _sync();
  }

  void _sync() => ref
      .read(statsProvider(widget.serverId).notifier)
      .setActive(widget.active && _foreground);

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider(widget.serverId));
    final s = stats.latest;
    if (s == null) {
      return stats.error != null
          ? EmptyState(
              icon: Icons.query_stats_rounded,
              title: context.l.statsFailedTitle,
              message: context.l.statsFailed,
            )
          : const Center(child: CircularProgressIndicator());
    }

    final status = context.status;
    final cpu = stats.cpu.last;
    final root = s.rootDisk;

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(statsProvider(widget.serverId).notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _HostCard(sample: s),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: RingGauge(
                      value: stats.samples.length > 1 ? cpu : null,
                      color: status.tone(cpu, status.cpu),
                      label: context.l.statCpu,
                      detail: context.l.statCores(s.cores),
                    ),
                  ),
                  Expanded(
                    child: RingGauge(
                      value: s.memUsage,
                      color: status.tone(
                        s.memUsage,
                        status.memory,
                        warnAt: 0.85,
                      ),
                      label: context.l.statMemory,
                      detail: formatKbPair(s.memUsedKb, s.memTotalKb),
                    ),
                  ),
                  Expanded(
                    child: RingGauge(
                      value: root?.usage,
                      color: status.tone(root?.usage ?? 0, status.disk),
                      label: context.l.statDisk,
                      detail: root == null
                          ? null
                          : formatKbPair(root.usedKb, root.totalKb),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SectionLabel(context.l.statHistory),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    children: [
                      _Legend(
                        color: status.cpu,
                        label: context.l.statCpu,
                        value: '${(cpu * 100).round()}%',
                      ),
                      _Legend(
                        color: status.memory,
                        label: context.l.statMemory,
                        value: '${(s.memUsage * 100).round()}%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  HistoryChart(
                    // The first CPU figure is the average since boot, not a
                    // reading of now; the chart starts from the second.
                    series: [
                      stats.cpu.skip(1).map((v) => v * 100).toList(),
                      stats.memory.map((v) => v * 100).toList(),
                    ],
                    colors: [status.cpu, status.memory],
                    maxY: 100,
                    capacity: StatsNotifier.history,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l.statHistoryHint,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _NetworkCard(stats: stats),
          const SizedBox(height: 12),
          _LoadCard(sample: s),
          SectionLabel(context.l.statDisks),
          Card(
            child: Column(
              children: [
                for (final (i, d) in s.disks.indexed) ...[
                  if (i > 0) const Divider(indent: 16, endIndent: 16),
                  _DiskRow(disk: d),
                ],
                if (s.swapTotalKb > 0) ...[
                  const Divider(indent: 16, endIndent: 16),
                  _UsageRow(
                    icon: Icons.swap_vert_rounded,
                    title: context.l.statSwap,
                    subtitle: null,
                    usage: s.swapUsage,
                    used: formatKb(s.swapUsedKb),
                    total: formatKb(s.swapTotalKb),
                    color: status.memory,
                  ),
                ],
              ],
            ),
          ),
          if (stats.error != null) ...[
            const SizedBox(height: 12),
            Text(
              context.l.statsStale,
              textAlign: TextAlign.center,
              style: context.text.bodySmall?.copyWith(
                color: context.status.warn,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HostCard extends StatelessWidget {
  const _HostCard({required this.sample});
  final StatsSample sample;

  @override
  Widget build(BuildContext context) {
    final days = sample.uptime.inDays;
    final hours = sample.uptime.inHours % 24;
    final minutes = sample.uptime.inMinutes % 60;
    final uptime = days > 0
        ? context.l.uptimeDays(days, hours)
        : context.l.uptimeHours(hours, minutes);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            TintedIcon(Icons.terminal_rounded, color: context.status.ok),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sample.hostname,
                    style: mono(size: 16, weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (sample.os.isNotEmpty) sample.os,
                      sample.kernel,
                    ].join(' · '),
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.l.statUptime.toUpperCase(),
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(uptime, style: mono(size: 13, weight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, this.value});
  final Color color;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: context.text.bodySmall),
      if (value != null) ...[
        const SizedBox(width: 6),
        Text(value!, style: mono(size: 12, weight: FontWeight.w700)),
      ],
    ],
  );
}

class _NetworkCard extends StatelessWidget {
  const _NetworkCard({required this.stats});
  final StatsState stats;

  @override
  Widget build(BuildContext context) {
    final rx = stats.rx.length > 1 ? stats.rx.last : null;
    final tx = stats.tx.length > 1 ? stats.tx.last : null;
    final colors = [context.colors.secondary, context.colors.tertiary];

    Widget rate(IconData icon, String label, double? value, Color color) =>
        Expanded(
          child: Row(
            children: [
              TintedIcon(icon, color: color, size: 36),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value == null ? '–' : '${formatBytes(value)}/s',
                    style: mono(size: 15, weight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          children: [
            Row(
              children: [
                rate(Icons.south_rounded, context.l.statNetIn, rx, colors[0]),
                rate(Icons.north_rounded, context.l.statNetOut, tx, colors[1]),
              ],
            ),
            const SizedBox(height: 12),
            HistoryChart(
              series: [stats.rx.skip(1).toList(), stats.tx.skip(1).toList()],
              colors: colors,
              capacity: StatsNotifier.history,
              height: 70,
              grid: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadCard extends StatelessWidget {
  const _LoadCard({required this.sample});
  final StatsSample sample;

  @override
  Widget build(BuildContext context) {
    final cores = sample.cores.clamp(1, 1024);
    Widget cell(String label, double load) {
      final color = context.status.forLoad(load / cores, warnAt: 0.7, badAt: 1);
      return Expanded(
        child: Column(
          children: [
            Text(
              load.toStringAsFixed(2),
              style: mono(size: 18, weight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l.statLoad, style: context.text.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                cell(context.l.statLoad1, sample.load1),
                cell(context.l.statLoad5, sample.load5),
                cell(context.l.statLoad15, sample.load15),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DiskRow extends StatelessWidget {
  const _DiskRow({required this.disk});
  final Disk disk;

  @override
  Widget build(BuildContext context) => _UsageRow(
    icon: Icons.storage_rounded,
    title: disk.mount,
    subtitle: disk.device,
    usage: disk.usage,
    used: formatKb(disk.usedKb),
    total: formatKb(disk.totalKb),
    color: context.status.tone(disk.usage, context.status.disk),
  );
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.usage,
    required this.used,
    required this.total,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final double usage;
  final String used;
  final String total;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: context.colors.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: mono(size: 13.5, weight: FontWeight.w600),
                    ),
                    if (subtitle != null)
                      TextSpan(
                        text: '  $subtitle',
                        style: mono(
                          size: 11,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${(usage * 100).round()}%',
              style: mono(size: 13, weight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 10),
        UsageBar(value: usage, color: color),
        const SizedBox(height: 6),
        Text(
          '$used / $total',
          style: mono(size: 11, color: context.colors.onSurfaceVariant),
        ),
      ],
    ),
  );
}
