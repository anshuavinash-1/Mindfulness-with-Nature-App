import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfulness_with_nature_app_flutter/models/community_post.dart';
import 'package:mindfulness_with_nature_app_flutter/models/user_model.dart'
    as app_model;
import 'package:mindfulness_with_nature_app_flutter/pages/community_page.dart';
import 'package:mindfulness_with_nature_app_flutter/services/auth_service.dart';
import 'package:provider/provider.dart';

class FakeAuthService extends ChangeNotifier implements AuthService {
  FakeAuthService({this.user});

  final app_model.User? user;

  @override
  app_model.User? get currentUser => user;

  @override
  String? get userEmail => user?.email;

  @override
  bool get isLoading => false;

  @override
  bool get isLoggedIn => user != null;

  @override
  Stream<app_model.User?> get authStateChanges => Stream.value(user);

  @override
  Future<app_model.User?> signInWithEmail(
          String email, String password) async =>
      user;

  @override
  Future<app_model.User?> signUpWithEmail(String email, String password,
          {String? displayName}) async =>
      user;

  @override
  Future<bool> login(String email, String password) async => user != null;

  @override
  Future<bool> signup(
          String email, String password, String confirmPassword) async =>
      user != null;

  @override
  Future<void> signOut() async {}

  @override
  void logout() {}

  @override
  Future<Map<String, dynamic>> getCurrentUserClaims(
          {bool forceRefresh = false}) async =>
      const <String, dynamic>{};

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> deleteAccount() async {}
}

Widget _buildTestApp({
  required AuthService authService,
  Stream<List<CommunityPost>>? postsStream,
}) {
  return ChangeNotifierProvider<AuthService>.value(
    value: authService,
    child: MaterialApp(
      home: CommunityPage(postsStream: postsStream),
    ),
  );
}

Future<void> _pumpWithLargeSurface(
  WidgetTester tester,
  Widget widget,
) async {
  await tester.binding.setSurfaceSize(const Size(800, 1800));
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
  await tester.pumpWidget(widget);
}

void main() {
  group('CommunityPage', () {
    testWidgets('guest mode blocks posting and shows guidance', (tester) async {
      await _pumpWithLargeSurface(
        tester,
        _buildTestApp(
          authService: FakeAuthService(),
          postsStream: const Stream<List<CommunityPost>>.empty(),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text(
            'Guests can browse community posts but must sign in to create a post.'),
        findsOneWidget,
      );

      final postButton = tester.widget<FilledButton>(
        find.byKey(const Key('community-post-button')),
      );

      expect(postButton.onPressed, isNull);
    });

    testWidgets('signed in mode enables the composer', (tester) async {
      final user = app_model.User(
        uid: 'user-123',
        email: 'person@example.com',
        displayName: 'Person',
        createdAt: DateTime(2026, 1, 1),
        lastLogin: DateTime(2026, 1, 2),
        preferences: app_model.UserPreferences(
          theme: 'forest',
          notificationsEnabled: true,
          fontScale: 1.0,
        ),
      );

      await _pumpWithLargeSurface(
        tester,
        _buildTestApp(
          authService: FakeAuthService(user: user),
          postsStream: const Stream<List<CommunityPost>>.empty(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Guests can browse community posts'),
          findsNothing);

      final postButton = tester.widget<FilledButton>(
        find.byKey(const Key('community-post-button')),
      );

      expect(postButton.onPressed, isNotNull);
    });

    testWidgets('tapping a post image opens the viewer with a close control',
        (tester) async {
      final user = app_model.User(
        uid: 'user-123',
        email: 'person@example.com',
        displayName: 'Person',
        createdAt: DateTime(2026, 1, 1),
        lastLogin: DateTime(2026, 1, 2),
        preferences: app_model.UserPreferences(
          theme: 'forest',
          notificationsEnabled: true,
          fontScale: 1.0,
        ),
      );

      final post = CommunityPost(
        id: 'post-1',
        userId: user.uid,
        username: 'Person',
        content: 'A peaceful moment',
        imageUrl: 'https://example.com/sample-image.jpg',
        createdAt: DateTime(2026, 1, 3),
      );

      final controller = StreamController<List<CommunityPost>>.broadcast();
      addTearDown(controller.close);

      await _pumpWithLargeSurface(
        tester,
        _buildTestApp(
          authService: FakeAuthService(user: user),
          postsStream: controller.stream,
        ),
      );

      controller.add([post]);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('community-image-preview')), findsOneWidget);

      await tester
          .ensureVisible(find.byKey(const Key('community-image-preview')));
      await tester.tap(find.byKey(const Key('community-image-preview')));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key('community-viewer-close-icon')), findsOneWidget);
      expect(find.byKey(const Key('community-viewer-close-button')),
          findsOneWidget);
    });
  });
}
