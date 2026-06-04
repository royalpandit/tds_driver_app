 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
 import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
 import 'package:package_info_plus/package_info_plus.dart';
import 'package:traveldesk_driver/presentation/providers/auth_provider.dart';
 import 'core/services/firebase_service.dart';
import 'data/services/api_service.dart';
 import 'core/theme/app_theme.dart';
 import 'package:firebase_auth/firebase_auth.dart' as fb;

 import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/driver_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

// Global navigator key for Firebase navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase at app startup so the default app exists.
    // Use `DefaultFirebaseOptions.currentPlatform` for web and platforms when available.
    /*await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );*/
    await Firebase.initializeApp();
   /* try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        await Firebase.initializeApp();
      }
    } catch (e) {
      // If Firebase initialization fails, log and continue so app can still run.
      debugPrint('Firebase.initializeApp() failed in main: $e');

    }*/
    /*try {
      if (kIsWeb) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      } else {
        // For mobile/desktop, initialize with the best-available options.
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
    } catch (e) {
      // If Firebase initialization fails, log and continue so app can still run.
      debugPrint('Firebase.initializeApp() failed in main: $e');
    }*/

    // Ensure any existing Firebase user is signed out, then initialize services
    try {
      await fb.FirebaseAuth.instance.signOut();
      debugPrint('✅ Signed out existing Firebase user at startup');
    } catch (e) {
      debugPrint('⚠️ Error signing out existing Firebase user: $e');
    }

    // Initialize Firebase-related services (assumes Firebase has been initialized above)
    final firebaseService = FirebaseService();
    await firebaseService.initializeFirebase().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        debugPrint('Firebase service initialization timed out, continuing without Firebase messaging');
      },
    ).catchError((e) {
      debugPrint('Firebase service initialization failed: $e, continuing without Firebase messaging');
    });
    firebaseService.setNavigatorKey(navigatorKey);

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final apiService = ApiService();
      final platform = kIsWeb
          ? 'web'
          : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');

      if (platform == 'android' || platform == 'ios') {
        await apiService.storeAppSetting(
          type: 'driver_app_version',
          platform: platform,
          value: packageInfo.version,
        );
      }
    } catch (e) {
      debugPrint('Failed to persist app version on startup: $e');
    }

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error in main: $e');
    // Fallback: run app without Firebase
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Traveldesk',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
          );
        },
      ),
    );
  }
}



