import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverdeck/app.dart';

void main() {
  testWidgets('starts on the server list', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ServerDeckApp()));
    await tester.pumpAndSettle();
    expect(find.text('Servers'), findsOneWidget);
  });
}
