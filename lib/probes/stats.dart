/// Reading a Linux server's vital signs from `/proc` and `df`, in one round
/// trip, with nothing installed on the server.
library;

const _separator = '@@SD@@';

/// The one command behind every stats refresh. Its sections are split by a
/// marker line, in the order [parseStats] expects them.
const statsCommand =
    'S=$_separator; '
    'cat /proc/loadavg; echo \$S; '
    'cat /proc/uptime; echo \$S; '
    'grep "^cpu " /proc/stat; echo \$S; '
    'cat /proc/meminfo; echo \$S; '
    'df -Pk -x tmpfs -x devtmpfs -x squashfs -x overlay -x efivarfs 2>/dev/null; echo \$S; '
    'hostname; echo \$S; '
    '(. /etc/os-release 2>/dev/null; echo "\$PRETTY_NAME"); echo \$S; '
    'nproc 2>/dev/null; echo \$S; '
    'uname -r; echo \$S; '
    'cat /proc/net/dev';

class Disk {
  const Disk({
    required this.device,
    required this.mount,
    required this.totalKb,
    required this.usedKb,
    required this.availableKb,
  });

  final String device;
  final String mount;
  final int totalKb;
  final int usedKb;
  final int availableKb;

  /// As `df` counts it: used over used + available, so the blocks reserved
  /// for root do not make a full disk look like it has room.
  double get usage =>
      usedKb + availableKb == 0 ? 0 : usedKb / (usedKb + availableKb);
}

/// One reading of the server. CPU and network figures are counters since
/// boot; [StatsSample.cpuUsageSince] and [StatsSample.networkRateSince] turn
/// two readings into rates.
class StatsSample {
  const StatsSample({
    required this.taken,
    required this.load1,
    required this.load5,
    required this.load15,
    required this.uptime,
    required this.cpuTotal,
    required this.cpuIdle,
    required this.memTotalKb,
    required this.memAvailableKb,
    required this.swapTotalKb,
    required this.swapFreeKb,
    required this.disks,
    required this.hostname,
    required this.os,
    required this.cores,
    required this.kernel,
    required this.netRxBytes,
    required this.netTxBytes,
  });

  final DateTime taken;
  final double load1;
  final double load5;
  final double load15;
  final Duration uptime;

  /// Jiffies spent in every state, and in idle + iowait, since boot.
  final int cpuTotal;
  final int cpuIdle;

  final int memTotalKb;
  final int memAvailableKb;
  final int swapTotalKb;
  final int swapFreeKb;
  final List<Disk> disks;
  final String hostname;
  final String os;
  final int cores;
  final String kernel;

  /// Bytes through every interface but loopback, since boot.
  final int netRxBytes;
  final int netTxBytes;

  int get memUsedKb => memTotalKb - memAvailableKb;
  double get memUsage => memTotalKb == 0 ? 0 : memUsedKb / memTotalKb;
  int get swapUsedKb => swapTotalKb - swapFreeKb;
  double get swapUsage => swapTotalKb == 0 ? 0 : swapUsedKb / swapTotalKb;

  /// The disk mounted at `/`, or the first one.
  Disk? get rootDisk =>
      disks.where((d) => d.mount == '/').firstOrNull ?? disks.firstOrNull;

  /// Busy share of the CPU between [earlier] and this reading, 0..1. The
  /// share since boot when there is no earlier reading.
  double cpuUsageSince(StatsSample? earlier) {
    final total = cpuTotal - (earlier?.cpuTotal ?? 0);
    final idle = cpuIdle - (earlier?.cpuIdle ?? 0);
    if (total <= 0) return 0;
    return ((total - idle) / total).clamp(0.0, 1.0);
  }

  /// Bytes per second in and out between [earlier] and this reading.
  (double rx, double tx) networkRateSince(StatsSample earlier) {
    final seconds = taken.difference(earlier.taken).inMilliseconds / 1000;
    if (seconds <= 0) return (0, 0);
    // A counter that went backwards means a reboot or a wrap: no rate.
    final rx = netRxBytes - earlier.netRxBytes;
    final tx = netTxBytes - earlier.netTxBytes;
    return (rx < 0 ? 0 : rx / seconds, tx < 0 ? 0 : tx / seconds);
  }
}

