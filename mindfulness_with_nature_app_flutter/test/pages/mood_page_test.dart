import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_with_nature_app_flutter/pages/mood_page.dart';

void main() {
  group('MoodSettingsPage', () {
    testWidgets('renders key sections and actions', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MoodSettingsPage()));

      expect(find.text('Set Your Mood'), findsOneWidget);
      expect(find.text('Background'), findsOneWidget);
      expect(find.text('Nature Sound'), findsOneWidget);
      expect(find.text('Apply Settings'), findsOneWidget);
    });

    testWidgets('allows selecting background and sound chips', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MoodSettingsPage()));

      await tester.tap(find.text('Forest'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Birdsong'));
      await tester.pumpAndSettle();

      final forestChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Forest'),
      );
      final birdsongChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Birdsong'),
      );

      expect(forestChip.selected, isTrue);
      expect(birdsongChip.selected, isTrue);
    });

    testWidgets('shows snackbar when applying settings', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MoodSettingsPage()));

      await tester.ensureVisible(find.text('Apply Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply Settings'));
      await tester.pump();

      expect(find.text('Mood settings saved 🌿'), findsOneWidget);
    });
  });
}