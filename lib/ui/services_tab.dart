import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_data.dart';
import '../probes/logs.dart';
import '../probes/services.dart';
import '../ssh/connection.dart';
import '../ssh/session.dart';
import 'theme.dart';
import 'widgets.dart';

class ServicesSnapshot {
  const ServicesSnapshot(this.services, this.containers, this.dockerError);
  final List<Service> services;

  /// Null when the server has no Docker.
  final List<DockerContainer>? containers;

  /// Docker is there but would not list, e.g. the user is not in its group.
  final String? dockerError;
}

final servicesProvider = FutureProvider.autoDispose
    .family<ServicesSnapshot, String>((ref, serverId) async {
      final session = ref.watch(sessionProvider(serverId));
      if (session is! SessionReady) throw const Disconnected();
      final connection = session.connection;
      final results = await Future.wait([
        connection.run(servicesCommand),
        connection.run(dockerCommand),
      ]);
      final docker = results[1];
      final containers = parseContainers(docker.stdout);
      return ServicesSnapshot(
        parseServices(results[0].stdout),
        containers,
        containers != null && !docker.ok ? docker.stderr.trim() : null,
      );
    });

enum _Filter { running, failed, all }

enum _Kind { systemd, docker }

class ServicesTab extends ConsumerStatefulWidget {
  const ServicesTab({super.key, required this.serverId});
  final String serverId;

