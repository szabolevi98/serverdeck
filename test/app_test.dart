import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverdeck/app.dart';
import 'package:serverdeck/data/app_data.dart';
import 'package:serverdeck/data/models.dart';
import 'package:serverdeck/data/storage.dart';
import 'package:serverdeck/demo/demo.dart';

void main() {
  testWidgets('starts on an empty server list', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dataFileProvider.overrideWithValue(MemoryDataFile()),
          secretStoreProvider.overrideWithValue(MemorySecretStore()),
        ],
        child: const ServerDeckApp(),
      ),
    );
    await tester.pumpAndSettle();
    // The large app bar draws its title twice: expanded and collapsed.
    expect(find.text('Servers'), findsWidgets);
    expect(find.text('No servers yet'), findsOneWidget);
  });

  testWidgets('shows the language picked in the settings', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dataFileProvider.overrideWithValue(
            MemoryDataFile(const AppData(settings: Settings(language: 'fr'))),
          ),
          secretStoreProvider.overrideWithValue(MemorySecretStore()),
        ],
        child: const ServerDeckApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Aucun serveur'), findsOneWidget);
  });

  testWidgets('a language picked in the settings is used and saved', (
    tester,
  ) async {
    final file = MemoryDataFile();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dataFileProvider.overrideWithValue(file),
          secretStoreProvider.overrideWithValue(MemorySecretStore()),
        ],
        child: const ServerDeckApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text("The phone's language"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch').last);
    await tester.pumpAndSettle();
    expect(find.text('Einstellungen'), findsOneWidget);
    expect(file.data.settings.language, 'de');
  });

  testWidgets('the demo opens from the empty list, in the same language', (
    tester,
  ) async {
    addTearDown(stopDemo);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dataFileProvider.overrideWithValue(
            MemoryDataFile(const AppData(settings: Settings(language: 'en'))),
          ),
          secretStoreProvider.overrideWithValue(MemorySecretStore()),
        ],
        child: const ServerDeckApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try the demo'));
    expect(demoTour.value?.language, 'en');

    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('demo'),
        overrides: demoOverrides(settings: demoTour.value!),
        child: const ServerDeckApp(),
      ),
    );
    // The demo's knocks take a moment; the list is there before they answer.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('web-1'), findsOneWidget);
    expect(find.text('Exit'), findsOneWidget);
    await tester.tap(find.text('Exit'));
    expect(demoTour.value, isNull);
    // Let the demo's slow answers run out.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
  });
}
