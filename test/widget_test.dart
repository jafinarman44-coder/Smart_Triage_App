import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_triage_app/main.dart';

void main() {
  testWidgets('SmartTriageApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartTriageApp());

    // Verify that our dashboard header or title is present.
    expect(find.text('SmartTriage AI'), findsOneWidget);
    expect(find.text('Triage Queue'), findsOneWidget);
  });
}
