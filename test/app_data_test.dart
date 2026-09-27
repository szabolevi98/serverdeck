import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverdeck/data/app_data.dart';
import 'package:serverdeck/data/models.dart';
import 'package:serverdeck/data/storage.dart';
import 'package:serverdeck/ssh/keys.dart';

void main() {
  late MemoryDataFile file;
  late MemorySecretStore secrets;
  late ProviderContainer container;

  AppDataNotifier notifier() => container.read(appDataProvider.notifier);
  Future<AppData> data() => container.read(appDataProvider.future);

  setUp(() {
    file = MemoryDataFile();
    secrets = MemorySecretStore();
    container = ProviderContainer(
      overrides: [
        dataFileProvider.overrideWithValue(file),
        secretStoreProvider.overrideWithValue(secrets),
      ],
    );
  });
  tearDown(() => container.dispose());

  const web = ServerProfile(
    id: 's1',
    name: 'web',
    host: 'example.com',
    username: 'root',
    auth: AuthMethod.password,
  );

  test('a server is saved with its password kept apart', () async {
    await notifier().saveServer(web, password: 'hunter2');
    expect((await data()).servers.single.host, 'example.com');
    expect(secrets.values[Secrets.password('s1')], 'hunter2');
    expect(file.data.toJson().toString(), isNot(contains('hunter2')));
  });

  test(
    'a null password keeps the stored one, an empty one removes it',
    () async {
      await notifier().saveServer(web, password: 'hunter2');
      await notifier().saveServer(web.copyWith(name: 'renamed'));
      expect(secrets.values[Secrets.password('s1')], 'hunter2');
      expect((await data()).servers.single.name, 'renamed');
      await notifier().saveServer(web, password: '');
      expect(secrets.values, isEmpty);
    },
  );

  test('deleting a server takes its own commands and logs with it', () async {
    await notifier().saveServer(web, password: 'x');
    await notifier().saveCommand(
      const SavedCommand(id: 'c1', name: 'mine', command: 'ls', serverId: 's1'),
    );
    await notifier().saveCommand(
      const SavedCommand(id: 'c2', name: 'shared', command: 'uptime'),
    );
    await notifier().saveLogSource(
      const LogSource(
        id: 'l1',
        serverId: 's1',
        name: 'nginx',
        kind: LogKind.unit,
        target: 'nginx',
      ),
    );
    await notifier().deleteServer('s1');
    final d = await data();
    expect(d.servers, isEmpty);
    expect(d.commands.map((c) => c.id), ['c2']);
    expect(d.logSources, isEmpty);
    expect(secrets.values, isEmpty);
  });

  test('deleting a key unhooks the servers that used it', () async {
    final key = await notifier().addKey('k', generateEd25519('t'));
    expect(secrets.values[Secrets.privateKey(key.id)], contains('OPENSSH'));
    await notifier().saveServer(
      web.copyWith(auth: AuthMethod.key, keyId: key.id),
    );
    await notifier().deleteKey(key.id);
    final d = await data();
    expect(d.keys, isEmpty);
    expect(d.servers.single.keyId, isNull);
    expect(secrets.values, isEmpty);
  });

  test('trusting a host replaces what was known about it', () async {
    await notifier().trustHost('example.com', 'ssh-ed25519', 'SHA256:a');
    await notifier().trustHost('example.com', 'ssh-ed25519', 'SHA256:b');
    final d = await data();
    expect(d.knownHosts.single.fingerprint, 'SHA256:b');
    await notifier().forgetHost('example.com');
    expect((await data()).knownHosts, isEmpty);
  });

  test('servers reorder like a ReorderableListView reports it', () async {
    for (final id in ['a', 'b', 'c']) {
      await notifier().saveServer(
        ServerProfile(id: id, name: id, host: id, username: 'u'),
      );
    }
    await notifier().reorderServers(0, 3);
    expect((await data()).servers.map((s) => s.id), ['b', 'c', 'a']);
    await notifier().reorderServers(2, 0);
    expect((await data()).servers.map((s) => s.id), ['a', 'b', 'c']);
  });

  test('the data survives a round trip through JSON', () async {
    await notifier().saveServer(web.copyWith(port: 2222));
    await notifier().addKey('k', generateEd25519('t'));
    await notifier().updateSettings(const Settings(appLock: true));
    final back = AppData.fromJson(file.data.toJson());
    expect(back.servers.single.port, 2222);
    expect(back.servers.single.hostKeyId, '[example.com]:2222');
    expect(back.servers.single.address, 'root@example.com:2222');
    expect(back.keys.single.name, 'k');
    expect(back.settings.appLock, isTrue);
  });
}
