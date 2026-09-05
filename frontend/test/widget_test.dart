import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('HistHealth app loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HistHealthApp());
    expect(find.text('HistHealth'), findsWidgets);
  });
}
