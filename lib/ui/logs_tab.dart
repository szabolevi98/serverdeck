import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_data.dart';
import '../data/models.dart';
import '../probes/logs.dart';
import '../ssh/connection.dart';
import '../ssh/session.dart';
import 'theme.dart';
import 'widgets.dart';

/// Follows one log at a time, live, while the tab is on screen.
class LogsTab extends ConsumerStatefulWidget {
  const LogsTab({super.key, required this.serverId, required this.active});
  final String serverId;
  final bool active;

  @override
  ConsumerState<LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends ConsumerState<LogsTab> {
  static const _maxLines = 3000;

  late String _sourceId = 'journal:${widget.serverId}';
  final _lines = <String>[];
  final _pending = <String>[];
  RunningCommand? _running;
  StreamSubscription<String>? _subscription;
  bool _paused = false;
  bool _errorsOnly = false;
  String _filter = '';
  String? _problem;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    }
  }

  @override
  void didUpdateWidget(LogsTab old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) widget.active ? _start() : _stop();
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  List<LogSource> get _sources {
    final data = ref.read(appDataProvider).value;
    return [
      journalSource(widget.serverId, context.l.logsJournal),
      ...?data?.logSourcesFor(widget.serverId),
    ];
  }

  LogSource get _source =>
      _sources.where((s) => s.id == _sourceId).firstOrNull ?? _sources.first;

  bool get _root =>
      ref.read(appDataProvider).value?.server(widget.serverId)?.username ==
      'root';

  Future<void> _start() async {
    _stop();
    final session = ref.read(sessionProvider(widget.serverId));
    if (session is! SessionReady) return;
    setState(() {
      _lines.clear();
      _pending.clear();
      _problem = null;
      _loading = true;
    });
    try {
      final running = await session.connection.start(
        followCommand(_source, root: _root),
      );
      if (!mounted) {
        running.stop();
        return;
      }
      _running = running;
      _subscription = running.lines.listen(
        _add,
        onDone: () {
          if (!mounted || !identical(_running, running)) return;
          final code = running.exitCode;
          setState(() {
            _loading = false;
            // A follower only ends on its own when it could not start.
            if (code != null && code != 0 && _lines.isNotEmpty) {
              _problem = _lines.last;
            } else if (code != null && code != 0) {
              _problem = context.l.logsEnded(code);
            }
          });
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _problem = e.toString();
        });
      }
    }
  }

  void _stop() {
    _subscription?.cancel();
    _subscription = null;
    _running?.stop();
    _running = null;
  }

  void _add(String line) {
    if (!mounted) return;
    if (_paused) {
      _pending.add(line);
      if (_pending.length > _maxLines) _pending.removeAt(0);
      setState(() {});
      return;
    }
    setState(() {
      _loading = false;
      _lines.add(line);
      if (_lines.length > _maxLines) {
        _lines.removeRange(0, _lines.length - _maxLines);
      }
    });
  }

  void _resume() => setState(() {
    _paused = false;
    _lines.addAll(_pending);
    _pending.clear();
    if (_lines.length > _maxLines) {
      _lines.removeRange(0, _lines.length - _maxLines);
    }
  });

  @override
  Widget build(BuildContext context) {
    // Rebuild when saved sources change.
    ref.watch(appDataProvider.select((d) => d.value?.logSources));
    final l = context.l;
    final q = _filter.toLowerCase();
    final shown = _lines.where((line) {
      if (_errorsOnly && levelOf(line) != LineLevel.error) return false;
      return q.isEmpty || line.toLowerCase().contains(q);
    }).toList();
    final status = context.status;

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final s in _sources) ...[
                GestureDetector(
                  onLongPress: s.kind == LogKind.journal
                      ? null
                      : () => _deleteSource(s),
                  child: ChoiceChip(
                    avatar: Icon(switch (s.kind) {
                      LogKind.journal => Icons.menu_book_rounded,
                      LogKind.unit => Icons.miscellaneous_services_rounded,
                      LogKind.file => Icons.description_rounded,
                    }, size: 17),
                    label: Text(s.name),
                    selected: s.id == _source.id,
                    showCheckmark: false,
                    onSelected: (_) {
                      setState(() => _sourceId = s.id);
                      _start();
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: Text(l.logsAdd),
                onPressed: _addSource,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l.logsFilter,
                    prefixIcon: const Icon(Icons.filter_list_rounded),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _filter = v.trim()),
                ),
              ),
              IconButton(
                tooltip: l.logsErrorsOnly,
                isSelected: _errorsOnly,
                selectedIcon: Icon(Icons.error_rounded, color: status.bad),
                icon: const Icon(Icons.error_outline_rounded),
                onPressed: () => setState(() => _errorsOnly = !_errorsOnly),
              ),
              IconButton(
                tooltip: _paused ? l.logsResume : l.logsPause,
                icon: Icon(
                  _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                ),
                onPressed: () =>
                    _paused ? _resume() : setState(() => _paused = true),
              ),
              IconButton(
                tooltip: l.logsClear,
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => setState(() {
                  _lines.clear();
                  _pending.clear();
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                if (_problem != null && shown.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _problem!,
                        textAlign: TextAlign.center,
                        style: mono(size: 12, color: status.bad),
                      ),
                    ),
                  )
                else if (_loading && shown.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  // Reversed, so the newest line sits at the bottom and the
                  // view stays there while lines arrive.
                  ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    itemCount: shown.length,
                    itemBuilder: (context, i) {
                      final line = shown[shown.length - 1 - i];
                      final level = levelOf(line);
                      final (time, text) = splitJournalLine(line);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              if (time != null)
                                TextSpan(
                                  text: '$time  ',
                                  style: mono(
                                    size: 11.2,
                                    height: 1.4,
                                    color: context.colors.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              TextSpan(text: text),
                            ],
                          ),
                          style: mono(
                            size: 11.2,
                            height: 1.4,
                            color: switch (level) {
                              LineLevel.error => status.bad,
                              LineLevel.warning => status.warn,
                              LineLevel.normal =>
                                context.colors.onSurface.withValues(
                                  alpha: 0.86,
                                ),
                            },
                          ),
                        ),
                      );
                    },
                  ),
                if (_paused && _pending.isNotEmpty)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 40),
                        ),
                        onPressed: _resume,
                        icon: const Icon(Icons.south_rounded, size: 18),
                        label: Text(l.logsNewLines(_pending.length)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addSource() async {
    final source = await showModalBottomSheet<LogSource>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SourceSheet(serverId: widget.serverId),
    );
    if (source == null) return;
    await ref.read(appDataProvider.notifier).saveLogSource(source);
    if (!mounted) return;
    setState(() => _sourceId = source.id);
    _start();
  }

  Future<void> _deleteSource(LogSource source) async {
    final ok = await confirm(
      context,
      title: context.l.logsDeleteTitle(source.name),
      message: context.l.logsDeleteMessage,
      action: context.l.delete,
      destructive: true,
    );
    if (!ok) return;
    await ref.read(appDataProvider.notifier).deleteLogSource(source.id);
    if (_sourceId == source.id && mounted) {
      setState(() => _sourceId = 'journal:${widget.serverId}');
      _start();
    }
  }
}

