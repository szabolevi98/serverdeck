import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:serverdeck/probes/stats.dart';

void main() {
  final ubuntu = File('test/fixtures/stats_ubuntu.txt').readAsStringSync();

  test('reads an Ubuntu 24.04 server', () {
    final s = parseStats(ubuntu);
    expect(s.hostname, 'web-1');
    expect(s.os, 'Ubuntu 24.04.4 LTS');
    expect(s.kernel, '6.8.0-137-generic');
    expect(s.cores, 4);
    expect(s.load1, 0);
    expect(s.uptime.inDays, 47);
    expect(s.cpuTotal, 1617788317);
    expect(s.cpuIdle, 1609405921 + 978890);
    expect(s.memTotalKb, 8131776);
    expect(s.memAvailableKb, 7177672);
    expect(s.memUsage, closeTo(0.117, 0.001));
    expect(s.swapTotalKb, 8388604);
    expect(s.swapUsage, 0);
    expect(s.disks.map((d) => d.mount), ['/', '/boot', '/boot/efi']);
    expect(s.rootDisk!.usage, closeTo(0.234, 0.001));
    // Loopback is left out.
    expect(s.netRxBytes, 21963162506);
    expect(s.netTxBytes, 90900737532);
  });

  test('works with Windows line endings too', () {
    expect(parseStats(ubuntu.replaceAll('\n', '\r\n')).cores, 4);
  });

  test('CPU usage and network rates come from two readings', () {
    final t0 = DateTime(2026, 9, 27, 12);
    final a = parseStats(ubuntu, taken: t0);
    final later = ubuntu
        .replaceFirst(
          'cpu  3898486 97019 2799067 1609405921 978890 0 608934 0 0 0',
          // 300 more jiffies: 60 user, 15 system, 225 idle.
          'cpu  3898546 97019 2799082 1609406146 978890 0 608934 0 0 0',
        )
        .replaceFirst('eth0: 21963162506', 'eth0: 21963172506');
    final b = parseStats(later, taken: t0.add(const Duration(seconds: 2)));
    expect(b.cpuUsageSince(a), closeTo(0.25, 0.0001));
    final (rx, tx) = b.networkRateSince(a);
    expect(rx, 5000);
    expect(tx, 0);
    // Counters that went back (a reboot) give no rate rather than a negative.
    final (rx2, _) = a.networkRateSince(b);
    expect(rx2, 0);
  });

  test('a mount point with a space stays whole', () {
    final odd = ubuntu.replaceFirst(
      '/dev/sda15          106832     6250    100582       6% /boot/efi',
      '/dev/sdb1          106832     6250    100582       6% /mnt/My Disk',
    );
    expect(parseStats(odd).disks.last.mount, '/mnt/My Disk');
  });

  test('output that is not the probe is refused', () {
    expect(
      () => parseStats('sh: 1: cat: not found'),
      throwsA(isA<FormatException>()),
    );
  });

  test('sizes read like people say them', () {
    expect(formatKb(8131776), '7.8 GB');
    expect(formatKb(100476656), '95.8 GB');
    expect(formatBytes(512), '512 B');
    expect(formatBytes(1536), '1.5 KB');
    expect(formatBytes(150 * 1024 * 1024), '150 MB');
    expect(formatKbPair(946176, 8131776), '0.9 / 7.8 GB');
    expect(formatKbPair(23549848, 100476656), '22.5 / 95.8 GB');
    expect(formatKbPair(0, 8388604), '0 / 8.0 GB');
  });
}
