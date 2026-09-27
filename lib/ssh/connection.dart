import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
  RunningCommand({
    required this.lines,
    required this.done,
    required this._exitCode,
    required this._stop,
  });

  /// stdout and stderr, merged, split into lines.
  final Stream<String> lines;
  final Future<void> done;
  final int? Function() _exitCode;
  final void Function() _stop;

  int? get exitCode => _exitCode();
  void stop() => _stop();
}

/// An interactive shell: bytes out of the terminal, keystrokes into it.
class ShellChannel {
  ShellChannel({
    required this.output,
    required this.done,
    required this._write,
    required this._resize,
    required this._close,
  });

  /// stdout and stderr of the pty, in the order they came.
  final Stream<Uint8List> output;
  final Future<void> done;
  final void Function(Uint8List) _write;
  final void Function(int, int, int, int) _resize;
  final void Function() _close;

  void write(Uint8List data) => _write(data);
  void resize(int columns, int rows, int width, int height) =>
      _resize(columns, rows, width, height);
  void close() => _close();
}

/// What the screens need from a signed-in server. [ServerConnection] is the
/// real one; the demo build has one that makes things up.
abstract interface class Connection {
  bool get isClosed;
  Future<void> get done;

  /// Runs [command] to the end and collects what it printed.
  Future<ExecResult> run(
    String command, {
    Duration timeout = const Duration(seconds: 30),
  });

  /// Starts [command] and hands its output over while it runs.
  Future<RunningCommand> start(String command);

  /// An interactive shell on a pseudo-terminal of the given size.
  Future<ShellChannel> shell({required int columns, required int rows});

  void close();
}

/// Opens a [Connection]; [ServerConnection.open] unless the demo swaps it.
typedef Connector = Future<Connection> Function({
  required ServerProfile server,
  required KnownHost? known,
  required HostKeyPrompt prompt,
  required Future<void> Function(String type, String fingerprint) onTrust,
  String? privateKeyPem,
  String? password,
});

/// Decides about a host key seen for the first time: true accepts it.
typedef HostKeyPrompt = Future<bool> Function(
  String host,
  String type,
  String fingerprint,
);

/// One signed-in SSH connection to one server.
class ServerConnection implements Connection {
  ServerConnection._(this.server, this._client);

  final ServerProfile server;
  final SSHClient _client;

  @override
  bool get isClosed => _client.isClosed;
  @override
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

  @override
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
  /// `journalctl -f`, `tail -F`, a deploy script. [RunningCommand.stop]
  /// ends it on the server too, see [stoppable].
  @override
  Future<RunningCommand> start(String command) async {
    final session = await _client.execute(stoppable(command));
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
    return RunningCommand(
      lines: controller.stream,
      done: session.done,
      exitCode: () => session.exitCode,
      stop: () {
        try {
          session.kill(SSHSignal.INT);
        } catch (_) {}
        session.close();
      },
    );
  }

  @override
  Future<ShellChannel> shell({required int columns, required int rows}) async {
    final session = await _client.shell(
      pty: SSHPtyConfig(type: 'xterm-256color', width: columns, height: rows),
    );
    final output = StreamController<Uint8List>();
    var open = 2;
    for (final stream in [session.stdout, session.stderr]) {
      stream.listen(
        output.add,
        onDone: () {
          if (--open == 0) output.close();
        },
      );
    }
    return ShellChannel(
      output: output.stream,
      done: session.done,
      write: session.write,
      resize: session.resizeTerminal,
      close: session.close,
    );
  }

  @override
  void close() => _client.close();
}

/// Wraps [command] so that it dies when the channel closes.
///
/// Without a terminal, sshd neither passes on signals nor hangs up a command
/// whose channel was closed: a `journalctl -f` would run on until it next
/// wrote to the broken pipe, which for a quiet log is never. So the command
/// runs in the background while `cat` waits on the channel's input; when
/// the phone closes the channel that input ends, and the command is killed.
/// When the command ends on its own, the watcher goes and its status is
/// passed on. A background job's input is /dev/null in a script, hence the
/// channel's input kept on descriptor 3 for `cat`.
String stoppable(String command) {
  const script =
      'exec 3<&0; '
      '(%s) </dev/null & p=\$!; '
      '(cat <&3 >/dev/null; kill \$p 2>/dev/null) & w=\$!; '
      'wait \$p; s=\$?; kill \$w 2>/dev/null; exit \$s';
  final inner = script.replaceFirst('%s', command);
  return "sh -c '${inner.replaceAll("'", r"'\''")}'";
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
