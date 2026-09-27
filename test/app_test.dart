import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverdeck/app.dart';
import 'package:serverdeck/data/app_data.dart';
import 'package:serverdeck/data/storage.dart';

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
}
