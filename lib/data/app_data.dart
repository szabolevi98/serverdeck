import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ssh/keys.dart';
import 'models.dart';
import 'storage.dart';

final dataFileProvider = Provider<DataFile>((ref) => JsonDataFile());
final secretStoreProvider = Provider<SecretStore>(
  (ref) => const PlatformSecretStore(),
);

final appDataProvider = AsyncNotifierProvider<AppDataNotifier, AppData>(
  AppDataNotifier.new,
);

final _random = Random.secure();

/// A random id, 16 hex digits.
String newId() => List.generate(
  8,
  (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();

/// Every change to what ServerDeck remembers goes through here, and is saved
/// before the call returns.
class AppDataNotifier extends AsyncNotifier<AppData> {
  DataFile get _file => ref.read(dataFileProvider);
  SecretStore get _secrets => ref.read(secretStoreProvider);

  @override
  Future<AppData> build() => _file.load();

  Future<AppData> get _current async => state.value ?? await future;

  Future<void> _save(AppData next) async {
    await _file.save(next);
    state = AsyncData(next);
  }

  // Servers

  /// Adds [server], or replaces the one with its id. A null [password] leaves
  /// a stored one alone; an empty one deletes it.
  Future<void> saveServer(ServerProfile server, {String? password}) async {
    final data = await _current;
    final exists = data.server(server.id) != null;
    if (password != null) {
      if (password.isEmpty) {
        await _secrets.delete(Secrets.password(server.id));
      } else {
        await _secrets.write(Secrets.password(server.id), password);
      }
    }
    await _save(
      data.copyWith(
        servers: exists
            ? [for (final s in data.servers) s.id == server.id ? server : s]
            : [...data.servers, server],
      ),
    );
  }

  /// Removes the server with everything that belongs only to it.
  Future<void> deleteServer(String id) async {
    final data = await _current;
    await _secrets.delete(Secrets.password(id));
    await _save(
      data.copyWith(
        servers: data.servers.where((s) => s.id != id).toList(),
        commands: data.commands.where((c) => c.serverId != id).toList(),
        logSources: data.logSources.where((l) => l.serverId != id).toList(),
      ),
    );
  }

  Future<void> reorderServers(int from, int to) async {
    final data = await _current;
    final servers = [...data.servers];
    final moved = servers.removeAt(from);
    servers.insert(to > from ? to - 1 : to, moved);
    await _save(data.copyWith(servers: servers));
  }

  Future<String?> password(String serverId) =>
      _secrets.read(Secrets.password(serverId));

  // Keys

  Future<SshKey> addKey(String name, KeyMaterial material) async {
    final data = await _current;
    final key = SshKey(
      id: newId(),
      name: name,
      type: material.type,
      publicKey: material.publicKey,
      fingerprint: material.fingerprint,
      created: DateTime.now(),
    );
    await _secrets.write(Secrets.privateKey(key.id), material.privatePem);
    await _save(data.copyWith(keys: [...data.keys, key]));
    return key;
  }

  Future<void> renameKey(String id, String name) async {
    final data = await _current;
    await _save(
      data.copyWith(
        keys: [
          for (final k in data.keys)
            k.id == id
                ? SshKey(
                    id: k.id,
                    name: name,
                    type: k.type,
                    publicKey: k.publicKey,
                    fingerprint: k.fingerprint,
                    created: k.created,
                  )
                : k,
        ],
      ),
    );
  }

  /// Deletes the key. Servers that used it are left without one, and will ask.
  Future<void> deleteKey(String id) async {
    final data = await _current;
    await _secrets.delete(Secrets.privateKey(id));
    await _save(
      data.copyWith(
        keys: data.keys.where((k) => k.id != id).toList(),
        servers: [
          for (final s in data.servers) s.keyId == id ? s.withoutKey() : s,
        ],
      ),
    );
  }

  Future<String?> privateKey(String keyId) =>
      _secrets.read(Secrets.privateKey(keyId));

  // Known hosts

  Future<void> trustHost(String host, String type, String fingerprint) async {
    final data = await _current;
    await _save(
      data.copyWith(
        knownHosts: [
          ...data.knownHosts.where((h) => h.host != host),
          KnownHost(
            host: host,
            type: type,
            fingerprint: fingerprint,
            added: DateTime.now(),
          ),
        ],
      ),
    );
  }

  Future<void> forgetHost(String host) async {
    final data = await _current;
    await _save(
      data.copyWith(
        knownHosts: data.knownHosts.where((h) => h.host != host).toList(),
      ),
    );
  }

  // Saved commands

  Future<void> saveCommand(SavedCommand command) async {
    final data = await _current;
    final exists = data.commands.any((c) => c.id == command.id);
    await _save(
      data.copyWith(
        commands: exists
            ? [for (final c in data.commands) c.id == command.id ? command : c]
            : [...data.commands, command],
      ),
    );
  }

  Future<void> deleteCommand(String id) async {
    final data = await _current;
    await _save(
      data.copyWith(commands: data.commands.where((c) => c.id != id).toList()),
    );
  }

  // Log sources

  Future<void> saveLogSource(LogSource source) async {
    final data = await _current;
    final exists = data.logSources.any((l) => l.id == source.id);
    await _save(
      data.copyWith(
        logSources: exists
            ? [for (final l in data.logSources) l.id == source.id ? source : l]
            : [...data.logSources, source],
      ),
    );
  }

  Future<void> deleteLogSource(String id) async {
    final data = await _current;
    await _save(
      data.copyWith(
        logSources: data.logSources.where((l) => l.id != id).toList(),
      ),
    );
  }

  // Settings

  Future<void> updateSettings(Settings settings) async {
    final data = await _current;
    await _save(data.copyWith(settings: settings));
  }
}
