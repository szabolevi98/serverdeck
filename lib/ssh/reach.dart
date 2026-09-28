import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// What a bare TCP knock on the SSH port found, without signing in.
class Reachability {
  const Reachability.up(this.latency, this.banner) : error = null;
  const Reachability.down(this.error) : latency = null, banner = null;

  /// Time to open the TCP connection.
  final Duration? latency;

  /// The server's identification line, e.g. `SSH-2.0-OpenSSH_9.6p1 Ubuntu-3`.
  final String? banner;
  final String? error;

  bool get isUp => latency != null;
}

/// Opens a TCP connection to [host]:[port], times it, reads the SSH banner
/// and hangs up. Cheap enough to run for every server on the list.
Future<Reachability> knock(
  String host,
  int port, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final watch = Stopwatch()..start();
  Socket? socket;
  try {
    socket = await Socket.connect(host, port, timeout: timeout);
    final latency = watch.elapsed;
    String? banner;
    try {
      banner = await utf8.decoder
          .bind(socket)
          .transform(const LineSplitter())
          .firstWhere((line) => line.startsWith('SSH-'))
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      // Up, but not talking SSH, or slow to: the latency still stands.
    }
    return Reachability.up(latency, banner?.trim());
  } on SocketException catch (e) {
    return Reachability.down(e.osError?.message ?? e.message);
  } on TimeoutException {
    return const Reachability.down('timeout');
  } catch (e) {
    return Reachability.down(e.toString());
  } finally {
    socket?.destroy();
  }
}

/// `SSH-2.0-OpenSSH_9.6p1 Ubuntu-3ubuntu13` becomes `OpenSSH 9.6p1 Ubuntu`.
String? describeBanner(String? banner) {
  if (banner == null) return null;
  final match = RegExp(r'^SSH-[\d.]+-(\S+)(?:\s+(\S+))?').firstMatch(banner);
  if (match == null) return null;
  final software = match.group(1)!.replaceFirst('_', ' ');
  final comment = match.group(2);
  if (comment == null) return software;
  final distro = RegExp(r'^[A-Za-z]+').firstMatch(comment)?.group(0);
  return distro == null ? software : '$software $distro';
}

/// Addresses that are up whenever the internet is: Cloudflare, Google and
/// Quad9 DNS, by address so that no DNS lookup is needed first.
const _landmarks = [('1.1.1.1', 443), ('8.8.8.8', 443), ('9.9.9.9', 443)];

/// Whether the phone can reach the internet at all: opens a TCP connection
/// to any of three public resolvers and closes it, sending nothing.
Future<bool> internetReachable({
  Duration timeout = const Duration(seconds: 5),
}) async {
  final attempts = [
    for (final (host, port) in _landmarks)
      Socket.connect(host, port, timeout: timeout).then((socket) {
        socket.destroy();
        return true;
      }, onError: (_) => false),
  ];
  final done = Completer<bool>();
  var left = attempts.length;
  for (final a in attempts) {
    a.then((ok) {
      if (ok && !done.isCompleted) done.complete(true);
      if (--left == 0 && !done.isCompleted) done.complete(false);
    });
  }
  return done.future;
}
