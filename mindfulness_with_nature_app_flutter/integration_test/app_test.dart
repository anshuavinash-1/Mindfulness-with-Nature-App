import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mindfulness_with_nature_app_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> launchApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Mindfulness with Nature'), findsOneWidget);
  }

  Future<void> openSignupPage(WidgetTester tester) async {
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.text('Create Account'), findsOneWidget);
  }

  group('authentication integration tests', () {
    testWidgets('login shows validation for empty fields',
        (WidgetTester tester) async {
      await launchApp(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('login shows validation for invalid email',
        (WidgetTester tester) async {
      await launchApp(tester);

      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'invalid-email');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('signup flow navigates from login to signup and back',
        (WidgetTester tester) async {
      await launchApp(tester);

      await openSignupPage(tester);

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Mindfulness with Nature'), findsOneWidget);
    });

    testWidgets('signup shows validation for empty fields',
        (WidgetTester tester) async {
      await launchApp(tester);
      await openSignupPage(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('signup shows validation for invalid email',
        (WidgetTester tester) async {
      await launchApp(tester);
      await openSignupPage(tester);

      await tester.enterText(
          find.widgetWithText(TextField, 'Full Name'), 'Pat');
      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'invalid-email');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(
          find.widgetWithText(TextField, 'Confirm Password'), 'password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('signup shows validation for short password',
        (WidgetTester tester) async {
      await launchApp(tester);
      await openSignupPage(tester);

      await tester.enterText(
          find.widgetWithText(TextField, 'Full Name'), 'Pat');
      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'pat@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), '123');
      await tester.enterText(
          find.widgetWithText(TextField, 'Confirm Password'), '123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('signup shows validation for mismatched passwords',
        (WidgetTester tester) async {
      await launchApp(tester);
      await openSignupPage(tester);

      await tester.enterText(
          find.widgetWithText(TextField, 'Full Name'), 'Pat');
      await tester.enterText(
          find.widgetWithText(TextField, 'Email'), 'pat@example.com');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'password123');
      await tester.enterText(
          find.widgetWithText(TextField, 'Confirm Password'), 'password999');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
