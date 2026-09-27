import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_data.dart';
import '../l10n/generated/app_localizations.dart';
import '../data/models.dart';
import '../probes/logs.dart';
import '../ssh/connection.dart';
import '../ssh/session.dart';
import 'theme.dart';
import 'widgets.dart';

/// Ready-made commands offered while a server has none of its own.
List<(String, String)> _templates(AppLocalizations l) => [
  (l.tplDisk, 'df -h -x tmpfs -x devtmpfs -x squashfs -x overlay'),
  (l.tplFolders, 'du -xh --max-depth=1 / 2>/dev/null | sort -h | tail -n 12'),
  (l.tplUpdates, 'apt list --upgradable 2>/dev/null | tail -n +2'),
  (l.tplWho, 'w'),
  (l.tplApache, 'apache2ctl configtest'),
  (l.tplNginx, 'nginx -t'),
  (l.tplTop, 'ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 15'),
  (l.tplPorts, 'ss -tulpn'),
];

class CommandsTab extends ConsumerStatefulWidget {
  const CommandsTab({super.key, required this.serverId});
  final String serverId;

  @override
  ConsumerState<CommandsTab> createState() => _CommandsTabState();
}

class _CommandsTabState extends ConsumerState<CommandsTab> {
  final _quick = TextEditingController();

  @override
  void dispose() {
    _quick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final commands =
        ref.watch(
          appDataProvider.select((d) => d.value?.commandsFor(widget.serverId)),
        ) ??
        const <SavedCommand>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        tooltip: l.commandAdd,
        onPressed: () => _edit(null),
        child: const Icon(Icons.add_rounded),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          TextField(
            controller: _quick,
            style: mono(size: 14),
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _runQuick(),
            decoration: InputDecoration(
              hintText: l.commandQuick,
              prefixIcon: Icon(
                Icons.chevron_right_rounded,
                color: context.colors.primary,
              ),
              suffixIcon: IconButton(
                tooltip: l.commandRun,
                icon: const Icon(Icons.play_arrow_rounded),
                onPressed: _runQuick,
              ),
            ),
          ),
          if (commands.isEmpty) ...[
            SectionLabel(l.commandTemplates),
            Text(
              l.commandTemplatesHint,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (name, command) in _templates(l))
                  ActionChip(
                    avatar: const Icon(Icons.add_rounded, size: 18),
                    label: Text(name),
                    onPressed: () => ref
                        .read(appDataProvider.notifier)
                        .saveCommand(
                          SavedCommand(
                            id: newId(),
                            name: name,
                            command: command,
                            confirm: false,
                          ),
                        ),
                  ),
              ],
            ),
          ] else ...[
            SectionLabel(l.commandSaved),
            for (final c in commands) ...[
              _CommandCard(
                command: c,
                onRun: () => _run(c.command, title: c.name, ask: c.confirm),
                onEdit: () => _edit(c),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }

  void _runQuick() {
    final command = _quick.text.trim();
    if (command.isEmpty) return;
    FocusScope.of(context).unfocus();
    _run(command, title: command, ask: false);
  }

  Future<void> _run(
    String command, {
    required String title,
    required bool ask,
  }) async {
    if (ask) {
      final ok = await confirm(
        context,
        title: context.l.commandRunTitle(title),
        message: context.l.actionConfirmMessage(command),
        action: context.l.commandRun,
      );
      if (!ok) return;
    }
    final session = ref.read(sessionProvider(widget.serverId));
    if (session is! SessionReady || !mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommandRunScreen(
          connection: session.connection,
          title: title,
          command: command,
        ),
      ),
    );
  }

  Future<void> _edit(SavedCommand? command) async {
    final result = await showModalBottomSheet<_EditResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _CommandSheet(command: command, serverId: widget.serverId),
    );
    if (result == null) return;
    final store = ref.read(appDataProvider.notifier);
    if (result.delete) {
      await store.deleteCommand(command!.id);
    } else {
      await store.saveCommand(result.command!);
    }
  }
}

class _CommandCard extends StatelessWidget {
  const _CommandCard({
    required this.command,
    required this.onRun,
    required this.onEdit,
  });

  final SavedCommand command;
  final VoidCallback onRun;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onRun,
      onLongPress: onEdit,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          command.name,
                          style: context.text.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (command.serverId == null) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.public_rounded,
                          size: 14,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    command.command,
                    style: mono(
                      size: 11.5,
                      color: context.colors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: context.l.edit,
              icon: Icon(
                Icons.tune_rounded,
                color: context.colors.onSurfaceVariant,
              ),
              onPressed: onEdit,
            ),
            IconButton.filledTonal(
              tooltip: context.l.commandRun,
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: onRun,
            ),
          ],
        ),
      ),
    ),
  );
}

class _EditResult {
  const _EditResult.save(this.command) : delete = false;
  const _EditResult.delete() : command = null, delete = true;
  final SavedCommand? command;
  final bool delete;
}

class _CommandSheet extends StatefulWidget {
  const _CommandSheet({required this.command, required this.serverId});
  final SavedCommand? command;
  final String serverId;

  @override
  State<_CommandSheet> createState() => _CommandSheetState();
}

