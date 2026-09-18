// File generated with project credentials from google-services.json
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgll71XkwFm3oHC2-JGCSC7kuL3Sj20wc',
    appId: '1:271409069457:android:08b9c3c7263d41c4ebee30',
    messagingSenderId: '271409069457',
    projectId: 'borekill-demo',
    storageBucket: 'borekill-demo.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDgll71XkwFm3oHC2-JGCSC7kuL3Sj20wc',
    appId: '1:271409069457:ios:08b9c3c7263d41c4ebee30',
    messagingSenderId: '271409069457',
    projectId: 'borekill-demo',
    storageBucket: 'borekill-demo.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDgll71XkwFm3oHC2-JGCSC7kuL3Sj20wc',
    appId: '1:271409069457:web:08b9c3c7263d41c4ebee30',
    messagingSenderId: '271409069457',
    projectId: 'borekill-demo',
    storageBucket: 'borekill-demo.firebasestorage.app',
  );
}

