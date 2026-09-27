import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:serverdeck/app.dart';
import 'package:serverdeck/data/app_data.dart';
import 'package:serverdeck/data/models.dart';
import 'package:serverdeck/data/storage.dart';
import 'package:serverdeck/ui/app_lock.dart';

class FakeAuth implements LocalAuthentication {
  FakeAuth(this.answer);
  bool answer;
  int asked = 0;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<Object?> authMessages = const [],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async {
    asked++;
    return answer;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget app(FakeAuth auth, {required bool lock}) => ProviderScope(
  overrides: [
    dataFileProvider.overrideWithValue(
      MemoryDataFile(AppData(settings: Settings(appLock: lock))),
    ),
    secretStoreProvider.overrideWithValue(MemorySecretStore()),
    localAuthProvider.overrideWithValue(auth),
  ],
  child: const ServerDeckApp(),
);

void main() {
  testWidgets('with the lock off, nothing is asked', (tester) async {
    final auth = FakeAuth(false);
    await tester.pumpWidget(app(auth, lock: false));
    await tester.pumpAndSettle();
    expect(find.text('No servers yet'), findsOneWidget);
    expect(auth.asked, 0);
  });

  testWidgets('with the lock on, the app shows only after unlocking', (
    tester,
  ) async {
    final auth = FakeAuth(false);
    await tester.pumpWidget(app(auth, lock: true));
    await tester.pumpAndSettle();
    expect(find.text('ServerDeck is locked'), findsOneWidget);
    expect(find.text('No servers yet'), findsNothing);
    expect(auth.asked, greaterThan(0));

    auth.answer = true;
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.text('No servers yet'), findsOneWidget);
    expect(find.text('ServerDeck is locked'), findsNothing);
  });
}
