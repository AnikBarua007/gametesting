import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthUser {
  final String uid;
  final String? email;
  final bool isGuest;

  const AuthUser({
    required this.uid,
    this.email,
    this.isGuest = false,
  });
}

abstract class AuthService {
  static AuthService instance = MockAuthService();

  Stream<AuthUser?> get authStateChanges;
  AuthUser? get currentUser;

  Future<AuthUser> signInWithEmail(String email, String password);
  Future<AuthUser> registerWithEmail(String email, String password);
  Future<AuthUser> signInAnonymously();
  Future<void> signOut();
}

class MockAuthService implements AuthService {
  final StreamController<AuthUser?> _authController =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  // In-memory mock user database (email -> password & user)
  final Map<String, String> _credentials = <String, String>{
    'player@playpal.com': 'password123',
    'pro@gamer.com': 'gameon123',
  };

  final Map<String, AuthUser> _usersByEmail = <String, AuthUser>{
    'player@playpal.com': const AuthUser(
      uid: 'user_playpal_001',
      email: 'player@playpal.com',
      isGuest: false,
    ),
    'pro@gamer.com': const AuthUser(
      uid: 'user_progamer_002',
      email: 'pro@gamer.com',
      isGuest: false,
    ),
  };

  MockAuthService({AuthUser? initialUser}) {
    _currentUser = initialUser;
  }

  @override
  Stream<AuthUser?> get authStateChanges => _authController.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final String cleanEmail = email.trim().toLowerCase();

    if (!_credentials.containsKey(cleanEmail) ||
        _credentials[cleanEmail] != password) {
      throw const AuthException('Invalid email or password. Please try again.');
    }

    final AuthUser user = _usersByEmail[cleanEmail]!;
    _currentUser = user;
    _authController.add(_currentUser);
    return user;
  }

  @override
  Future<AuthUser> registerWithEmail(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final String cleanEmail = email.trim().toLowerCase();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw const AuthException('Please provide a valid email address.');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters long.');
    }
    if (_credentials.containsKey(cleanEmail)) {
      throw const AuthException('An account with this email already exists.');
    }

    final String newUid = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final AuthUser user = AuthUser(uid: newUid, email: cleanEmail, isGuest: false);

    _credentials[cleanEmail] = password;
    _usersByEmail[cleanEmail] = user;

    _currentUser = user;
    _authController.add(_currentUser);
    return user;
  }

  @override
  Future<AuthUser> signInAnonymously() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final String guestId =
        'guest_${DateTime.now().millisecondsSinceEpoch % 100000}';
    final AuthUser guest = AuthUser(uid: guestId, isGuest: true);

    _currentUser = guest;
    _authController.add(_currentUser);
    return guest;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _authController.add(null);
  }
}

class FirebaseAuthService implements AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  AuthUser? _mapUser(fb.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      isGuest: user.isAnonymous,
    );
  }

  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.authStateChanges().map(_mapUser);

  @override
  AuthUser? get currentUser => _mapUser(_auth.currentUser);

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    try {
      final fb.UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapUser(cred.user)!;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication error');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<AuthUser> registerWithEmail(String email, String password) async {
    try {
      final fb.UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapUser(cred.user)!;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration error');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<AuthUser> signInAnonymously() async {
    try {
      final fb.UserCredential cred = await _auth.signInAnonymously();
      return _mapUser(cred.user)!;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Guest sign-in error');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

