import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:serverdeck/ssh/connection.dart';

/// Runs [command] the way sshd would: through a shell, with a pipe for input.
Future<Process> run(String command) =>
    Process.start('sh', ['-c', stoppable(command)]);

void main() {
  test('a follower dies when its input closes', () async {
    final p = await run('sleep 30');
    final watch = Stopwatch()..start();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await p.stdin.close();
    final code = await p.exitCode.timeout(const Duration(seconds: 5));
    expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
    expect(code, isNot(0));
  });

  test('a command that ends by itself keeps its output and status', () async {
    final p = await run("echo 'it''s here'; echo oops >&2; exit 3");
    final out = await p.stdout.transform(utf8.decoder).join();
    final err = await p.stderr.transform(utf8.decoder).join();
    expect(await p.exitCode.timeout(const Duration(seconds: 5)), 3);
    expect(out.trim(), 'its here');
    expect(err.trim(), 'oops');
  });
}
