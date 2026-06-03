import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_with_nature_app_flutter/pages/mood_page.dart';
import 'package:mindfulness_with_nature_app_flutter/services/app_experience_service.dart';
import 'package:provider/provider.dart';

Widget _buildTestApp() {
  return ChangeNotifierProvider<AppExperienceService>(
    create: (_) => AppExperienceService(),
    child: const MaterialApp(home: MoodSettingsPage()),
  );
}

void main() {
  group('MoodSettingsPage', () {
    testWidgets('renders key sections and guest restriction message',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Set Your Mood'), findsOneWidget);
      expect(find.text('Background'), findsOneWidget);
      expect(find.text('Nature Sounds'), findsOneWidget);
      expect(find.text('Apply settings'), findsOneWidget);
      expect(
        find.textContaining('Guest theme changes are available on web only'),
        findsOneWidget,
      );
    });

    testWidgets('does not allow guest selection on non-web', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forest'));
      await tester.pumpAndSettle();

      expect(find.text('Ocean Waves'), findsOneWidget);
      expect(find.text('Unavailable'), findsNWidgets(2));

      final birdSongsTarget = find
          .ancestor(
            of: find.text('Bird Songs'),
            matching: find.byType(GestureDetector),
          )
          .first;
      await tester.ensureVisible(birdSongsTarget);
      await tester.tap(birdSongsTarget);
      await tester.pumpAndSettle();
    });

    testWidgets('does not save settings for guest on non-web', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      final applyButton = find.byKey(const Key('mood-apply-settings-button'));
      await tester.ensureVisible(applyButton);
      await tester.pumpAndSettle();
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      expect(find.text('Mood settings saved 🌿'), findsNothing);
    });
  });
}
