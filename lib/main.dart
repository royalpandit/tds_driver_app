import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/firebase_service.dart';
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

    // Initialize Firebase
    final firebaseService = FirebaseService();
    await firebaseService.initializeFirebase().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        print('Firebase initialization timed out, continuing without Firebase');
      },
    ).catchError((e) {
      print('Firebase initialization failed: $e, continuing without Firebase');
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