class _CommandSheetState extends State<_CommandSheet> {
  late final _name = TextEditingController(text: widget.command?.name);
  late final _command = TextEditingController(text: widget.command?.command);
  late bool _everywhere = widget.command != null
      ? widget.command!.serverId == null
      : false;
  late bool _confirm = widget.command?.confirm ?? true;

  @override
  void dispose() {
    _name.dispose();
    _command.dispose();
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.command == null ? l.commandAdd : l.commandEdit,
              style: context.text.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: widget.command == null,
              decoration: InputDecoration(labelText: l.serverName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _command,
              minLines: 2,
              maxLines: 6,
              style: mono(size: 13),
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: l.commandLabel,
                hintText: 'cd /var/www/app && git pull --ff-only',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.commandEverywhere),
              subtitle: Text(l.commandEverywhereHint),
              value: _everywhere,
              onChanged: (v) => setState(() => _everywhere = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.commandConfirm),
              value: _confirm,
              onChanged: (v) => setState(() => _confirm = v),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _save, child: Text(l.save)),
            if (widget.command != null) ...[
              const SizedBox(height: 8),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.error,
                ),
                onPressed: () =>
                    Navigator.pop(context, const _EditResult.delete()),
                child: Text(l.delete),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _save() {
    final command = _command.text.trim();
    if (command.isEmpty) return;
    final name = _name.text.trim();
    Navigator.pop(
      context,
      _EditResult.save(
        SavedCommand(
          id: widget.command?.id ?? newId(),
          name: name.isEmpty ? command.split('\n').first : name,
          command: command,
          serverId: _everywhere ? null : widget.serverId,
          confirm: _confirm,
        ),
      ),
    );
  }
}

/// A command running, its output arriving, and how it ended.
class CommandRunScreen extends StatefulWidget {
  const CommandRunScreen({
    super.key,
    required this.connection,
    required this.title,
    required this.command,
  });

  final ServerConnection connection;
  final String title;
  final String command;

  @override
  State<CommandRunScreen> createState() => _CommandRunScreenState();
}

class _CommandRunScreenState extends State<CommandRunScreen> {
  final _lines = <String>[];
  final _watch = Stopwatch();
  final _scroll = ScrollController();
  RunningCommand? _running;
  Timer? _ticker;
  int? _exitCode;
  bool _stopped = false;
  String? _error;

  bool get _finished => _exitCode != null || _stopped || _error != null;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    _watch.start();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => mounted ? setState(() {}) : null,
    );
    try {
      final running = await widget.connection.start(widget.command);
      _running = running;
      running.lines.listen(
        (line) {
          if (!mounted) return;
          setState(() => _lines.add(line));
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scroll.hasClients) {
              _scroll.jumpTo(_scroll.position.maxScrollExtent);
            }
          });
        },
        onDone: () async {
          await running.done.catchError((_) {});
          _finish(() => _exitCode = running.exitCode ?? (_stopped ? null : -1));
        },
      );
    } catch (e) {
      _finish(() => _error = e.toString());
    }
  }

  void _finish(VoidCallback change) {
    _watch.stop();
    _ticker?.cancel();
    if (mounted) setState(change);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _running?.stop();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final status = context.status;
    final seconds = _watch.elapsedMilliseconds / 1000;
    final (Color color, String label, bool pulse) = switch (this) {
      _ when _error != null => (status.bad, l.commandError, false),
      _ when _stopped => (status.warn, l.commandStopped, false),
      _ when _exitCode == 0 => (status.ok, l.commandExit(0), false),
      _ when _exitCode != null => (
        status.bad,
        l.commandExit(_exitCode!),
        false,
      ),
      _ => (status.warn, l.commandRunning, true),
    };

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: l.commandCopy,
            icon: const Icon(Icons.copy_all_rounded),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _lines.join('\n')));
              if (context.mounted) showMessage(context, l.commandCopied);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: r'$ ',
                      style: TextStyle(color: context.colors.primary),
                    ),
                    TextSpan(text: widget.command),
                  ],
                ),
                style: mono(size: 12.5),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.outline),
              ),
              clipBehavior: Clip.antiAlias,
              child: _lines.isEmpty && _error == null
                  ? Center(
                      child: _finished
                          ? Text(
                              l.commandNoOutput,
                              style: context.text.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            )
                          : const CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(12),
                      itemCount: _lines.length + (_error == null ? 0 : 1),
                      itemBuilder: (context, i) {
                        if (i == _lines.length) {
                          return Text(
                            _error!,
                            style: mono(size: 11.5, color: status.bad),
                          );
                        }
                        final line = _lines[i];
                        return SelectableText(
                          line,
                          style: mono(
                            size: 11.5,
                            height: 1.4,
                            color: switch (levelOf(line)) {
                              LineLevel.error => status.bad,
                              LineLevel.warning => status.warn,
                              LineLevel.normal => context.colors.onSurface,
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  StatusPill(label: label, color: color, pulse: pulse),
                  const SizedBox(width: 10),
                  Text(
                    '${seconds.toStringAsFixed(1)} s',
                    style: mono(
                      size: 12,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (!_finished)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: status.bad,
                        minimumSize: const Size(0, 42),
                      ),
                      onPressed: () {
                        _stopped = true;
                        _running?.stop();
                      },
                      icon: const Icon(Icons.stop_rounded),
                      label: Text(l.actionStop),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
