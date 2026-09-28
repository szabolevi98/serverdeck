/// The demo build: invented servers that answer like real ones, for
/// screenshots and for trying the app without a server. Built with
/// `--dart-define=SERVERDECK_DEMO=true`; nothing here touches the network.
///
/// Every address is from the ranges RFC 5737 sets aside for documentation.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/misc.dart' show Override;

import '../data/app_data.dart';
import '../data/models.dart';
import '../data/storage.dart';
import '../monitor/checker.dart';
import '../monitor/monitor_log.dart';
import '../monitor/monitor_providers.dart';
import '../probes/services.dart';
import '../probes/stats.dart';
import '../ssh/connection.dart';
import '../ssh/keys.dart';
import '../ssh/reach.dart';
import '../ssh/session.dart';
import '../ui/servers_screen.dart';

const demoMode = bool.fromEnvironment('SERVERDECK_DEMO');

List<Override> demoOverrides() {
  final key = generateEd25519('pixel-9');
  final secrets = MemorySecretStore()
    ..values[Secrets.privateKey('k1')] = key.privatePem;
  final added = DateTime(2026, 9, 1);
  KnownHost known(String host) => KnownHost(
    host: host,
    type: 'ssh-ed25519',
    fingerprint:
        'SHA256:${base64.encode(utf8.encode(host.padRight(32, '.'))).substring(0, 43)}',
    added: added,
  );

  final data = AppData(
    servers: const [
      ServerProfile(
        id: 'web-1',
        name: 'web-1',
        host: '203.0.113.10',
        username: 'deploy',
        keyId: 'k1',
        monitor: MonitorConfig(enabled: true, minutes: 30),
      ),
      ServerProfile(
        id: 'db-1',
        name: 'db-1',
        host: '203.0.113.21',
        username: 'root',
        keyId: 'k1',
        monitor: MonitorConfig(enabled: true, minutes: 15),
      ),
      ServerProfile(
        id: 'staging',
        name: 'staging',
        host: '198.51.100.7',
        port: 2222,
        username: 'ubuntu',
        keyId: 'k1',
      ),
      ServerProfile(
        id: 'backup',
        name: 'backup',
        host: '192.0.2.44',
        username: 'root',
        keyId: 'k1',
        monitor: MonitorConfig(
          enabled: true,
          minutes: 60,
          mode: MonitorMode.port,
        ),
      ),
    ],
    keys: [
      SshKey(
        id: 'k1',
        name: 'Pixel 9',
        type: key.type,
        publicKey: key.publicKey,
        fingerprint: key.fingerprint,
        created: added,
      ),
    ],
    knownHosts: [
      known('203.0.113.10'),
      known('203.0.113.21'),
      known('[198.51.100.7]:2222'),
    ],
    commands: const [
      SavedCommand(
        id: 'c1',
        name: 'Deploy',
        command: 'cd /srv/app && git pull --ff-only && systemctl reload nginx',
        serverId: 'web-1',
      ),
      SavedCommand(
        id: 'c2',
        name: 'Disk usage',
        command: 'df -h -x tmpfs -x devtmpfs -x squashfs -x overlay',
        confirm: false,
      ),
      SavedCommand(
        id: 'c3',
        name: 'Pending updates',
        command: 'apt list --upgradable 2>/dev/null | tail -n +2',
        confirm: false,
      ),
    ],
    logSources: const [
      LogSource(
        id: 'l1',
        serverId: 'web-1',
        name: 'nginx',
        kind: LogKind.unit,
        target: 'nginx.service',
      ),
      LogSource(
        id: 'l2',
        serverId: 'web-1',
        name: 'error.log',
        kind: LogKind.file,
        target: '/var/log/nginx/error.log',
      ),
    ],
  );

  final monitorFile = MemoryMonitorLogFile(_demoHistory(DateTime.now()));
  return [
    dataFileProvider.overrideWithValue(MemoryDataFile(data)),
    monitorLogFileProvider.overrideWithValue(monitorFile),
    monitorSchedulerProvider.overrideWithValue((_) async {}),
    internetProbeProvider.overrideWithValue(() async => true),
    monitorRunnerProvider.overrideWithValue(({bool force = false}) async {
      final (log, events) = await runChecks(
        servers: data.servers,
        log: await monitorFile.load(),
        force: force,
        retryAfter: Duration.zero,
        check: (s) async {
          await Future<void>.delayed(const Duration(milliseconds: 600));
          return s.id == 'backup'
              ? const CheckOutcome.down('timeout')
              : CheckOutcome.up(
                  Duration(milliseconds: s.id == 'db-1' ? 212 : 184),
                );
        },
      );
      await monitorFile.save(log);
      return (log, events);
    }),
    secretStoreProvider.overrideWithValue(secrets),
    knockProvider.overrideWithValue(_knock),
    connectorProvider.overrideWithValue(_connect),
  ];
}

