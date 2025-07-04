// This is a basic widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hospital_massage_system/app/app.dart';

void main() {
  testWidgets('Hospital Massage System smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HospitalMassageApp());

    // Verify that our app displays the hospital name
    expect(find.text('Hospital Massage System'), findsOneWidget);
    expect(find.text('Medical Center Massage Workshop'), findsOneWidget);
    
    // Verify that the loading indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Verify that initialization text is shown
    expect(find.text('Initializing System...'), findsOneWidget);
  });
}
