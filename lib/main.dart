import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'core/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
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
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      } else {
        // For mobile/desktop, initialize with the best-available options.
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
    } catch (e) {
      // If Firebase initialization fails, log and continue so app can still run.
      print('Firebase.initializeApp() failed in main: $e');
    }

    // Ensure any existing Firebase user is signed out, then initialize services
    try {
      await FirebaseAuth.instance.signOut();
      print('✅ Signed out existing Firebase user at startup');
    } catch (e) {
      print('⚠️ Error signing out existing Firebase user: $e');
    }

    // Initialize Firebase-related services (assumes Firebase has been initialized above)
    final firebaseService = FirebaseService();
    await firebaseService.initializeFirebase().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        print('Firebase service initialization timed out, continuing without Firebase messaging');
      },
    ).catchError((e) {
      print('Firebase service initialization failed: $e, continuing without Firebase messaging');
    });
    firebaseService.setNavigatorKey(navigatorKey);

    runApp(const MyApp());
  } catch (e) {
    print('Error in main: $e');
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



