import 'package:flutter_test/flutter_test.dart';
import 'package:foodie_notes/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('食誌 · AI 食記'), findsOneWidget);
  });
}
