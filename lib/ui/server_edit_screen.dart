import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_data.dart';
import '../data/models.dart';
import '../ssh/keys.dart';
import 'theme.dart';
import 'widgets.dart';

/// Adds a server, or changes one when [server] is given.
class ServerEditScreen extends ConsumerStatefulWidget {
  const ServerEditScreen({super.key, this.server});
  final ServerProfile? server;

  @override
  ConsumerState<ServerEditScreen> createState() => _ServerEditScreenState();
}

class _ServerEditScreenState extends ConsumerState<ServerEditScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.server?.name);
  late final _host = TextEditingController(text: widget.server?.host);
  late final _port = TextEditingController(
    text: '${widget.server?.port ?? 22}',
  );
  late final _user = TextEditingController(
    text: widget.server?.username ?? 'root',
  );
  final _password = TextEditingController();
  late AuthMethod _auth = widget.server?.auth ?? AuthMethod.key;
  late String? _keyId = widget.server?.keyId;
  bool _hasPassword = false;
  bool _showPassword = false;
  bool _saving = false;

  bool get _editing => widget.server != null;

  @override
  void initState() {
    super.initState();
    final server = widget.server;
    if (server != null) {
      ref.read(appDataProvider.notifier).password(server.id).then((value) {
        if (mounted && value != null) setState(() => _hasPassword = true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _host, _port, _user, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final keys = ref.watch(appDataProvider).value?.keys ?? const <SshKey>[];
    if (_keyId == null && keys.isNotEmpty && !_editing) _keyId = keys.first.id;
    final selectedKey = keys.where((k) => k.id == _keyId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? l.serverEditTitle : l.serverAdd)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            SectionLabel(l.serverSectionConnection),
            TextFormField(
              controller: _host,
              decoration: InputDecoration(
                labelText: l.serverHost,
                hintText: 'example.com',
                prefixIcon: const Icon(Icons.public_rounded),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? l.fieldRequired : null,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _user,
                    decoration: InputDecoration(
                      labelText: l.serverUser,
                      prefixIcon: const Icon(Icons.person_rounded),
                    ),
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? l.fieldRequired : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _port,
                    decoration: InputDecoration(labelText: l.serverPort),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: mono(size: 15),
                    validator: (v) {
                      final port = int.tryParse(v ?? '');
                      return port == null || port < 1 || port > 65535
                          ? l.serverPortInvalid
                          : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: l.serverName,
                hintText: l.serverNameHint,
                prefixIcon: const Icon(Icons.label_rounded),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            SectionLabel(l.serverSectionAuth),
            SegmentedButton<AuthMethod>(
              segments: [
                ButtonSegment(
                  value: AuthMethod.key,
                  icon: const Icon(Icons.key_rounded),
                  label: Text(l.authKey),
                ),
                ButtonSegment(
                  value: AuthMethod.password,
                  icon: const Icon(Icons.password_rounded),
                  label: Text(l.authPassword),
                ),
              ],
              selected: {_auth},
              onSelectionChanged: (s) => setState(() => _auth = s.first),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _auth == AuthMethod.key
                  ? _keyPicker(keys, selectedKey)
                  : _passwordField(),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Text(l.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keyPicker(List<SshKey> keys, SshKey? selected) {
    final l = context.l;
    return Column(
      key: const ValueKey('key'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (keys.isNotEmpty)
          DropdownButtonFormField<String>(
            initialValue: selected?.id,
            decoration: InputDecoration(
              labelText: l.authKeyPick,
              prefixIcon: const Icon(Icons.vpn_key_rounded),
            ),
            items: [
              for (final k in keys)
                DropdownMenuItem(value: k.id, child: Text(k.name)),
            ],
            onChanged: (id) => setState(() => _keyId = id),
            validator: (id) =>
                _auth == AuthMethod.key && id == null ? l.authKeyMissing : null,
          ),
        if (selected != null) ...[
          const SizedBox(height: 12),
          PublicKeyBox(sshKey: selected),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _generate,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: Text(l.keyGenerateNew),
        ),
        if (keys.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l.authKeyNone,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _passwordField() => TextFormField(
    key: const ValueKey('password'),
    controller: _password,
    obscureText: !_showPassword,
    autocorrect: false,
    enableSuggestions: false,
    decoration: InputDecoration(
      labelText: context.l.authPassword,
      helperText: _hasPassword ? context.l.authPasswordKept : null,
      prefixIcon: const Icon(Icons.lock_rounded),
      suffixIcon: IconButton(
        icon: Icon(
          _showPassword
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
        ),
        onPressed: () => setState(() => _showPassword = !_showPassword),
      ),
    ),
    validator: (v) =>
        _auth == AuthMethod.password && !_hasPassword && (v ?? '').isEmpty
        ? context.l.fieldRequired
        : null,
  );

  Future<void> _generate() async {
    final name =
        'ServerDeck ${DateTime.now().toIso8601String().substring(0, 10)}';
    final material = generateEd25519('serverdeck');
    final key = await ref.read(appDataProvider.notifier).addKey(name, material);
    if (!mounted) return;
    setState(() => _keyId = key.id);
    showMessage(context, context.l.keyGenerated);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final host = _host.text.trim();
    final name = _name.text.trim();
    final server = ServerProfile(
      id: widget.server?.id ?? newId(),
      name: name.isEmpty ? host : name,
      host: host,
      port: int.parse(_port.text),
      username: _user.text.trim(),
      auth: _auth,
      keyId: _auth == AuthMethod.key ? _keyId : widget.server?.keyId,
    );
    final password = _password.text;
    await ref
        .read(appDataProvider.notifier)
        .saveServer(
          server,
          password: _auth == AuthMethod.password && password.isNotEmpty
              ? password
              : null,
        );
    if (mounted) Navigator.pop(context, server);
  }
}

/// The public key line, ready to be copied into `authorized_keys`.
class PublicKeyBox extends StatelessWidget {
  const PublicKeyBox({super.key, required this.sshKey});
  final SshKey sshKey;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
    decoration: BoxDecoration(
      color: context.colors.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sshKey.fingerprint,
                style: mono(size: 11.5, color: context.colors.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                sshKey.publicKey,
                style: mono(
                  size: 11,
                  color: context.colors.onSurfaceVariant,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: context.l.keyCopy,
          icon: const Icon(Icons.copy_rounded),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: sshKey.publicKey));
            if (context.mounted) showMessage(context, context.l.keyCopied);
          },
        ),
      ],
    ),
  );
}