/// Thirty days of checks: web-1 with one 45-minute outage three days ago,
/// db-1 with a short blip, backup down for the last two hours.
MonitorLog _demoHistory(DateTime now) {
  var log = const MonitorLog();
  for (final (id, every) in [('web-1', 30), ('db-1', 15), ('backup', 60)]) {
    for (
      var t = now.subtract(const Duration(days: 30));
      t.isBefore(now);
      t = t.add(Duration(minutes: every))
    ) {
      final ago = now.difference(t);
      final down = switch (id) {
        'web-1' =>
          ago > const Duration(days: 3) &&
              ago < const Duration(days: 3, minutes: 45),
        'db-1' =>
          ago > const Duration(days: 9) &&
              ago < const Duration(days: 9, minutes: 16),
        _ => ago < const Duration(hours: 2),
      };
      log = log.record(
        id,
        CheckRecord(
          at: t,
          up: !down,
          latencyMs: down ? null : 150 + (t.minute * 7) % 90,
          problem: down ? (id == 'db-1' ? 'unreachable' : 'timeout') : null,
        ),
      );
    }
  }
  return log;
}

Future<Reachability> _knock(String host, int port) async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  if (host == '192.0.2.44') return const Reachability.down('timeout');
  final latency = 18 + host.codeUnits.fold<int>(0, (a, b) => a + b) % 40;
  return Reachability.up(
    Duration(milliseconds: latency),
    host.startsWith('198')
        ? 'SSH-2.0-OpenSSH_9.2p1 Debian-2+deb12u3'
        : 'SSH-2.0-OpenSSH_9.6p1 Ubuntu-3ubuntu13.5',
  );
}

Future<Connection> _connect({
  required ServerProfile server,
  required KnownHost? known,
  required HostKeyPrompt prompt,
  required Future<void> Function(String type, String fingerprint) onTrust,
  String? privateKeyPem,
  String? password,
}) async {
  await Future<void>.delayed(const Duration(milliseconds: 700));
  if (server.host == '192.0.2.44') {
    throw TimeoutException('demo', const Duration(seconds: 12));
  }
  return DemoConnection(server);
}

/// A server that makes up plausible answers.
class DemoConnection implements Connection {
  DemoConnection(this.server);
  final ServerProfile server;
  final _done = Completer<void>();
  final _random = Random(7);
  final _started = DateTime.now();

  // Counters since "boot", advanced on every stats reading.
  int _cpuTotal = 180000000;
  int _cpuIdle = 150000000;
  int _rx = 812345678901;
  int _tx = 234567890123;
  DateTime _last = DateTime.now();

  bool get _db => server.id == 'db-1';

  @override
  bool get isClosed => _done.isCompleted;

  @override
  Future<void> get done => _done.future;

  @override
  void close() {
    if (!_done.isCompleted) _done.complete();
  }

  @override
  Future<ExecResult> run(
    String command, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (command == statsCommand) return ExecResult(_stats(), '', 0);
    if (command == servicesCommand) return ExecResult(_services(), '', 0);
    if (command == dockerCommand) return ExecResult(_docker(), '', 0);
    if (command.contains('systemctl status')) {
      return ExecResult(_status(command), '', 0);
    }
    if (command.contains('docker logs')) {
      return ExecResult(_appLog(12).join('\n'), '', 0);
    }
    if (command.startsWith('df ')) return ExecResult(_df, '', 0);
    if (command.contains('apt list')) return ExecResult(_updates, '', 0);
    if (command.contains('git pull')) return ExecResult(_deploy, '', 0);
    return ExecResult('', '', 0);
  }

