import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design/core/services/auth_service.dart';
import 'package:design/core/services/profile_service.dart';
import 'package:design/main.dart';

void main() {
  setUp(() {
    AuthService.instance = MockAuthService(
      initialUser: const AuthUser(
        uid: 'user_playpal_001',
        email: 'player@playpal.com',
      ),
    );
    ProfileService.instance = MockProfileService();
  });
  testWidgets('game home shows discovery content', (tester) async {
    await tester.pumpWidget(const PlayPalApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Dive into the Action'), findsOneWidget);
    expect(find.text('HIDDEN\nHAND'), findsOneWidget);
    expect(find.text('QUICK JOIN NOW'), findsOneWidget);
  });

  testWidgets('selecting a game shows launch bar and launching navigates to game screen', (tester) async {
    await tester.pumpWidget(const PlayPalApp());
    await tester.pumpAndSettle();

    // Tap on the first game card
    await tester.tap(find.text('HIDDEN\nHAND'));
    await tester.pumpAndSettle();

    // The launch bar should appear
    expect(find.text('LAUNCH GAME'), findsOneWidget);

    // Tap Launch Game
    await tester.tap(find.text('LAUNCH GAME'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('HIDDEN HAND is ready!'), findsOneWidget);
  });

  testWidgets('quick join launches game directly', (tester) async {
    await tester.pumpWidget(const PlayPalApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('QUICK JOIN NOW'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('HIDDEN HAND is ready!'), findsOneWidget);
  });

  testWidgets('navigating to inbox screen displays notifications', (tester) async {
    await tester.pumpWidget(const PlayPalApp());
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.mail_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Maya invited you to Sketch Party.'), findsOneWidget);
  });
}
