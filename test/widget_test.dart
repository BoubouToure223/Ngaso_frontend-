// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:myapp/app.dart';
import 'package:myapp/core/theme/theme_provider.dart';

void main() {
  testWidgets('Renders SplashPage on initial load', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const MyApp(),
      ),
    );

    // The router takes a moment to settle on the initial route.
    await tester.pumpAndSettle();

    // Verify that SplashPage is shown, which contains the App Logo.
    expect(find.byType(Image), findsOneWidget);
  });
}
