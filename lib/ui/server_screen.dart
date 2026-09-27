import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_data.dart';
import '../data/models.dart';
import '../probes/services.dart';
import '../ssh/connection.dart';
import '../ssh/session.dart';
import 'commands_tab.dart';
import 'logs_tab.dart';
import 'overview_tab.dart';
import 'server_edit_screen.dart';
import 'services_tab.dart';
import 'terminal_tab.dart';
import 'theme.dart';
import 'widgets.dart';

/// One server: connects on open, and shows what it can once signed in.
class ServerScreen extends ConsumerStatefulWidget {
  const ServerScreen({super.key, required this.serverId});
  final String serverId;

  @override
  ConsumerState<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends ConsumerState<ServerScreen> {
  int _tab = 0;

  /// Tabs opened once stay built, so coming back does not reload them.
  final _visited = <int>{0};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  void _connect() => ref
      .read(sessionProvider(widget.serverId).notifier)
      .connect(_askAboutHostKey);

  Future<bool> _askAboutHostKey(
    String host,
    String type,
    String fingerprint,
  ) async {
    if (!mounted) return false;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          HostKeyDialog(host: host, type: type, fingerprint: fingerprint),
    );
    return accepted ?? false;
  }

  /// Signs in once with a password, adds the server's key to
  /// authorized_keys, and connects again with the key. The password is used
  /// for this one sign-in and not kept.
  Future<void> _installKey(ServerProfile server) async {
    final l = context.l;
    final data = ref.read(appDataProvider).value;
    final key = data?.key(server.keyId ?? '');
    if (key == null) return;
    final password = await showDialog<String>(
      context: context,
      builder: (_) => _PasswordDialog(server: server),
    );
    if (password == null || password.isEmpty || !mounted) return;

    final store = ref.read(appDataProvider.notifier);
    try {
      final connection = await ref.read(connectorProvider)(
        server: server.copyWith(auth: AuthMethod.password),
        known: data!.knownHost(server.hostKeyId),
        prompt: _askAboutHostKey,
        onTrust: (type, fp) => store.trustHost(server.hostKeyId, type, fp),
        password: password,
      );
      try {
        final result = await connection.run(installKeyCommand(key.publicKey));
        if (!result.ok) throw Exception(result.stderr.trim());
      } finally {
        connection.close();
      }
      if (!mounted) return;
      showMessage(context, l.installKeyDone);
      _connect();
    } catch (e) {
      if (!mounted) return;
      showMessage(
        context,
        classify(e) == ConnectionProblem.authFailed
            ? l.problemAuthPassword(server.username)
            : e.toString(),
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final server = ref.watch(
      appDataProvider.select((d) => d.value?.server(widget.serverId)),
    );
    final session = ref.watch(sessionProvider(widget.serverId));
    if (server == null) return const Scaffold();

    final status = context.status;
    final (Color dot, bool pulse) = switch (session) {
      SessionReady() => (status.ok, false),
      SessionConnecting() => (status.warn, true),
      SessionFailed() => (status.bad, false),
    };

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(server.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              server.address,
              style: mono(size: 12, color: context.colors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: StatusPill(
              label: switch (session) {
                SessionReady() => context.l.sessionOnline,
                SessionConnecting() => context.l.sessionConnecting,
                SessionFailed(:final problem)
                    when problem == ConnectionProblem.unreachable ||
                        problem == ConnectionProblem.timeout ||
                        problem == ConnectionProblem.disconnected =>
                  context.l.statusDown,
                SessionFailed() => context.l.sessionError,
              },
              color: dot,
              pulse: pulse,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'reconnect') _connect();
              if (v == 'edit') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServerEditScreen(server: server),
                  ),
                );
                _connect();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reconnect',
                child: Text(context.l.sessionReconnect),
              ),
              PopupMenuItem(value: 'edit', child: Text(context.l.edit)),
            ],
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: switch (session) {
          SessionConnecting() => _Connecting(server: server),
          SessionFailed() => _Failed(
            server: server,
            state: session,
            onRetry: _connect,
            onForgetKey: () async {
              await ref
                  .read(sessionProvider(widget.serverId).notifier)
                  .forgetHostKey();
              _connect();
            },
            onInstallKey: () => _installKey(server),
          ),
          SessionReady() => IndexedStack(
            key: const ValueKey('ready'),
            index: _tab,
            children: [
              OverviewTab(serverId: widget.serverId, active: _tab == 0),
              _tab == 1 || _visited.contains(1)
                  ? ServicesTab(serverId: widget.serverId)
                  : const SizedBox(),
              _tab == 2 || _visited.contains(2)
                  ? LogsTab(serverId: widget.serverId, active: _tab == 2)
                  : const SizedBox(),
              _tab == 3 || _visited.contains(3)
                  ? CommandsTab(serverId: widget.serverId)
                  : const SizedBox(),
              _tab == 4 || _visited.contains(4)
                  ? TerminalTab(serverId: widget.serverId)
                  : const SizedBox(),
            ],
          ),
        },
      ),
      bottomNavigationBar: session is SessionReady
          ? NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() {
                _tab = i;
                _visited.add(i);
              }),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.speed_outlined),
                  selectedIcon: const Icon(Icons.speed_rounded),
                  label: context.l.tabOverview,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.miscellaneous_services_outlined),
                  selectedIcon: const Icon(
                    Icons.miscellaneous_services_rounded,
                  ),
                  label: context.l.tabServices,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.receipt_long_outlined),
                  selectedIcon: const Icon(Icons.receipt_long_rounded),
                  label: context.l.tabLogs,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.bolt_outlined),
                  selectedIcon: const Icon(Icons.bolt_rounded),
                  label: context.l.tabCommands,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.terminal_outlined),
                  selectedIcon: const Icon(Icons.terminal_rounded),
                  label: context.l.tabTerminal,
                ),
              ],
            )
          : null,
    );
  }
}