class _SourceSheet extends StatefulWidget {
  const _SourceSheet({required this.serverId});
  final String serverId;

  @override
  State<_SourceSheet> createState() => _SourceSheetState();
}

class _SourceSheetState extends State<_SourceSheet> {
  LogKind _kind = LogKind.unit;
  final _target = TextEditingController();
  final _name = TextEditingController();

  @override
  void dispose() {
    _target.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.logsAddTitle, style: context.text.titleLarge),
          const SizedBox(height: 16),
          SegmentedButton<LogKind>(
            segments: [
              ButtonSegment(
                value: LogKind.unit,
                icon: const Icon(Icons.miscellaneous_services_rounded),
                label: Text(l.logsKindUnit),
              ),
              ButtonSegment(
                value: LogKind.file,
                icon: const Icon(Icons.description_rounded),
                label: Text(l.logsKindFile),
              ),
            ],
            selected: {_kind},
            onSelectionChanged: (s) => setState(() => _kind = s.first),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _target,
            autofocus: true,
            autocorrect: false,
            style: mono(size: 14),
            decoration: InputDecoration(
              labelText: _kind == LogKind.unit
                  ? l.logsUnitLabel
                  : l.logsFileLabel,
              hintText: _kind == LogKind.unit
                  ? 'nginx'
                  : '/var/log/nginx/error.log',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: l.serverName,
              hintText: l.serverNameHint,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              var target = _target.text.trim();
              if (target.isEmpty) return;
              if (_kind == LogKind.unit &&
                  !target.contains('.') &&
                  !target.contains('@')) {
                target = '$target.service';
              }
              final name = _name.text.trim();
              Navigator.pop(
                context,
                LogSource(
                  id: newId(),
                  serverId: widget.serverId,
                  name: name.isNotEmpty
                      ? name
                      : _kind == LogKind.unit
                      ? target.replaceFirst(RegExp(r'\.service$'), '')
                      : target.split('/').last,
                  kind: _kind,
                  target: target,
                ),
              );
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
  }
}
