import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_data.dart';
import '../data/models.dart';
import 'connection.dart';

/// The connection dropped after it was up: network change, server reboot,
/// the phone slept.
class Disconnected implements Exception {
  const Disconnected();
}

sealed class SessionState {
  const SessionState();
}

class SessionConnecting extends SessionState {
  const SessionConnecting();
}

class SessionReady extends SessionState {
  const SessionReady(this.connection);
  final Connection connection;
}

class SessionFailed extends SessionState {
  const SessionFailed(this.error);
  final Object error;

  ConnectionProblem get problem =>
      error is Disconnected ? ConnectionProblem.disconnected : classify(error);
}

/// How connections are opened: over SSH, or made up in the demo build.
final connectorProvider = Provider<Connector>((ref) => ServerConnection.open);

/// The SSH connection of one open server screen. It lives as long as
/// something watches it, and closes with the last watcher.
final sessionProvider = NotifierProvider.autoDispose
    .family<SessionNotifier, SessionState, String>(SessionNotifier.new);

class SessionNotifier extends Notifier<SessionState> {
  SessionNotifier(this.serverId);
  final String serverId;

  Connection? _connection;
  int _attempt = 0;

  @override
  SessionState build() {
    ref.onDispose(() {
      _attempt++;
      _connection?.close();
      _connection = null;
    });
    return const SessionConnecting();
  }

  /// Connects, or reconnects. [prompt] is asked about a host key seen for
  /// the first time.
  Future<void> connect(HostKeyPrompt prompt) async {
    final attempt = ++_attempt;
    _connection?.close();
    _connection = null;
    state = const SessionConnecting();

    bool current() => attempt == _attempt && ref.mounted;

    try {
      final data = await ref.read(appDataProvider.future);
      final server = data.server(serverId);
      if (server == null) throw const MissingCredentials();
      final store = ref.read(appDataProvider.notifier);
      final keyId = server.keyId;

      final connection = await ref.read(connectorProvider)(
        server: server,
        known: data.knownHost(server.hostKeyId),
        prompt: prompt,
        onTrust: (type, fingerprint) =>
            store.trustHost(server.hostKeyId, type, fingerprint),
        privateKeyPem: server.auth == AuthMethod.key && keyId != null
            ? await store.privateKey(keyId)
            : null,
        password: server.auth == AuthMethod.password
            ? await store.password(server.id)
            : null,
      );
      if (!current()) {
        connection.close();
        return;
      }
      _connection = connection;
      state = SessionReady(connection);
      unawaited(
        connection.done.then(
          (_) => _dropped(connection, const Disconnected()),
          onError: (Object e) => _dropped(connection, e),
        ),
      );
    } catch (e) {
      if (current()) state = SessionFailed(e);
    }
  }

  void _dropped(Connection connection, Object error) {
    if (!ref.mounted || !identical(connection, _connection)) return;
    _connection = null;
    state = SessionFailed(error is Disconnected ? error : const Disconnected());
  }

  /// Forgets the host key on record, after the user decided the change is
  /// expected (a reinstall), so the next connect asks afresh.
  Future<void> forgetHostKey() async {
    final data = await ref.read(appDataProvider.future);
    final server = data.server(serverId);
    if (server != null) {
      await ref.read(appDataProvider.notifier).forgetHost(server.hostKeyId);
    }
  }
}