class _Connecting extends StatelessWidget {
  const _Connecting({required this.server});
  final ServerProfile server;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox.square(
          dimension: 42,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 20),
        Text(context.l.sessionConnectingTo, style: context.text.titleMedium),
        const SizedBox(height: 6),
        Text(
          server.address,
          style: mono(size: 13, color: context.colors.onSurfaceVariant),
        ),
      ],
    ),
  );
}

class _Failed extends StatelessWidget {
  const _Failed({
    required this.server,
    required this.state,
    required this.onRetry,
    required this.onForgetKey,
    required this.onInstallKey,
  });

  final ServerProfile server;
  final SessionFailed state;
  final VoidCallback onRetry;
  final VoidCallback onForgetKey;
  final VoidCallback onInstallKey;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final problem = state.problem;
    final (IconData icon, String title, String message) = switch (problem) {
      ConnectionProblem.unreachable => (
        Icons.cloud_off_rounded,
        l.problemUnreachableTitle,
        l.problemUnreachable(server.host, server.port),
      ),
      ConnectionProblem.timeout => (
        Icons.timer_off_rounded,
        l.problemTimeoutTitle,
        l.problemTimeout,
      ),
      ConnectionProblem.authFailed => (
        Icons.no_accounts_rounded,
        l.problemAuthTitle,
        server.auth == AuthMethod.key
            ? l.problemAuthKey(server.username)
            : l.problemAuthPassword(server.username),
      ),
      ConnectionProblem.hostKeyChanged => (
        Icons.gpp_bad_rounded,
        l.problemHostKeyChangedTitle,
        l.problemHostKeyChanged,
      ),
      ConnectionProblem.hostKeyRefused => (
        Icons.gpp_maybe_rounded,
        l.problemHostKeyRefusedTitle,
        l.problemHostKeyRefused,
      ),
      ConnectionProblem.missingCredentials => (
        Icons.key_off_rounded,
        l.problemMissingTitle,
        l.problemMissing,
      ),
      ConnectionProblem.disconnected => (
        Icons.link_off_rounded,
        l.problemDisconnectedTitle,
        l.problemDisconnected,
      ),
      ConnectionProblem.other => (
        Icons.error_outline_rounded,
        l.problemOtherTitle,
        state.error.toString(),
      ),
    };
    final changed = state.error is HostKeyChanged
        ? state.error as HostKeyChanged
        : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      children: [
        Center(
          child: TintedIcon(
            icon,
            size: 72,
            color: problem == ConnectionProblem.hostKeyChanged
                ? context.status.bad
                : context.status.warn,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.text.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        if (changed != null) ...[
          const SizedBox(height: 20),
          _Fingerprint(
            label: l.hostKeyKnown,
            type: changed.known.type,
            fingerprint: changed.known.fingerprint,
          ),
          const SizedBox(height: 8),
          _Fingerprint(
            label: l.hostKeyNow,
            type: changed.type,
            fingerprint: changed.fingerprint,
            color: context.status.bad,
          ),
        ],
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(l.sessionReconnect),
        ),
        if (problem == ConnectionProblem.authFailed &&
            server.auth == AuthMethod.key &&
            server.keyId != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onInstallKey,
            icon: const Icon(Icons.key_rounded),
            label: Text(l.installKey),
          ),
        ],
        if (changed != null) ...[
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: context.status.bad,
            ),
            onPressed: () async {
              final ok = await confirm(
                context,
                title: l.hostKeyForgetTitle,
                message: l.hostKeyForgetMessage,
                action: l.hostKeyForget,
                destructive: true,
              );
              if (ok) onForgetKey();
            },
            child: Text(l.hostKeyForget),
          ),
        ],
      ],
    );
  }
}

