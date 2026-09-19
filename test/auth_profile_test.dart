import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design/core/models/user_profile.dart';
import 'package:design/core/services/auth_service.dart';
import 'package:design/core/services/profile_service.dart';
import 'package:design/features/auth/screens/auth_screen.dart';
import 'package:design/features/auth/screens/profile_setup_screen.dart';
import 'package:design/features/auth/widgets/auth_gate.dart';
import 'package:design/features/profile/screens/profile_screen.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('serialization toMap and fromMap works correctly', () {
      final DateTime now = DateTime.now();
      final UserProfile profile = UserProfile(
        uid: 'u123',
        displayName: 'GhostRider',
        email: 'ghost@playpal.com',
        avatarId: 'avatar_ninja',
        bio: 'Winning matches silently',
        createdAt: now,
        lastActive: now,
        stats: const PlayerStats(gamesPlayed: 10, wins: 7, favoriteGame: 'casefile'),
      );

      final Map<String, dynamic> map = profile.toMap();
      final UserProfile deserialized = UserProfile.fromMap(map);

      expect(deserialized.uid, 'u123');
      expect(deserialized.displayName, 'GhostRider');
      expect(deserialized.email, 'ghost@playpal.com');
      expect(deserialized.avatarId, 'avatar_ninja');
      expect(deserialized.stats.gamesPlayed, 10);
      expect(deserialized.stats.wins, 7);
      expect(deserialized.stats.winRate, 0.7);
      expect(deserialized.stats.favoriteGame, 'casefile');
      expect(deserialized.isProfileComplete, isTrue);
    });

    test('isProfileComplete returns false when displayName is empty', () {
      final UserProfile incomplete = UserProfile(
        uid: 'u456',
        displayName: '',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      expect(incomplete.isProfileComplete, isFalse);
    });
  });

  group('AuthService & ProfileService Logic', () {
    late MockAuthService authService;
    late MockProfileService profileService;

    setUp(() {
      authService = MockAuthService();
      profileService = MockProfileService();
      AuthService.instance = authService;
      ProfileService.instance = profileService;
    });

    test('signInWithEmail succeeds with valid demo credentials', () async {
      final AuthUser user = await authService.signInWithEmail(
        'player@playpal.com',
        'password123',
      );
      expect(user.uid, 'user_playpal_001');
      expect(user.email, 'player@playpal.com');
      expect(authService.currentUser?.uid, 'user_playpal_001');
    });

    test('signInWithEmail throws AuthException on incorrect password', () async {
      expect(
        () => authService.signInWithEmail('player@playpal.com', 'wrongpass'),
        throwsA(isA<AuthException>()),
      );
    });

    test('registerWithEmail creates new user and allows login', () async {
      final AuthUser user = await authService.registerWithEmail(
        'newhero@playpal.com',
        'supersecret',
      );
      expect(user.email, 'newhero@playpal.com');
      expect(authService.currentUser, equals(user));
    });

    test('signInAnonymously creates guest session', () async {
      final AuthUser guest = await authService.signInAnonymously();
      expect(guest.isGuest, isTrue);
      expect(guest.uid, startsWith('guest_'));
      expect(authService.currentUser?.isGuest, isTrue);
    });

    test('profileService saves and streams updated profile', () async {
      final UserProfile testProfile = UserProfile(
        uid: 'test_uid',
        displayName: 'TestPlayer',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      await profileService.saveProfile(testProfile);
      final UserProfile? fetched = await profileService.getProfile('test_uid');
      expect(fetched?.displayName, 'TestPlayer');
    });
  });

  group('Auth & Profile UI Tests', () {
    setUp(() {
      AuthService.instance = MockAuthService();
      ProfileService.instance = MockProfileService();
    });

    testWidgets('AuthScreen displays login and guest actions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AuthScreen()),
      );

      expect(find.text('PLAYPAL'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('PLAY AS GUEST (INSTANT)'), findsOneWidget);
    });

    testWidgets('ProfileSetupScreen allows gamertag entry and avatar selection', (tester) async {
      const AuthUser guest = AuthUser(uid: 'guest_999', isGuest: true);

      await tester.pumpWidget(
        const MaterialApp(home: ProfileSetupScreen(user: guest)),
      );

      expect(find.text('CREATE YOUR IDENTITY'), findsOneWidget);
      expect(find.text('ENTER ARENA'), findsOneWidget);

      // Verify avatar presets are displayed
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('ProfileScreen renders stats and sign-out button', (tester) async {
      final UserProfile demoProfile = UserProfile(
        uid: 'user_playpal_001',
        displayName: 'ShadowStriker',
        email: 'player@playpal.com',
        avatarId: 'avatar_ninja',
        bio: 'Ninja gamer',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        stats: const PlayerStats(gamesPlayed: 54, wins: 38, favoriteGame: 'hidden-hand'),
      );

      await tester.pumpWidget(
        MaterialApp(home: ProfileScreen(profile: demoProfile)),
      );

      expect(find.text('ShadowStriker'), findsOneWidget);
      expect(find.text('CAREER STATS'), findsOneWidget);
      expect(find.text('54'), findsOneWidget);
      expect(find.text('38'), findsOneWidget);
      expect(find.text('SIGN OUT'), findsOneWidget);
    });

    testWidgets('AuthGate routes to AuthScreen when unauthenticated', (tester) async {
      AuthService.instance = MockAuthService(initialUser: null);

      await tester.pumpWidget(
        const MaterialApp(
          home: AuthGate(child: Text('Protected Lobby')),
        ),
      );

      expect(find.text('PLAYPAL'), findsOneWidget);
      expect(find.text('Protected Lobby'), findsNothing);
    });

    testWidgets('AuthGate routes to child lobby when authenticated with complete profile', (tester) async {
      const AuthUser loggedIn = AuthUser(uid: 'user_playpal_001', email: 'player@playpal.com');
      AuthService.instance = MockAuthService(initialUser: loggedIn);

      await tester.pumpWidget(
        const MaterialApp(
          home: AuthGate(child: Text('Protected Lobby')),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Protected Lobby'), findsOneWidget);
    });
  });
}

