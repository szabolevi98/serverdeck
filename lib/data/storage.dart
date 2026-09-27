import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'models.dart';

/// Where [AppData] is kept between runs.
abstract class DataFile {
  Future<AppData> load();
  Future<void> save(AppData data);
}

/// Passwords and private keys. Never written to the data file.
abstract class SecretStore {
  Future<String?> read(String name);
  Future<void> write(String name, String value);
  Future<void> delete(String name);
}

/// Names of the secrets, in one place.
abstract final class Secrets {
  static String password(String serverId) => 'password:$serverId';
  static String privateKey(String keyId) => 'key:$keyId';
}

/// A JSON file in the app's private support directory, replaced atomically
/// so a crash mid-write leaves the previous version intact.
class JsonDataFile implements DataFile {
  JsonDataFile([this._directory]);

  Directory? _directory;

  Future<File> _file() async {
    final dir = _directory ??= await getApplicationSupportDirectory();
    return File('${dir.path}${Platform.pathSeparator}serverdeck.json');
  }

  @override
  Future<AppData> load() async {
    final file = await _file();
    if (!await file.exists()) return const AppData();
    final json = jsonDecode(await file.readAsString()) as Map<String, Object?>;
    return AppData.fromJson(json);
  }

  @override
  Future<void> save(AppData data) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data.toJson()),
      flush: true,
    );
    await temp.rename(file.path);
  }
}

/// The Android Keystore / iOS Keychain backed store.
class PlatformSecretStore implements SecretStore {
  const PlatformSecretStore();

  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String name) => _storage.read(key: name);

  @override
  Future<void> write(String name, String value) =>
      _storage.write(key: name, value: value);

  @override
  Future<void> delete(String name) => _storage.delete(key: name);
}

/// For tests, and for nothing else.
class MemoryDataFile implements DataFile {
  MemoryDataFile([this.data = const AppData()]);
  AppData data;
  int saves = 0;

  @override
  Future<AppData> load() async => data;

  @override
  Future<void> save(AppData data) async {
    this.data = data;
    saves++;
  }
}

class MemorySecretStore implements SecretStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String name) async => values[name];

  @override
  Future<void> write(String name, String value) async => values[name] = value;

  @override
  Future<void> delete(String name) async => values.remove(name);
}
