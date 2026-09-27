/// systemd services and Docker containers: listing them, and the commands
/// that start, stop and restart them.
library;

import 'dart:convert';

const _separator = '@@SD@@';

/// Every service unit systemd knows, then what each one's unit file says
/// about starting at boot.
const servicesCommand =
    'systemctl list-units --type=service --all --no-pager --plain --no-legend; '
    'echo $_separator; '
    'systemctl list-unit-files --type=service --no-pager --no-legend';

/// Says first whether Docker is installed, then lists the containers.
const dockerCommand =
    'if command -v docker >/dev/null 2>&1; then echo DOCKER; '
    "docker ps -a --no-trunc --format '{{json .}}'; "
    'else echo NODOCKER; fi';

/// Wraps [value] for a POSIX shell so that nothing in it is interpreted.
String shellQuote(String value) => "'${value.replaceAll("'", r"'\''")}'";

/// `sudo -n` in front of [command] unless the user is root. `-n` fails at
/// once instead of waiting for a password nobody can type.
String privileged(String command, {required bool root}) =>
    root ? command : 'sudo -n $command';

enum ServiceState { running, exited, failed, inactive, activating, other }

class Service {
  const Service({
    required this.unit,
    required this.active,
    required this.sub,
    required this.description,
    this.enabled,
  });

  /// `apache2.service`
  final String unit;

  /// `active`, `inactive`, `failed`, `activating`, ...
  final String active;

  /// `running`, `exited`, `dead`, `failed`, ...
  final String sub;
  final String description;

  /// `enabled`, `disabled`, `static`, ... when the unit file said.
  final String? enabled;

  /// `apache2`, as people call it.
  String get name =>
      unit.endsWith('.service') ? unit.substring(0, unit.length - 8) : unit;

  ServiceState get state => switch ((active, sub)) {
    ('active', 'running') => ServiceState.running,
    ('active', 'exited') => ServiceState.exited,
    ('failed', _) => ServiceState.failed,
    ('activating' || 'reloading' || 'deactivating', _) =>
      ServiceState.activating,
    ('inactive', _) => ServiceState.inactive,
    _ => ServiceState.other,
  };

  bool get isEnabled => enabled == 'enabled' || enabled == 'enabled-runtime';
}

/// Parses [servicesCommand]'s output. Units whose file is gone (`not-found`)
/// are dropped: they are names other units mention, not services.
List<Service> parseServices(String output) {
  final text = output.replaceAll('\r\n', '\n');
  final at = text.indexOf('$_separator\n');
  final unitsPart = at < 0 ? text : text.substring(0, at);
  final filesPart = at < 0 ? '' : text.substring(at + _separator.length + 1);

  final enabled = <String, String>{};
  for (final line in filesPart.split('\n')) {
    final f = line.trim().split(RegExp(r'\s+'));
    if (f.length >= 2 && f[0].endsWith('.service')) enabled[f[0]] = f[1];
  }

  final services = <Service>[];
  for (final raw in unitsPart.split('\n')) {
    // Some systemd versions mark failed units with a bullet in front.
    final line = raw.replaceFirst(RegExp(r'^[\s●*]+'), '');
    final match = RegExp(r'^(\S+\.service)\s+(\S+)\s+(\S+)\s+(\S+)\s*(.*)$')
        .firstMatch(line);
    if (match == null) continue;
    final load = match.group(2)!;
    if (load == 'not-found' || load == 'masked') continue;
    final unit = match.group(1)!;
    // An instance like user@0.service takes its file's state from user@.service.
    final template = unit.contains('@')
        ? '${unit.substring(0, unit.indexOf('@'))}@.service'
        : null;
    services.add(
      Service(
        unit: unit,
        active: match.group(3)!,
        sub: match.group(4)!,
        description: match.group(5)!.trim(),
        enabled: enabled[unit] ?? (template == null ? null : enabled[template]),
      ),
    );
  }
  services.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return services;
}

enum ServiceAction { start, stop, restart, reload }

String serviceActionCommand(
  Service service,
  ServiceAction action, {
  required bool root,
}) => privileged(
  'systemctl ${action.name} ${shellQuote(service.unit)}',
  root: root,
);

/// The last lines of the unit's status and journal, for the detail sheet.
String serviceStatusCommand(Service service, {required bool root}) =>
    privileged(
      'systemctl status ${shellQuote(service.unit)} --no-pager -n 30 -l',
      root: root,
    );

enum ContainerState { running, paused, restarting, exited, created, other }

class DockerContainer {
  const DockerContainer({
    required this.id,
    required this.name,
    required this.image,
    required this.stateText,
    required this.status,
    required this.ports,
  });

  final String id;
  final String name;
  final String image;
  final String stateText;

  /// `Up 3 hours (healthy)`, `Exited (0) 2 days ago`, ...
  final String status;
  final String ports;

  ContainerState get state => switch (stateText) {
    'running' => ContainerState.running,
    'paused' => ContainerState.paused,
    'restarting' => ContainerState.restarting,
    'exited' || 'dead' => ContainerState.exited,
    'created' => ContainerState.created,
    _ => ContainerState.other,
  };

  bool get unhealthy => status.contains('(unhealthy)');
}

/// Parses [dockerCommand]'s output, one JSON object per line. Null when
/// Docker is not installed, which is different from no containers.
List<DockerContainer>? parseContainers(String output) {
  final lines = const LineSplitter().convert(output);
  if (lines.isEmpty || lines.first.trim() != 'DOCKER') return null;
  final containers = <DockerContainer>[];
  for (final line in lines.skip(1)) {
    if (!line.trim().startsWith('{')) continue;
    final Map<String, Object?> j;
    try {
      j = jsonDecode(line) as Map<String, Object?>;
    } on FormatException {
      continue;
    }
    containers.add(
      DockerContainer(
        id: (j['ID'] as String? ?? '').characters12,
        name: (j['Names'] as String? ?? '').split(',').first,
        image: j['Image'] as String? ?? '',
        stateText: (j['State'] as String? ?? '').toLowerCase(),
        status: j['Status'] as String? ?? '',
        ports: j['Ports'] as String? ?? '',
      ),
    );
  }
  containers.sort(
    (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
  );
  return containers;
}

enum ContainerAction { start, stop, restart }

String containerActionCommand(
  DockerContainer container,
  ContainerAction action, {
  required bool root,
}) =>
    privileged('docker ${action.name} ${shellQuote(container.id)}', root: root);

extension on String {
  String get characters12 => length > 12 ? substring(0, 12) : this;
}

/// Adds [publicKey] to the user's `authorized_keys` unless it is there
/// already, creating `~/.ssh` with the modes sshd insists on.
String installKeyCommand(String publicKey) {
  final key = shellQuote(publicKey.trim());
  return 'umask 077; mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && '
      '(grep -qxF $key ~/.ssh/authorized_keys || '
      'echo $key >> ~/.ssh/authorized_keys) && '
      'chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys';
}
