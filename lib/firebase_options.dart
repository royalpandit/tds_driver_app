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
    apiKey: 'AIzaSyAC3CxXeD5y6KqHnHgyznyPlIy4wjvFaPY',
    appId: '1:552039310635:web:REPLACE_ME',
    messagingSenderId: '552039310635',
    projectId: 'tds-soln',
    authDomain: 'tds-soln.firebaseapp.com',
    storageBucket: 'tds-soln.firebasestorage.app',
    measurementId: null,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAC3CxXeD5y6KqHnHgyznyPlIy4wjvFaPY',
    appId: '1:552039310635:android:a1387094bdc6a9dcfa116e',
    messagingSenderId: '552039310635',
    projectId: 'tds-soln',
    storageBucket: 'tds-soln.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAC3CxXeD5y6KqHnHgyznyPlIy4wjvFaPY',
    appId: '1:552039310635:ios:REPLACE_ME',
    messagingSenderId: '552039310635',
    projectId: 'tds-soln',
    storageBucket: 'tds-soln.firebasestorage.app',
    iosBundleId: 'com.traveldesk.driver',
  );

  // macOS / Windows / Linux fall back to the same values as iOS/android where appropriate
  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = android;
  static const FirebaseOptions linux = android;
}