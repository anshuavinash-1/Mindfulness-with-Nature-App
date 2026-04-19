import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mindfulness_with_nature_app_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('happy path - login, check progress, and logout',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the login page
      expect(find.text('Welcome to\nMindfulness with Nature'), findsOneWidget);

      // Enter login credentials
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');

      // Tap the login button and wait for the simulated API call (2 seconds)
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump(); // Start animations
      await tester
          .pump(const Duration(seconds: 3)); // Wait for API delay plus buffer
      await tester.pumpAndSettle(); // Wait for all animations to complete

      // Verify we're on the dashboard by checking for the app bar title
      expect(find.text('Mindfulness Dashboard'), findsOneWidget);

      // Tap the Meditate tab
      await tester.tap(find.text('Meditate'));
      await tester.pumpAndSettle();

      // Make sure we are on the Meditation page
      expect(find.text('Meditation Timer'), findsOneWidget);

      // Tap the mood tab
      await tester.tap(find.text('Mood'));
      await tester.pumpAndSettle();

      // Verify we're on the Mood page
      expect(find.text("Mood & Stress Tracking"), findsOneWidget);

      // Tap the Progress tab in bottom navigation
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      // Verify we're on the Progress page
      expect(find.text('Your Mindfulness Journey'), findsOneWidget);

      // Find and tap the logout button in the app bar
      await tester.tap(find.byTooltip('Logout'));
      await tester.pumpAndSettle();

      // Verify we're back on the login page
      expect(find.text('Welcome to\nMindfulness with Nature'), findsOneWidget);
    });
  });
}
