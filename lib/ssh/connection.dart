import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';

import '../data/models.dart';
import 'keys.dart';

/// The server showed a different host key from the one accepted before.
/// Either it was reinstalled, or someone is in between.
class HostKeyChanged implements Exception {
  const HostKeyChanged(this.known, this.type, this.fingerprint);
  final KnownHost known;
  final String type;
  final String fingerprint;
}

/// The user said no to a host key seen for the first time.
class HostKeyRefused implements Exception {
  const HostKeyRefused();
}

/// A key-based server whose key is gone, or a password server with none.
class MissingCredentials implements Exception {
  const MissingCredentials();
}

/// What a finished command left behind.
class ExecResult {
  const ExecResult(this.stdout, this.stderr, this.exitCode);
  final String stdout;
  final String stderr;
  final int? exitCode;

  bool get ok => exitCode == 0;
}

/// A command that is still running: its output as it comes, line by line.
class RunningCommand {
  RunningCommand._(this._session, this.lines);
  final SSHSession _session;

  /// stdout and stderr, merged, split into lines.
  final Stream<String> lines;

  Future<void> get done => _session.done;
  int? get exitCode => _session.exitCode;

  void stop() {
    try {
      _session.kill(SSHSignal.INT);
    } catch (_) {}
    _session.close();
  }
}

/// Decides about a host key seen for the first time: true accepts it.
typedef HostKeyPrompt = Future<bool> Function(
  String host,
  String type,
  String fingerprint,
);

/// One signed-in SSH connection to one server.
class ServerConnection {
  ServerConnection._(this.server, this._client);

  final ServerProfile server;
  final SSHClient _client;

  bool get isClosed => _client.isClosed;
  Future<void> get done => _client.done;

  /// Connects and signs in.
  ///
  /// [known] is what was accepted for this host before, if anything. A
  /// different key throws [HostKeyChanged]; an unseen one goes to [prompt],
  /// and when accepted, to [onTrust] to be remembered.
  static Future<ServerConnection> open({
    required ServerProfile server,
    required KnownHost? known,
    required HostKeyPrompt prompt,
    required Future<void> Function(String type, String fingerprint) onTrust,
    String? privateKeyPem,
    String? password,
    Duration timeout = const Duration(seconds: 12),
  }) async {
    final identities = <SSHKeyPair>[];
    if (server.auth == AuthMethod.key) {
      if (privateKeyPem == null) throw const MissingCredentials();
      identities.add(loadKeyPair(privateKeyPem));
    } else if (password == null || password.isEmpty) {
      throw const MissingCredentials();
    }

    HostKeyChanged? changed;
    final socket = await SSHSocket.connect(
      server.host,
      server.port,
      timeout: timeout,
    );

    // The handshake has its own deadline, which stops while the user reads a
    // new host key: dartssh2's would run on and drop the connection under
    // someone checking the fingerprint on the server.
    late final SSHClient client;
    Timer? deadline;
    var timedOut = false;
    void arm() {
      deadline?.cancel();
      deadline = Timer(timeout, () {
        timedOut = true;
        client.close();
      });
    }

    client = SSHClient(
      socket,
      username: server.username,
      identities: identities,
      onPasswordRequest: server.auth == AuthMethod.password
          ? () => password
          : null,
      ident: 'ServerDeck_1.0',
      keepAliveInterval: const Duration(seconds: 15),
      authTimeout: timeout,
      onVerifyHostKey: (type, fingerprintBytes) async {
        final fingerprint = utf8.decode(fingerprintBytes);
        if (known != null) {
          if (known.type == type && known.fingerprint == fingerprint) {
            return true;
          }
          changed = HostKeyChanged(known, type, fingerprint);
          return false;
        }
        deadline?.cancel();
        try {
          if (!await prompt(server.hostKeyId, type, fingerprint)) return false;
          await onTrust(type, fingerprint);
          return true;
        } finally {
          arm();
        }
      },
    );
    arm();

    try {
      await client.authenticated;
    } catch (e) {
      client.close();
      if (changed != null) throw changed!;
      if (timedOut) throw TimeoutException('SSH handshake', timeout);
      if (e is SSHHostkeyError) throw const HostKeyRefused();
      rethrow;
    } finally {
      deadline?.cancel();
    }
    return ServerConnection._(server, client);
  }

  /// Runs [command] to the end and collects what it printed.
  Future<ExecResult> run(
    String command, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final result = await _client
        .runWithResult(command, stdout: true, stderr: true)
        .timeout(timeout);
    return ExecResult(
      utf8.decode(result.stdout, allowMalformed: true),
      utf8.decode(result.stderr, allowMalformed: true),
      result.exitCode,
    );
  }

  /// Starts [command] and hands its output over line by line while it runs:
  /// `journalctl -f`, `tail -F`, a deploy script.
  Future<RunningCommand> start(String command) async {
    final session = await _client.execute(command);
    final controller = StreamController<String>();
    var open = 2;
    void closeOne() {
      if (--open == 0) controller.close();
    }

    for (final stream in [session.stdout, session.stderr]) {
      stream
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true))
          .transform(const LineSplitter())
          .listen(
            controller.add,
            onError: controller.addError,
            onDone: closeOne,
          );
    }
    return RunningCommand._(session, controller.stream);
  }

  /// An interactive shell on a pseudo-terminal of the given size.
  Future<SSHSession> shell({required int columns, required int rows}) =>
      _client.shell(
        pty: SSHPtyConfig(type: 'xterm-256color', width: columns, height: rows),
      );

  void close() => _client.close();
}

/// What went wrong, in a word the UI can turn into a sentence.
enum ConnectionProblem {
  unreachable,
  timeout,
  authFailed,
  hostKeyChanged,
  hostKeyRefused,
  missingCredentials,
  disconnected,
  other,
}

ConnectionProblem classify(Object error) => switch (error) {
  HostKeyChanged() => ConnectionProblem.hostKeyChanged,
  HostKeyRefused() => ConnectionProblem.hostKeyRefused,
  MissingCredentials() => ConnectionProblem.missingCredentials,
  SSHAuthFailError() => ConnectionProblem.authFailed,
  // Closed before signing in: the server hung up, or the network did.
  SSHAuthAbortError() => ConnectionProblem.disconnected,
  SSHHandshakeError() => ConnectionProblem.unreachable,
  TimeoutException() => ConnectionProblem.timeout,
  SocketException(:final message) when message.contains('timed out') =>
    ConnectionProblem.timeout,
  SocketException() => ConnectionProblem.unreachable,
  SSHSocketError() => ConnectionProblem.unreachable,
  _ => ConnectionProblem.other,
};
