import 'package:flutter_test/flutter_test.dart';
import 'package:nutrimate/main.dart';

void main() {
  testWidgets('NutriMate app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NutriMateApp());
    expect(find.byType(NutriMateApp), findsOneWidget);
  });
}
