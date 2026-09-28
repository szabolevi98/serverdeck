/// The things ServerDeck remembers. Secrets (passwords, private keys) are not
/// here: they live in the platform's secure storage, keyed by these ids.
library;

import 'package:flutter/material.dart' show ThemeMode;

enum AuthMethod { key, password }

class ServerProfile {
  const ServerProfile({
    required this.id,
    required this.name,
    required this.host,
    this.port = 22,
    required this.username,
    this.auth = AuthMethod.key,
    this.keyId,
  });

  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  final AuthMethod auth;

  /// The [SshKey] to sign in with when [auth] is [AuthMethod.key].
  final String? keyId;

  /// `user@host` or `user@host:port`, the way ssh would be told to connect.
  String get address =>
      port == 22 ? '$username@$host' : '$username@$host:$port';

  /// Known hosts are keyed like OpenSSH keys them: `host` or `[host]:port`.
  String get hostKeyId => port == 22 ? host : '[$host]:$port';

  ServerProfile copyWith({
    String? name,
    String? host,
    int? port,
    String? username,
    AuthMethod? auth,
    String? keyId,
  }) => ServerProfile(
    id: id,
    name: name ?? this.name,
    host: host ?? this.host,
    port: port ?? this.port,
    username: username ?? this.username,
    auth: auth ?? this.auth,
    keyId: keyId ?? this.keyId,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'host': host,
    'port': port,
    'username': username,
    'auth': auth.name,
    'keyId': keyId,
  };

  factory ServerProfile.fromJson(Map<String, Object?> json) => ServerProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    host: json['host'] as String,
    port: json['port'] as int? ?? 22,
    username: json['username'] as String,
    auth: AuthMethod.values.byName(json['auth'] as String? ?? 'key'),
    keyId: json['keyId'] as String?,
  );
}

/// The public half of a key pair. The private half is in secure storage.
class SshKey {
  const SshKey({
    required this.id,
    required this.name,
    required this.type,
    required this.publicKey,
    required this.fingerprint,
    required this.created,
  });

  final String id;
  final String name;

  /// `ssh-ed25519`, `ssh-rsa`, `ecdsa-sha2-nistp256`, ...
  final String type;

  /// The line that goes into `authorized_keys`: `type base64 comment`.
  final String publicKey;

  /// `SHA256:...`, as `ssh-keygen -l` prints it.
  final String fingerprint;
  final DateTime created;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'publicKey': publicKey,
    'fingerprint': fingerprint,
    'created': created.toIso8601String(),
  };

  factory SshKey.fromJson(Map<String, Object?> json) => SshKey(
    id: json['id'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    publicKey: json['publicKey'] as String,
    fingerprint: json['fingerprint'] as String,
    created: DateTime.parse(json['created'] as String),
  );
}

/// A host key accepted on first contact, so a later change can be noticed.
class KnownHost {
  const KnownHost({
    required this.host,
    required this.type,
    required this.fingerprint,
    required this.added,
  });

  /// `host` or `[host]:port`, see [ServerProfile.hostKeyId].
  final String host;
  final String type;
  final String fingerprint;
  final DateTime added;

  Map<String, Object?> toJson() => {
    'host': host,
    'type': type,
    'fingerprint': fingerprint,
    'added': added.toIso8601String(),
  };

  factory KnownHost.fromJson(Map<String, Object?> json) => KnownHost(
    host: json['host'] as String,
    type: json['type'] as String,
    fingerprint: json['fingerprint'] as String,
    added: DateTime.parse(json['added'] as String),
  );
}

/// A command kept for one tap. [serverId] null means every server has it.
class SavedCommand {
  const SavedCommand({
    required this.id,
    required this.name,
    required this.command,
    this.serverId,
    this.confirm = true,
  });

  final String id;
  final String name;
  final String command;
  final String? serverId;

  /// Ask before running it.
  final bool confirm;

  SavedCommand copyWith({
    String? name,
    String? command,
    String? Function()? serverId,
    bool? confirm,
  }) => SavedCommand(
    id: id,
    name: name ?? this.name,
    command: command ?? this.command,
    serverId: serverId != null ? serverId() : this.serverId,
    confirm: confirm ?? this.confirm,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'command': command,
    'serverId': serverId,
    'confirm': confirm,
  };

  factory SavedCommand.fromJson(Map<String, Object?> json) => SavedCommand(
    id: json['id'] as String,
    name: json['name'] as String,
    command: json['command'] as String,
    serverId: json['serverId'] as String?,
    confirm: json['confirm'] as bool? ?? true,
  );
}

