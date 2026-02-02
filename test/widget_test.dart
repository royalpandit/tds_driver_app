import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:traveldesk_driver/presentation/providers/auth_provider.dart';
import 'package:traveldesk_driver/presentation/providers/driver_provider.dart';
import 'package:traveldesk_driver/presentation/screens/auth/login_screen.dart';
import 'package:traveldesk_driver/presentation/screens/main_screen.dart';

void main() {
  Widget createWidgetUnderTest(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('LoginScreen has email and user type fields', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const LoginScreen()));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email or Phone'), findsOneWidget);
    expect(find.text('User Type'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
  });

  testWidgets('MainScreen has bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const MainScreen()));

    // Check for Bottom Navigation
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
    
    // Tap More tab
    await tester.tap(find.text('More'));
    await tester.pump(); // Use pump instead of pumpAndSettle to avoid timeout from Map widget

    // Check content of More screen
    expect(find.text('About Us'), findsOneWidget);
    expect(find.text('Contact Us'), findsOneWidget);
  });
}


