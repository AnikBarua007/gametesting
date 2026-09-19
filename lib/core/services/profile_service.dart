import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

abstract class ProfileService {
  static ProfileService instance = MockProfileService();

  Future<UserProfile?> getProfile(String uid);
  UserProfile? getProfileSync(String uid);
  Stream<UserProfile?> watchProfile(String uid);
  Future<void> saveProfile(UserProfile profile);
  Future<void> updateStatus(String uid, String status);
}

class MockProfileService implements ProfileService {
  @override
  UserProfile? getProfileSync(String uid) => _profiles[uid];

  final Map<String, UserProfile> _profiles = <String, UserProfile>{
    'user_playpal_001': UserProfile(
      uid: 'user_playpal_001',
      displayName: 'ShadowStriker',
      email: 'player@playpal.com',
      avatarId: 'avatar_ninja',
      bio: 'Master of deception in Hidden Hand.',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastActive: DateTime.now(),
      stats: const PlayerStats(gamesPlayed: 54, wins: 38, favoriteGame: 'hidden-hand'),
    ),
    'user_progamer_002': UserProfile(
      uid: 'user_progamer_002',
      displayName: 'NeonValkyrie',
      email: 'pro@gamer.com',
      avatarId: 'avatar_cyber',
      bio: 'Fastest sketcher in town!',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      lastActive: DateTime.now(),
      stats: const PlayerStats(gamesPlayed: 82, wins: 56, favoriteGame: 'sketch-party'),
    ),
  };

  final Map<String, StreamController<UserProfile?>> _controllers =
      <String, StreamController<UserProfile?>>{};

  StreamController<UserProfile?> _getController(String uid) {
    return _controllers.putIfAbsent(
      uid,
      () => StreamController<UserProfile?>.broadcast(),
    );
  }

  @override
  Future<UserProfile?> getProfile(String uid) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _profiles[uid];
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    final StreamController<UserProfile?> controller = _getController(uid);
    // Emit current value immediately if available
    Future<void>.microtask(() {
      if (!controller.isClosed) {
        controller.add(_profiles[uid]);
      }
    });
    return controller.stream;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _profiles[profile.uid] = profile;
    _getController(profile.uid).add(profile);
  }

  @override
  Future<void> updateStatus(String uid, String status) async {
    final UserProfile? current = _profiles[uid];
    if (current != null) {
      final UserProfile updated = current.copyWith(
        status: status,
        lastActive: DateTime.now(),
      );
      _profiles[uid] = updated;
      _getController(uid).add(updated);
    }
  }
}

class FirestoreProfileService implements ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, UserProfile> _cache = <String, UserProfile>{};

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  UserProfile? getProfileSync(String uid) => _cache[uid];

  @override
  Future<UserProfile?> getProfile(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _users.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      final UserProfile profile = UserProfile.fromMap(doc.data()!);
      _cache[uid] = profile;
      return profile;
    } catch (_) {
      return _cache[uid];
    }
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    if (uid.isEmpty) return Stream<UserProfile?>.value(null);
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      final UserProfile profile = UserProfile.fromMap(doc.data()!);
      _cache[uid] = profile;
      return profile;
    });
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _cache[profile.uid] = profile;
    await _users.doc(profile.uid).set(
          profile.toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> updateStatus(String uid, String status) async {
    if (uid.isEmpty) return;
    try {
      await _users.doc(uid).update(<String, dynamic>{
        'status': status,
        'lastActive': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }
}
