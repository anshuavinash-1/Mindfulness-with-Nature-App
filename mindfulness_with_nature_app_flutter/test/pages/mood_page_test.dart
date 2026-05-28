import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_with_nature_app_flutter/pages/mood_page.dart';

void main() {
  group('MoodSettingsPage', () {
    testWidgets('renders key sections and actions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(const MaterialApp(home: MoodSettingsPage()));

      expect(find.text('Set Your Mood'), findsOneWidget);
      expect(find.text('Background'), findsOneWidget);
      expect(find.text('Nature Sounds'), findsOneWidget);
      expect(find.text('Apply settings'), findsOneWidget);
    });

    testWidgets('allows selecting background and sound chips', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(const MaterialApp(home: MoodSettingsPage()));

      await tester.tap(find.text('Forest'));
      await tester.pumpAndSettle();

      final birdSongsTarget = find
          .ancestor(
            of: find.text('Bird Songs'),
            matching: find.byType(GestureDetector),
          )
          .first;
      await tester.ensureVisible(birdSongsTarget);
      await tester.tap(birdSongsTarget);
      await tester.pumpAndSettle();

      final forestText = tester.widget<Text>(find.text('Forest'));
      final birdSongsText = tester.widget<Text>(find.text('Bird Songs'));

      expect(forestText.style?.fontWeight, FontWeight.bold);
      expect(birdSongsText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('shows snackbar when applying settings', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(const MaterialApp(home: MoodSettingsPage()));

      await tester.ensureVisible(find.text('Apply settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply settings'));
      await tester.pump();

      expect(find.text('Mood settings saved 🌿'), findsOneWidget);
    });
  });
}
