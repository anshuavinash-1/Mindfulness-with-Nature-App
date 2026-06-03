import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_with_nature_app_flutter/pages/activities_page.dart';

void main() {
  group('ActivitiesPage', () {
    testWidgets('shows initial tag-selection prompt', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(const MaterialApp(home: ActivitiesPage()));
      await tester.pumpAndSettle();

      expect(find.text('Activities'), findsOneWidget);
      expect(find.text('Select tags first'), findsOneWidget);
    });

    testWidgets('allows selecting an activity tag', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(const MaterialApp(home: ActivitiesPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Being Present'));
      await tester.pumpAndSettle();

      final selectedTagText = tester.widget<Text>(find.text('Being Present'));
      expect(selectedTagText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets(
        'keeps start button disabled without playlist tracks in test env',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(const MaterialApp(home: ActivitiesPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Being Present'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Select tags first'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select tags first'));
      await tester.pumpAndSettle();

      expect(find.text('Select tags first'), findsOneWidget);
      expect(find.text('End Session'), findsNothing);
    });
  });
}
