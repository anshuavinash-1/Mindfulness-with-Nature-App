import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_with_nature_app_flutter/pages/bottom_nav.dart';

void main() {
  group('BottomNavBar', () {
    testWidgets('renders all expected tabs', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Activities'), findsOneWidget);
      expect(find.text('Set Your Mood'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
    });

    testWidgets('invokes onTap with tapped index', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavBar(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Community'));
      await tester.pumpAndSettle();

      expect(tappedIndex, equals(4));
    });
  });
}
