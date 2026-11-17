import 'package:flutter_test/flutter_test.dart';

import 'package:smart_triage_app/main.dart';

void main() {
  testWidgets('SmartTriageApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartTriageApp());
    await tester.pumpAndSettle();

    expect(find.text('SmartTriage AI'), findsOneWidget);
    expect(find.text('Triage Queue'), findsOneWidget);
  });
}