/// A log to follow: a systemd unit's journal, the whole journal, or a file.
class LogSource {
  const LogSource({
    required this.id,
    required this.serverId,
    required this.name,
    required this.kind,
    required this.target,
  });

  final String id;
  final String serverId;
  final String name;
  final LogKind kind;

  /// The unit for [LogKind.unit], the path for [LogKind.file], unused for
  /// [LogKind.journal].
  final String target;

  Map<String, Object?> toJson() => {
    'id': id,
    'serverId': serverId,
    'name': name,
    'kind': kind.name,
    'target': target,
  };

  factory LogSource.fromJson(Map<String, Object?> json) => LogSource(
    id: json['id'] as String,
    serverId: json['serverId'] as String,
    name: json['name'] as String,
    kind: LogKind.values.byName(json['kind'] as String),
    target: json['target'] as String? ?? '',
  );
}

enum LogKind { journal, unit, file }

class Settings {
  const Settings({this.appLock = false, this.themeMode = ThemeMode.system});

  /// Ask for a fingerprint, face or the device PIN on start and on return.
  final bool appLock;

  /// Light, dark, or whatever the phone is set to.
  final ThemeMode themeMode;

  Settings copyWith({bool? appLock, ThemeMode? themeMode}) => Settings(
    appLock: appLock ?? this.appLock,
    themeMode: themeMode ?? this.themeMode,
  );

  Map<String, Object?> toJson() => {
    'appLock': appLock,
    'themeMode': themeMode.name,
  };

  factory Settings.fromJson(Map<String, Object?> json) => Settings(
    appLock: json['appLock'] as bool? ?? false,
    themeMode:
        ThemeMode.values.asNameMap()[json['themeMode']] ?? ThemeMode.system,
  );
}

/// Everything in the data file, as one immutable value.
class AppData {
  const AppData({
    this.servers = const [],
    this.keys = const [],
    this.knownHosts = const [],
    this.commands = const [],
    this.logSources = const [],
    this.settings = const Settings(),
  });

  final List<ServerProfile> servers;
  final List<SshKey> keys;
  final List<KnownHost> knownHosts;
  final List<SavedCommand> commands;
  final List<LogSource> logSources;
  final Settings settings;

  ServerProfile? server(String id) =>
      servers.where((s) => s.id == id).firstOrNull;

  SshKey? key(String id) => keys.where((k) => k.id == id).firstOrNull;

  KnownHost? knownHost(String host) =>
      knownHosts.where((h) => h.host == host).firstOrNull;

  /// The commands offered on [serverId]: its own and the shared ones.
  List<SavedCommand> commandsFor(String serverId) => commands
      .where((c) => c.serverId == null || c.serverId == serverId)
      .toList();

  List<LogSource> logSourcesFor(String serverId) =>
      logSources.where((l) => l.serverId == serverId).toList();

  AppData copyWith({
    List<ServerProfile>? servers,
    List<SshKey>? keys,
    List<KnownHost>? knownHosts,
    List<SavedCommand>? commands,
    List<LogSource>? logSources,
    Settings? settings,
  }) => AppData(
    servers: servers ?? this.servers,
    keys: keys ?? this.keys,
    knownHosts: knownHosts ?? this.knownHosts,
    commands: commands ?? this.commands,
    logSources: logSources ?? this.logSources,
    settings: settings ?? this.settings,
  );

  Map<String, Object?> toJson() => {
    'version': 1,
    'servers': [for (final s in servers) s.toJson()],
    'keys': [for (final k in keys) k.toJson()],
    'knownHosts': [for (final h in knownHosts) h.toJson()],
    'commands': [for (final c in commands) c.toJson()],
    'logSources': [for (final l in logSources) l.toJson()],
    'settings': settings.toJson(),
  };

  factory AppData.fromJson(Map<String, Object?> json) {
    List<T> list<T>(String name, T Function(Map<String, Object?>) read) => [
      for (final item in (json[name] as List<Object?>? ?? const []))
        read(item! as Map<String, Object?>),
    ];
    return AppData(
      servers: list('servers', ServerProfile.fromJson),
      keys: list('keys', SshKey.fromJson),
      knownHosts: list('knownHosts', KnownHost.fromJson),
      commands: list('commands', SavedCommand.fromJson),
      logSources: list('logSources', LogSource.fromJson),
      settings: Settings.fromJson(
        json['settings'] as Map<String, Object?>? ?? const {},
      ),
    );
  }
}
