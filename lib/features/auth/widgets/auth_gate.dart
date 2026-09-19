import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/profile_service.dart';
import '../screens/auth_screen.dart';
import '../screens/profile_setup_screen.dart';

class AuthGate extends StatelessWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: AuthService.instance.authStateChanges,
      initialData: AuthService.instance.currentUser,
      builder: (context, authSnapshot) {
        final AuthUser? user = authSnapshot.data;

        // If not logged in, show AuthScreen (Login/Signup/Guest)
        if (user == null) {
          return const AuthScreen();
        }

        // If logged in, stream their profile from ProfileService
        return StreamBuilder<UserProfile?>(
          stream: ProfileService.instance.watchProfile(user.uid),
          initialData: ProfileService.instance.getProfileSync(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting &&
                !profileSnapshot.hasData) {
              return const Scaffold(
                backgroundColor: Color(0xff1c1d2a),
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xffefc249)),
                ),
              );
            }

            final UserProfile? profile = profileSnapshot.data;

            // If profile does not exist or has no gamertag, show ProfileSetupScreen
            if (profile == null || !profile.isProfileComplete) {
              return ProfileSetupScreen(user: user);
            }

            // Profile is set up and complete, show main app
            return child;
          },
        );
      },
    );
  }
}