  @override
  Future<RunningCommand> start(String command) async {
    final controller = StreamController<String>();
    final done = Completer<void>();
    Timer? timer;
    int? code;
    void finish(int c) {
      code = c;
      timer?.cancel();
      if (!controller.isClosed) controller.close();
      if (!done.isCompleted) done.complete();
    }

    if (command.contains('journalctl') || command.contains('tail -n')) {
      final file = command.contains('error.log');
      final lines = file ? _errorLog(30) : _journal(60);
      for (final l in lines) {
        controller.add(l);
      }
      timer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
        controller.add(file ? _errorLog(1).single : _journal(1).single);
      });
    } else {
      final result = await run(command);
      final lines = const LineSplitter().convert(result.stdout);
      var i = 0;
      timer = Timer.periodic(const Duration(milliseconds: 180), (t) {
        if (i < lines.length) {
          controller.add(lines[i++]);
        } else {
          finish(0);
        }
      });
    }
    return RunningCommand(
      lines: controller.stream,
      done: done.future,
      exitCode: () => code,
      stop: () => finish(130),
    );
  }

  @override
  Future<ShellChannel> shell({required int columns, required int rows}) async {
    final output = StreamController<Uint8List>();
    final done = Completer<void>();
    final prompt =
        '\x1b[1;32m${server.username}@${server.name}\x1b[0m:\x1b[1;34m~\x1b[0m\$ ';
    var line = '';
    void out(String s) => output.add(Uint8List.fromList(utf8.encode(s)));

    out(
      'Ubuntu 24.04.1 LTS · 6.8.0-45-generic\r\n\r\n'
      '  load 0.42 · 183 processes · 1 user\r\n'
      '  disk 43% of 95.8 GB · memory 58%\r\n\r\n'
      '$prompt',
    );
    return ShellChannel(
      output: output.stream,
      done: done.future,
      write: (bytes) {
        for (final ch in utf8.decode(bytes).split('')) {
          if (ch == '\r' || ch == '\n') {
            out('\r\n${_answer(line.trim())}$prompt');
            line = '';
          } else if (ch == '\x7f') {
            if (line.isNotEmpty) {
              line = line.substring(0, line.length - 1);
              out('\b \b');
            }
          } else if (ch == '\x03') {
            out('^C\r\n$prompt');
            line = '';
          } else if (ch.codeUnitAt(0) >= 0x20) {
            line += ch;
            out(ch);
          }
        }
      },
      resize: (_, _, _, _) {},
      close: () {
        if (!done.isCompleted) done.complete();
        output.close();
      },
    );
  }

  String _answer(String command) {
    if (command.isEmpty) return '';
    final text = switch (command.split(' ').first) {
      'uptime' =>
        ' ${_clock()} up 23 days,  4:12,  1 user,  load average: 0.42, 0.37, 0.31',
      'ls' =>
        '\x1b[1;34mapp\x1b[0m  \x1b[1;34mbackups\x1b[0m  deploy.sh  README.md',
      'whoami' => server.username,
      'hostname' => server.name,
      'df' => _df,
      'systemctl' =>
        '● nginx.service - A high performance web server\n'
            '     Active: active (running) since Thu 2026-09-04 09:12:44 UTC; 3 weeks ago',
      'git' => 'Already up to date.',
      _ => '${command.split(' ').first}: demo shell',
    };
    return '${text.replaceAll('\n', '\r\n')}\r\n';
  }

  String _clock() {
    final t = DateTime.now().toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }

  String _stats() {
    final now = DateTime.now();
    final seconds = max(0.5, now.difference(_last).inMilliseconds / 1000);
    _last = now;
    final t = now.difference(_started).inMilliseconds / 1000;
    final busy =
        (_db ? 0.46 : 0.24) + 0.12 * sin(t / 6) + 0.06 * _random.nextDouble();
    final jiffies = (seconds * 100 * 4).round();
    _cpuTotal += jiffies;
    _cpuIdle += (jiffies * (1 - busy)).round();
    _rx += ((1.3 + 0.8 * sin(t / 4).abs()) * 1024 * 1024 * seconds).round();
    _tx += ((0.35 + 0.3 * _random.nextDouble()) * 1024 * 1024 * seconds)
        .round();
    final memAvailable = _db ? 2412000 : 3380000 + _random.nextInt(60000);

    return [
      '0.42 0.37 0.31 2/231 48211',
      '${23 * 86400 + 4 * 3600 + 12 * 60}.54 7812345.20',
      'cpu  ${_cpuTotal - _cpuIdle} 0 0 $_cpuIdle 0 0 0 0 0 0',
      'MemTotal:        8131776 kB\n'
          'MemFree:         ${memAvailable - 400000} kB\n'
          'MemAvailable:    $memAvailable kB\n'
          'SwapTotal:       2097148 kB\n'
          'SwapFree:        1893212 kB',
      'Filesystem     1024-blocks     Used Available Capacity Mounted on\n'
          '/dev/vda1        100476656 41392112  58984120      42% /\n'
          '/dev/vda15          106832     6250    100582       6% /boot/efi\n'
          '/dev/vdb1        514937808 ${_db ? 402337112 : 131337112} ${_db ? 86400000 : 357400000}      ${_db ? 83 : 27}% /srv/data',
      server.name,
      server.port == 2222
          ? 'Debian GNU/Linux 12 (bookworm)'
          : 'Ubuntu 24.04.1 LTS',
      '4',
      '6.8.0-45-generic',
      'Inter-|   Receive\n face |bytes\n'
          '    lo: 1000 10 0 0 0 0 0 0 1000 10 0 0 0 0 0 0\n'
          '  eth0: $_rx 1 0 0 0 0 0 0 $_tx 1 0 0 0 0 0 0',
    ].join('\n@@SD@@\n');
  }

  String _services() {
    const units = [
      ('containerd', 'active', 'running', 'containerd container runtime'),
      (
        'cron',
        'active',
        'running',
        'Regular background program processing daemon',
      ),
      ('docker', 'active', 'running', 'Docker Application Container Engine'),
      ('fail2ban', 'active', 'running', 'Fail2Ban Service'),
      (
        'nginx',
        'active',
        'running',
        'A high performance web server and a reverse proxy server',
      ),
      ('postgresql@16-main', 'active', 'running', 'PostgreSQL Cluster 16-main'),
      ('redis-server', 'active', 'running', 'Advanced key-value store'),
      ('ssh', 'active', 'running', 'OpenBSD Secure Shell server'),
      ('systemd-journald', 'active', 'running', 'Journal Service'),
      ('ufw', 'active', 'exited', 'Uncomplicated firewall'),
      ('backup-sync', 'failed', 'failed', 'Nightly off-site backup'),
      ('apt-daily', 'inactive', 'dead', 'Daily apt download activities'),
      ('certbot', 'inactive', 'dead', 'Certbot'),
    ];
    return [
      for (final (name, active, sub, description) in units)
        '$name.service loaded $active $sub $description',
      '@@SD@@',
      for (final (name, _, _, _) in units)
        '$name.service ${name == 'apt-daily' ? 'static' : 'enabled'} enabled',
    ].join('\n');
  }

  String _docker() {
    if (server.id != 'web-1') return 'NODOCKER\n';
    String c(
      String id,
      String name,
      String image,
      String state,
      String status,
      String ports,
    ) => jsonEncode({
      'ID': id,
      'Names': name,
      'Image': image,
      'State': state,
      'Status': status,
      'Ports': ports,
    });
    return [
      'DOCKER',
      c(
        'a1b2c3d4e5f6',
        'app',
        'ghcr.io/example/app:2.4.1',
        'running',
        'Up 3 days (healthy)',
        '127.0.0.1:8080->8080/tcp',
      ),
      c(
        'b2c3d4e5f6a1',
        'worker',
        'ghcr.io/example/app:2.4.1',
        'running',
        'Up 3 days',
        '',
      ),
      c(
        'c3d4e5f6a1b2',
        'redis',
        'redis:7.4-alpine',
        'running',
        'Up 12 days',
        '6379/tcp',
      ),
      c(
        'd4e5f6a1b2c3',
        'migrate',
        'ghcr.io/example/app:2.4.1',
        'exited',
        'Exited (0) 3 days ago',
        '',
      ),
    ].join('\n');
  }

  String _status(String command) {
    final unit = RegExp(r"'([^']+)'").firstMatch(command)?.group(1) ?? 'x';
    final failed = unit.startsWith('backup-sync');
    return [
      '● $unit - ${unit.replaceAll('.service', '')}',
      '     Loaded: loaded (/usr/lib/systemd/system/$unit; enabled; preset: enabled)',
      failed
          ? '     Active: failed (Result: exit-code) since Sat 2026-09-27 03:00:14 UTC; 15h ago'
          : '     Active: active (running) since Thu 2026-09-04 09:12:44 UTC; 3 weeks 2 days ago',
      '   Main PID: 1123 (${unit.split('.').first})',
      '      Tasks: 5 (limit: 9483)',
      '     Memory: 42.6M (peak: 118.2M)',
      '        CPU: 3min 12.402s',
      '',
      if (failed) ...[
        'Sep 27 03:00:01 ${server.name} systemd[1]: Starting backup-sync.service - Nightly off-site backup...',
        'Sep 27 03:00:14 ${server.name} backup-sync[88211]: rsync: [sender] write error: Broken pipe (32)',
        'Sep 27 03:00:14 ${server.name} backup-sync[88211]: rsync error: error in socket IO (code 10)',
        'Sep 27 03:00:14 ${server.name} systemd[1]: backup-sync.service: Main process exited, code=exited, status=10/n/a',
        'Sep 27 03:00:14 ${server.name} systemd[1]: backup-sync.service: Failed with result \'exit-code\'.',
      ] else ...[
        'Sep 04 09:12:44 ${server.name} systemd[1]: Starting $unit...',
        'Sep 04 09:12:44 ${server.name} systemd[1]: Started $unit.',
        'Sep 27 00:00:02 ${server.name} systemd[1]: Reloading $unit...',
        'Sep 27 00:00:02 ${server.name} systemd[1]: Reloaded $unit.',
      ],
    ].join('\n');
  }

  List<String> _journal(int count) {
    const messages = [
      'nginx[1123]: 203.0.113.77 - - "GET /api/orders HTTP/2.0" 200 1843',
      'nginx[1123]: 198.51.100.23 - - "POST /api/login HTTP/2.0" 200 512',
      'app[2211]: order 48213 paid, sending receipt',
      'CRON[48102]: (deploy) CMD (php /srv/app/bin/queue.php)',
      'app[2211]: warning: slow query 1.8 s on orders_by_customer',
      'sshd[48190]: Accepted publickey for deploy from 192.0.2.10 port 50211 ssh2',
      'systemd[1]: Started session-3121.scope - Session 3121 of User deploy.',
      'app[2211]: cache warmed in 412 ms',
      'kernel: [UFW BLOCK] IN=eth0 SRC=198.51.100.99 DPT=3389',
      'app[2211]: error: payment provider timed out, retrying',
      'redis[901]: Background saving started by pid 48222',
      'fail2ban.actions[811]: NOTICE [sshd] Ban 198.51.100.99',
    ];
    final now = DateTime.now();
    return [
      for (var i = 0; i < count; i++)
        '${_iso(now.subtract(Duration(seconds: (count - i) * 7)))} ${server.name} '
            '${messages[_random.nextInt(messages.length)]}',
    ];
  }

  List<String> _errorLog(int count) {
    const messages = [
      '[warn] 1123#1123: *8812 an upstream response is buffered to a temporary file',
      '[error] 1123#1123: *8813 upstream timed out (110: Connection timed out) while reading response header from upstream',
      '[notice] 1123#1123: signal process started',
      '[warn] 1123#1123: *8820 client sent invalid "Host" header while reading client request headers',
    ];
    final now = DateTime.now().toUtc();
    return [
      for (var i = 0; i < count; i++)
        '${now.year}/09/27 ${_clock()} ${messages[_random.nextInt(messages.length)]}',
    ];
  }

  List<String> _appLog(int count) => [
    for (var i = 0; i < count; i++)
      '2026-09-27T18:${(10 + i).toString().padLeft(2, '0')}:04Z INFO request handled in ${20 + _random.nextInt(60)} ms',
  ];

  String _iso(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)}T${two(t.hour)}:${two(t.minute)}:${two(t.second)}+00:00';
  }

  static const _df =
      'Filesystem      Size  Used Avail Use% Mounted on\n'
      '/dev/vda1        96G   40G   57G  42% /\n'
      '/dev/vda15      105M  6.2M   99M   6% /boot/efi\n'
      '/dev/vdb1       492G  126G  341G  27% /srv/data';

  static const _updates =
      'libssl3t64/noble-updates 3.0.13-0ubuntu3.5 amd64 [upgradable from: 3.0.13-0ubuntu3.4]\n'
      'openssh-server/noble-updates 1:9.6p1-3ubuntu13.6 amd64 [upgradable from: 1:9.6p1-3ubuntu13.5]\n'
      'nginx/noble-updates 1.24.0-2ubuntu7.2 amd64 [upgradable from: 1.24.0-2ubuntu7.1]';

  static const _deploy =
      'From github.com:example/app\n'
      '   4f1c2b9..8e3a7d1  main       -> origin/main\n'
      'Updating 4f1c2b9..8e3a7d1\n'
      'Fast-forward\n'
      ' src/orders/receipt.ts | 14 ++++++++------\n'
      ' 1 file changed, 8 insertions(+), 6 deletions(-)';
}
