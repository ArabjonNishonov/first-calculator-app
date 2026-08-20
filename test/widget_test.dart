// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:calculate/main.dart';

void main() {
  testWidgets('calculates a basic expression', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsNWidgets(2));

    await tester.tap(find.text('7'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('='));
    await tester.pump();

    expect(find.text('12'), findsOneWidget);
  });
}
