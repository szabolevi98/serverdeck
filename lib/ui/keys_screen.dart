import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/app_data.dart';
import '../data/models.dart';
import '../ssh/keys.dart';
import 'server_edit_screen.dart';
import 'theme.dart';
import 'widgets.dart';

class KeysScreen extends ConsumerWidget {
  const KeysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(appDataProvider).value ?? const AppData();
    final keys = data.keys;

    return Scaffold(
      appBar: AppBar(title: Text(context.l.keysTitle)),
      body: keys.isEmpty
          ? EmptyState(
              icon: Icons.key_rounded,
              title: context.l.keysEmptyTitle,
              message: context.l.keysEmpty,
              action: FilledButton.icon(
                onPressed: () => _add(context, ref),
                icon: const Icon(Icons.add_rounded),
                label: Text(context.l.keyAdd),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              itemCount: keys.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final key = keys[i];
                final users = data.servers
                    .where((s) => s.auth == AuthMethod.key && s.keyId == key.id)
                    .map((s) => s.name)
                    .toList();
                return _KeyCard(sshKey: key, usedBy: users);
              },
            ),
      floatingActionButton: keys.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _add(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l.keyAdd),
            ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetOption(
                icon: Icons.auto_awesome_rounded,
                title: context.l.keyGenerateNew,
                subtitle: context.l.keyGenerateHint,
                onTap: () => Navigator.pop(context, 'generate'),
              ),
              const SizedBox(height: 10),
              _SheetOption(
                icon: Icons.file_download_rounded,
                title: context.l.keyImport,
                subtitle: context.l.keyImportHint,
                onTap: () => Navigator.pop(context, 'import'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!context.mounted || choice == null) return;
    if (choice == 'generate') {
      final name = await _askName(context, context.l.keyGenerateNew);
      if (name == null || !context.mounted) return;
      await ref
          .read(appDataProvider.notifier)
          .addKey(name, generateEd25519('serverdeck'));
      if (context.mounted) showMessage(context, context.l.keyGenerated);
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const KeyImportScreen()),
      );
    }
  }
}

Future<String?> _askName(
  BuildContext context,
  String title, {
  String? initial,
}) {
  final controller = TextEditingController(
    text:
        initial ??
        'ServerDeck ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
  );
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(labelText: context.l.keyName),
        onSubmitted: (v) =>
            Navigator.pop(context, v.trim().isEmpty ? null : v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () {
            final v = controller.text.trim();
            Navigator.pop(context, v.isEmpty ? null : v);
          },
          child: Text(context.l.ok),
        ),
      ],
    ),
  );
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    color: context.colors.surfaceContainer,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            TintedIcon(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    ),
  );
}

class _KeyCard extends ConsumerWidget {
  const _KeyCard({required this.sshKey, required this.usedBy});
  final SshKey sshKey;
  final List<String> usedBy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final created = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(sshKey.created);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const TintedIcon(Icons.key_rounded, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sshKey.name, style: context.text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${_typeLabel(sshKey.type)} · $created',
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) => _act(context, ref, v),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'rename', child: Text(l.rename)),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        l.delete,
                        style: TextStyle(color: context.colors.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PublicKeyBox(sshKey: sshKey),
            ),
            if (usedBy.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final name in usedBy)
                    Chip(
                      avatar: const Icon(Icons.dns_rounded, size: 16),
                      label: Text(name),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _typeLabel(String type) => switch (type) {
    'ssh-ed25519' => 'Ed25519',
    'ssh-rsa' => 'RSA',
    _ when type.startsWith('ecdsa-sha2-') =>
      'ECDSA ${type.substring('ecdsa-sha2-'.length)}',
    _ => type,
  };

  Future<void> _act(BuildContext context, WidgetRef ref, String action) async {
    final notifier = ref.read(appDataProvider.notifier);
    if (action == 'rename') {
      final name = await _askName(
        context,
        context.l.rename,
        initial: sshKey.name,
      );
      if (name != null) await notifier.renameKey(sshKey.id, name);
      return;
    }
    final ok = await confirm(
      context,
      title: context.l.keyDeleteTitle(sshKey.name),
      message: usedBy.isEmpty
          ? context.l.keyDeleteMessage
          : context.l.keyDeleteUsed(usedBy.join(', ')),
      action: context.l.delete,
      destructive: true,
    );
    if (ok) await notifier.deleteKey(sshKey.id);
  }
}

/// Paste an existing private key, with its passphrase if it has one.
class KeyImportScreen extends ConsumerStatefulWidget {
  const KeyImportScreen({super.key});

  @override
  ConsumerState<KeyImportScreen> createState() => _KeyImportScreenState();
}

class _KeyImportScreenState extends ConsumerState<KeyImportScreen> {
  final _name = TextEditingController();
  final _pem = TextEditingController();
  final _passphrase = TextEditingController();
  String? _error;
  bool _askPassphrase = false;

  @override
  void dispose() {
    _name.dispose();
    _pem.dispose();
    _passphrase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.keyImport)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: l.keyName,
              prefixIcon: const Icon(Icons.label_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pem,
            minLines: 8,
            maxLines: 14,
            style: mono(size: 11.5),
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l.keyPrivate,
              hintText: '-----BEGIN OPENSSH PRIVATE KEY-----\n...',
              alignLabelWithHint: true,
              suffixIcon: IconButton(
                tooltip: l.paste,
                icon: const Icon(Icons.content_paste_rounded),
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null) _pem.text = data!.text!;
                },
              ),
            ),
          ),
          if (_askPassphrase) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _passphrase,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l.keyPassphrase,
                prefixIcon: const Icon(Icons.lock_rounded),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: context.colors.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(onPressed: _import, child: Text(l.keyImport)),
          const SizedBox(height: 12),
          Text(
            l.keyImportNote,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _import() async {
    final l = context.l;
    final KeyMaterial material;
    try {
      material = importPrivateKey(_pem.text, passphrase: _passphrase.text);
    } on KeyImportException catch (e) {
      setState(() {
        _askPassphrase =
            _askPassphrase ||
            e.problem == KeyImportProblem.needsPassphrase ||
            e.problem == KeyImportProblem.wrongPassphrase;
        _error = switch (e.problem) {
          KeyImportProblem.notAKey => l.keyErrorNotAKey,
          KeyImportProblem.needsPassphrase => l.keyErrorNeedsPassphrase,
          KeyImportProblem.wrongPassphrase => l.keyErrorWrongPassphrase,
          KeyImportProblem.unsupported => l.keyErrorUnsupported,
        };
      });
      return;
    }
    final name = _name.text.trim();
    await ref
        .read(appDataProvider.notifier)
        .addKey(name.isEmpty ? l.keyImportedName : name, material);
    if (mounted) Navigator.pop(context);
  }
}