  @override
  ConsumerState<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends ConsumerState<ServicesTab> {
  _Filter _filter = _Filter.running;
  _Kind _kind = _Kind.systemd;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(servicesProvider(widget.serverId));
    final l = context.l;

    return snapshot.when(
      skipLoadingOnRefresh: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyState(
        icon: Icons.miscellaneous_services_rounded,
        title: l.servicesFailedTitle,
        message: e.toString(),
        action: OutlinedButton(
          onPressed: _refresh,
          child: Text(l.sessionReconnect),
        ),
      ),
      data: (data) {
        final hasDocker = data.containers != null;
        final kind = hasDocker ? _kind : _Kind.systemd;
        final q = _query.toLowerCase();

        final running = data.services
            .where((s) => s.state == ServiceState.running)
            .length;
        final failed = data.services
            .where((s) => s.state == ServiceState.failed)
            .length;
        final services = data.services.where((s) {
          final matches =
              q.isEmpty ||
              s.name.toLowerCase().contains(q) ||
              s.description.toLowerCase().contains(q);
          return matches &&
              switch (_filter) {
                _Filter.running => s.state == ServiceState.running,
                _Filter.failed => s.state == ServiceState.failed,
                _Filter.all => true,
              };
        }).toList();
        final containers = (data.containers ?? const <DockerContainer>[])
            .where(
              (c) =>
                  q.isEmpty ||
                  c.name.toLowerCase().contains(q) ||
                  c.image.toLowerCase().contains(q),
            )
            .toList();

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              if (hasDocker) ...[
                SegmentedButton<_Kind>(
                  segments: [
                    ButtonSegment(
                      value: _Kind.systemd,
                      icon: const Icon(Icons.settings_suggest_rounded),
                      label: const Text('systemd'),
                    ),
                    ButtonSegment(
                      value: _Kind.docker,
                      icon: const Icon(Icons.view_in_ar_rounded),
                      label: Text('Docker (${data.containers!.length})'),
                    ),
                  ],
                  selected: {kind},
                  onSelectionChanged: (s) => setState(() => _kind = s.first),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                decoration: InputDecoration(
                  hintText: l.servicesSearch,
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
              const SizedBox(height: 12),
              if (kind == _Kind.systemd) ...[
                Wrap(
                  spacing: 8,
                  children: [
                    _FilterChip(
                      label: l.servicesRunning(running),
                      selected: _filter == _Filter.running,
                      onTap: () => setState(() => _filter = _Filter.running),
                    ),
                    _FilterChip(
                      label: l.servicesFailed(failed),
                      selected: _filter == _Filter.failed,
                      color: failed > 0 ? context.status.bad : null,
                      onTap: () => setState(() => _filter = _Filter.failed),
                    ),
                    _FilterChip(
                      label: l.servicesAll(data.services.length),
                      selected: _filter == _Filter.all,
                      onTap: () => setState(() => _filter = _Filter.all),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (services.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      _filter == _Filter.failed && q.isEmpty
                          ? l.servicesNoneFailed
                          : l.servicesNone,
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (final (i, s) in services.indexed) ...[
                          if (i > 0) const Divider(indent: 44),
                          _ServiceRow(service: s, onTap: () => _openService(s)),
                        ],
                      ],
                    ),
                  ),
              ] else ...[
                if (data.dockerError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      data.dockerError!,
                      style: mono(size: 12, color: context.status.bad),
                    ),
                  ),
                if (containers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      l.containersNone,
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (final (i, c) in containers.indexed) ...[
                          if (i > 0) const Divider(indent: 44),
                          _ContainerRow(
                            container: c,
                            onTap: () => _openContainer(c),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(servicesProvider(widget.serverId));
    try {
      await ref.read(servicesProvider(widget.serverId).future);
    } catch (_) {}
  }

  Connection? get _connection {
    final s = ref.read(sessionProvider(widget.serverId));
    return s is SessionReady ? s.connection : null;
  }

  bool get _root =>
      ref.read(appDataProvider).value?.server(widget.serverId)?.username ==
      'root';

  void _openService(Service service) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _DetailSheet(
      title: service.name,
      subtitle: service.description,
      state: _serviceLook(context, service.state),
      chips: [
        '${service.active} / ${service.sub}',
        if (service.enabled != null) service.enabled!,
      ],
      detailCommand: serviceStatusCommand(service, root: _root),
      connection: _connection,
      actions: [
        _SheetAction(
          ServiceAction.restart.name,
          Icons.restart_alt_rounded,
          context.l.actionRestart,
          primary: true,
        ),
        _SheetAction(
          ServiceAction.reload.name,
          Icons.sync_rounded,
          context.l.actionReload,
        ),
        service.state == ServiceState.running ||
                service.state == ServiceState.exited
            ? _SheetAction(
                ServiceAction.stop.name,
                Icons.stop_circle_outlined,
                context.l.actionStop,
                destructive: true,
              )
            : _SheetAction(
                ServiceAction.start.name,
                Icons.play_arrow_rounded,
                context.l.actionStart,
              ),
      ],
      onAction: (name) => _run(
        serviceActionCommand(
          service,
          ServiceAction.values.byName(name),
          root: _root,
        ),
        subject: service.name,
        action: name,
      ),
    ),
  );

  void _openContainer(DockerContainer container) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _DetailSheet(
      title: container.name,
      subtitle: container.image,
      state: _containerLook(context, container),
      chips: [
        container.status,
        container.id,
        if (container.ports.isNotEmpty) container.ports,
      ],
      detailCommand: _root
          ? 'docker logs --tail 40 ${shellQuote(container.id)} 2>&1'
          : 'sudo -n docker logs --tail 40 ${shellQuote(container.id)} 2>&1',
      connection: _connection,
      actions: [
        _SheetAction(
          ContainerAction.restart.name,
          Icons.restart_alt_rounded,
          context.l.actionRestart,
          primary: true,
        ),
        container.state == ContainerState.running
            ? _SheetAction(
                ContainerAction.stop.name,
                Icons.stop_circle_outlined,
                context.l.actionStop,
                destructive: true,
              )
            : _SheetAction(
                ContainerAction.start.name,
                Icons.play_arrow_rounded,
                context.l.actionStart,
              ),
      ],
      onAction: (name) => _run(
        containerActionCommand(
          container,
          ContainerAction.values.byName(name),
          root: _root,
        ),
        subject: container.name,
        action: name,
      ),
    ),
  );

  /// Asks, runs, reports, refreshes. Returns true when it ran and succeeded.
  Future<bool> _run(
    String command, {
    required String subject,
    required String action,
  }) async {
    final l = context.l;
    final verb = switch (action) {
      'restart' => l.actionRestart,
      'reload' => l.actionReload,
      'stop' => l.actionStop,
      _ => l.actionStart,
    };
    final ok = await confirm(
      context,
      title: l.actionConfirmTitle(verb, subject),
      message: l.actionConfirmMessage(command),
      action: verb,
      destructive: action == 'stop',
    );
    final connection = _connection;
    if (!ok || connection == null || !mounted) return false;

    try {
      final result = await connection.run(
        command,
        timeout: const Duration(seconds: 90),
      );
      if (!mounted) return result.ok;
      if (result.ok) {
        showMessage(context, l.actionDone(verb, subject));
      } else {
        final why = result.stderr.trim();
        showMessage(
          context,
          why.contains('a password is required') || why.contains('sudo:')
              ? l.actionNeedsSudo
              : l.actionFailed(result.exitCode ?? -1, why),
          error: true,
        );
      }
      await _refresh();
      return result.ok;
    } catch (e) {
      if (mounted) showMessage(context, e.toString(), error: true);
      return false;
    }
  }
}

(Color, String) _serviceLook(BuildContext context, ServiceState state) {
  final s = context.status;
  final l = context.l;
  return switch (state) {
    ServiceState.running => (s.ok, l.stateRunning),
    ServiceState.exited => (context.colors.secondary, l.stateExited),
    ServiceState.failed => (s.bad, l.stateFailed),
    ServiceState.activating => (s.warn, l.stateActivating),
    ServiceState.inactive => (s.idle, l.stateInactive),
    ServiceState.other => (s.idle, '?'),
  };
}

(Color, String) _containerLook(BuildContext context, DockerContainer c) {
  final s = context.status;
  final l = context.l;
  if (c.unhealthy) return (s.bad, l.stateUnhealthy);
  return switch (c.state) {
    ContainerState.running => (s.ok, l.stateRunning),
    ContainerState.paused => (s.warn, l.statePaused),
    ContainerState.restarting => (s.warn, l.stateRestarting),
    ContainerState.exited => (s.idle, l.stateExitedContainer),
    ContainerState.created => (s.idle, l.stateCreated),
    ContainerState.other => (s.idle, c.stateText),
  };
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
    showCheckmark: false,
    labelStyle: TextStyle(
      color: color ?? (selected ? context.colors.onSurface : null),
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
    ),
  );
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service, required this.onTap});
  final Service service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (color, label) = _serviceLook(context, service.state);
    return _Row(
      color: color,
      title: service.name,
      subtitle: service.description,
      trailing: label,
      onTap: onTap,
    );
  }
}

class _ContainerRow extends StatelessWidget {
  const _ContainerRow({required this.container, required this.onTap});
  final DockerContainer container;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (color, label) = _containerLook(context, container);
    return _Row(
      color: color,
      title: container.name,
      subtitle: '${container.image} · ${container.status}',
      trailing: label,
      onTap: onTap,
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final Color color;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: mono(size: 13.5, weight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            trailing,
            style: mono(size: 11.5, weight: FontWeight.w600, color: color),
          ),
        ],
      ),
    ),
  );
}