/// Splits [output] of [statsCommand] into a [StatsSample].
///
/// Throws [FormatException] when a section the rest depends on is missing,
/// e.g. on a server without `/proc` (not Linux).
StatsSample parseStats(String output, {DateTime? taken}) {
  final sections = output
      .replaceAll('\r\n', '\n')
      .split('$_separator\n')
      .map((s) => s.trim())
      .toList();
  if (sections.length < 10) {
    throw FormatException('expected 10 sections, got ${sections.length}');
  }
  String section(int i) => sections[i];

  final load = section(0).split(RegExp(r'\s+'));
  final uptimeSeconds = double.tryParse(section(1).split(' ').first) ?? 0;

  final cpu = section(2)
      .split(RegExp(r'\s+'))
      .skip(1)
      .map((v) => int.tryParse(v) ?? 0)
      .toList();
  if (cpu.length < 4) throw const FormatException('no cpu line');
  // user nice system idle iowait irq softirq steal guest guest_nice. Guest
  // time is already counted in user and nice, so it is left out of the total.
  final counted = cpu.take(8).toList();
  final total = counted.fold<int>(0, (a, b) => a + b);
  final idle = cpu[3] + (cpu.length > 4 ? cpu[4] : 0);

  final mem = <String, int>{};
  for (final line in section(3).split('\n')) {
    final match = RegExp(r'^(\S+):\s+(\d+)').firstMatch(line);
    if (match != null) mem[match.group(1)!] = int.parse(match.group(2)!);
  }
  final memTotal = mem['MemTotal'] ?? 0;
  // Kernels before 3.14 have no MemAvailable; free + buffers + cache is the
  // old estimate.
  final memAvailable =
      mem['MemAvailable'] ??
      (mem['MemFree'] ?? 0) + (mem['Buffers'] ?? 0) + (mem['Cached'] ?? 0);

  final disks = <Disk>[];
  for (final line in section(4).split('\n').skip(1)) {
    final f = line.trim().split(RegExp(r'\s+'));
    if (f.length < 6) continue;
    final totalKb = int.tryParse(f[1]);
    final used = int.tryParse(f[2]);
    final available = int.tryParse(f[3]);
    if (totalKb == null || used == null || available == null) continue;
    disks.add(
      Disk(
        device: f[0],
        // A mount point with spaces spreads over the remaining fields.
        mount: f.sublist(5).join(' '),
        totalKb: totalKb,
        usedKb: used,
        availableKb: available,
      ),
    );
  }

  var rx = 0;
  var tx = 0;
  for (final line in section(9).split('\n')) {
    final colon = line.indexOf(':');
    if (colon < 0) continue;
    final name = line.substring(0, colon).trim();
    if (name == 'lo') continue;
    final f = line.substring(colon + 1).trim().split(RegExp(r'\s+'));
    if (f.length < 9) continue;
    rx += int.tryParse(f[0]) ?? 0;
    tx += int.tryParse(f[8]) ?? 0;
  }

  return StatsSample(
    taken: taken ?? DateTime.now(),
    load1: double.tryParse(load.elementAtOrNull(0) ?? '') ?? 0,
    load5: double.tryParse(load.elementAtOrNull(1) ?? '') ?? 0,
    load15: double.tryParse(load.elementAtOrNull(2) ?? '') ?? 0,
    uptime: Duration(seconds: uptimeSeconds.round()),
    cpuTotal: total,
    cpuIdle: idle,
    memTotalKb: memTotal,
    memAvailableKb: memAvailable,
    swapTotalKb: mem['SwapTotal'] ?? 0,
    swapFreeKb: mem['SwapFree'] ?? 0,
    disks: disks,
    hostname: section(5),
    os: section(6),
    cores: int.tryParse(section(7)) ?? 1,
    kernel: section(8),
    netRxBytes: rx,
    netTxBytes: tx,
  );
}

/// 1536 KiB as `1.5 GB`, the way people read disk and memory sizes.
String formatKb(int kb) => formatBytes(kb * 1024);

/// `0.9 / 7.8 GB`: both in the unit of the larger, which fits under a gauge.
String formatKbPair(int usedKb, int totalKb) {
  final total = formatKb(totalKb);
  final unit = total.split(' ').last;
  const steps = {'B': 0, 'KB': 1, 'MB': 2, 'GB': 3, 'TB': 4, 'PB': 5};
  final used = usedKb * 1024 / _pow1024(steps[unit] ?? 0);
  final text = used >= 100 || used == used.roundToDouble()
      ? used.toStringAsFixed(0)
      : used.toStringAsFixed(1);
  return '$text / $total';
}

double _pow1024(int n) {
  var v = 1.0;
  for (var i = 0; i < n; i++) {
    v *= 1024;
  }
  return v;
}

String formatBytes(num bytes, {int decimals = 1}) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final text = unit == 0 || value >= 100
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(decimals);
  return '$text ${units[unit]}';
}
