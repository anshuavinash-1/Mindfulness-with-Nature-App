import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_with_nature_app_flutter/pages/activities_page.dart';

void main() {
  group('ActivitiesPage', () {
    testWidgets('shows initial prompt before activity selection', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ActivitiesPage()));

      expect(find.text('Mindful Activities'), findsOneWidget);
      expect(find.text('Select an activity first'), findsOneWidget);
    });

    testWidgets('enables session start after selecting an activity', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ActivitiesPage()));

      await tester.tap(find.text('Being Present'));
      await tester.pumpAndSettle();

      expect(find.text('Begin Session'), findsOneWidget);
      expect(find.text('Select an activity first'), findsNothing);
    });

    testWidgets('starts session and shows active-state controls', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ActivitiesPage()));

      await tester.tap(find.text('Being Present'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Begin Session'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Begin Session'));
      await tester.pump();

      expect(find.text('End Session'), findsOneWidget);
      expect(find.textContaining('Practicing: Being Present'), findsOneWidget);
      expect(find.text('Breathe... Relax... Let go...'), findsOneWidget);
    });
  });
}