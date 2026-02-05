// Generated placeholder Firebase options.
// Run `flutterfire configure` to generate real values for your project.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      // case TargetPlatform.macOS:
      //   return macos;
      // case TargetPlatform.windows:
      //   return windows;
      // case TargetPlatform.linux:
      //   return linux;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  // ----- Replace these placeholder values by running `flutterfire configure` -----
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyASHkuHVT7tV5rSbBNOMfFkTROUyDMfdT4',
    appId: '1:456204258662:web:REPLACE_ME',
    messagingSenderId: '456204258662',
    projectId: 'tdsdriver',
    authDomain: 'tdsdriver.firebaseapp.com',
    storageBucket: 'tdsdriver.firebasestorage.app',
    measurementId: null,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyASHkuHVT7tV5rSbBNOMfFkTROUyDMfdT4',
    appId: '1:456204258662:android:6cb80575b56c970523cca7',
    messagingSenderId: '456204258662',
    projectId: 'tdsdriver',
    storageBucket: 'tdsdriver.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA1T13rHt5sZBgVdFCyqbw4AHGeGMLFsnk',
    appId: '1:456204258662:ios:8925df0805e15ec923cca7',
    messagingSenderId: '456204258662',
    projectId: 'tdsdriver',
    storageBucket: 'tdsdriver.firebasestorage.app',
    iosBundleId: 'com.traveldesk.driver',
  );

  // macOS / Windows / Linux fall back to the same values as iOS/android where appropriate
  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = android;
  static const FirebaseOptions linux = android;
}