class _SheetAction {
  const _SheetAction(
    this.name,
    this.icon,
    this.label, {
    this.primary = false,
    this.destructive = false,
  });
  final String name;
  final IconData icon;
  final String label;
  final bool primary;
  final bool destructive;
}

/// A service or container up close: its state, its latest output, and what
/// can be done to it.
class _DetailSheet extends StatefulWidget {
  const _DetailSheet({
    required this.title,
    required this.subtitle,
    required this.state,
    required this.chips,
    required this.detailCommand,
    required this.connection,
    required this.actions,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final (Color, String) state;
  final List<String> chips;
  final String detailCommand;
  final Connection? connection;
  final List<_SheetAction> actions;
  final Future<bool> Function(String action) onAction;

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  String? _detail;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final connection = widget.connection;
    if (connection == null) return;
    try {
      final r = await connection.run(widget.detailCommand);
      // systemctl status exits 3 for a stopped unit; its output is still it.
      final text = [r.stdout, r.stderr].where((s) => s.trim().isNotEmpty);
      if (mounted) setState(() => _detail = text.join('\n').trimRight());
    } catch (e) {
      if (mounted) setState(() => _detail = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, label) = widget.state;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.94,
      minChildSize: 0.4,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: mono(size: 18, weight: FontWeight.w700),
                ),
              ),
              StatusPill(label: label, color: color),
            ],
          ),
          if (widget.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.subtitle,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final c in widget.chips)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(c, style: mono(size: 11.5)),
                ),
            ],
          ),
          const SizedBox(height: 18),
          for (final a in widget.actions.where((a) => a.primary))
            FilledButton.icon(
              onPressed: _busy ? null : () => _act(a.name),
              icon: Icon(a.icon, size: 20),
              label: Text(a.label),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final (i, a)
                  in widget.actions.where((a) => !a.primary).indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: a.destructive
                        ? OutlinedButton.styleFrom(
                            foregroundColor: context.status.bad,
                          )
                        : null,
                    onPressed: _busy ? null : () => _act(a.name),
                    icon: Icon(a.icon, size: 20),
                    label: Text(a.label),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.outline),
            ),
            child: _detail == null
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText.rich(
                      TextSpan(
                        children: [
                          for (final (i, line)
                              in (_detail!.isEmpty ? '—' : _detail!)
                                  .split('\n')
                                  .indexed)
                            TextSpan(
                              text: i == 0 ? line : '\n$line',
                              style: TextStyle(
                                color: switch (levelOf(line)) {
                                  LineLevel.error => context.status.bad,
                                  LineLevel.warning => context.status.warn,
                                  LineLevel.normal => null,
                                },
                              ),
                            ),
                        ],
                      ),
                      style: mono(size: 11, height: 1.45),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _act(String action) async {
    setState(() => _busy = true);
    final ok = await widget.onAction(action);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) _detail = null;
    });
    if (ok) _load();
  }
}