class _Fingerprint extends StatelessWidget {
  const _Fingerprint({
    required this.label,
    required this.type,
    required this.fingerprint,
    this.color,
  });

  final String label;
  final String type;
  final String fingerprint;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.colors.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label · $type',
          style: context.text.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(
          fingerprint,
          style: mono(size: 12, weight: FontWeight.w600, color: color),
        ),
      ],
    ),
  );
}

/// Shown the first time a server is met: its key fingerprint, and a way to
/// check it on the server itself.
class HostKeyDialog extends StatelessWidget {
  const HostKeyDialog({
    super.key,
    required this.host,
    required this.type,
    required this.fingerprint,
  });

  final String host;
  final String type;
  final String fingerprint;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final file = switch (type) {
      'ssh-ed25519' => 'ssh_host_ed25519_key.pub',
      'ssh-rsa' || 'rsa-sha2-256' || 'rsa-sha2-512' => 'ssh_host_rsa_key.pub',
      _ when type.startsWith('ecdsa') => 'ssh_host_ecdsa_key.pub',
      _ => 'ssh_host_*_key.pub',
    };
    return AlertDialog(
      icon: Icon(Icons.fingerprint_rounded, color: context.colors.primary),
      title: Text(l.hostKeyNewTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.hostKeyNew(host)),
          const SizedBox(height: 14),
          _Fingerprint(
            label: l.hostKeyNow,
            type: type,
            fingerprint: fingerprint,
          ),
          const SizedBox(height: 14),
          Text(
            l.hostKeyCheck,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            'ssh-keygen -lf /etc/ssh/$file',
            style: mono(size: 11.5),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.hostKeyReject),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.hostKeyAccept),
        ),
      ],
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.server});
  final ServerProfile server;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return AlertDialog(
      icon: Icon(Icons.key_rounded, color: context.colors.primary),
      title: Text(l.installKey),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.installKeyHint(widget.server.username)),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(labelText: l.authPassword),
            onSubmitted: (v) => Navigator.pop(context, v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () => Navigator.pop(context, _password.text),
          child: Text(l.installKeyAction),
        ),
      ],
    );
  }
}
