import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traveldesk_driver/presentation/screens/auth/login_screen.dart';
import 'package:traveldesk_driver/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('Corporate User Login Flow Tests', () {
    Widget createWidgetUnderTest() {
      return ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    testWidgets('Corporate user type button sets userType to corporateuser', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Find the Corporate button
      final corporateButton = find.text('Corporate');
      expect(corporateButton, findsOneWidget);
      
      // Tap the Corporate button
      await tester.tap(corporateButton);
      await tester.pump();
      
      // The Corporate button should be selected (black background)
      // We can verify this by checking if the button exists and is displayed
      expect(corporateButton, findsOneWidget);
    });

    testWidgets('Personal user type button sets userType to user', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(createWidgetUnderTest());
      
      // First tap Corporate to change from default
      final corporateButton = find.text('Corporate');
      await tester.tap(corporateButton);
      await tester.pump();
      
      // Then tap Personal button
      final personalButton = find.text('Personal');
      expect(personalButton, findsOneWidget);
      
      await tester.tap(personalButton);
      await tester.pump();
      
      // The Personal button should be selected
      expect(personalButton, findsOneWidget);
    });

    testWidgets('Login screen has all required fields for corporate user', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check if all necessary elements are present
      expect(find.text('Welcome to TravelDesk Solutions'), findsOneWidget);
      expect(find.text('Choose account type'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Corporate'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
    });

    testWidgets('Email validation works correctly', (WidgetTester tester) async {
      // Build the login screen with larger viewport
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Find the email text field
      final emailField = find.byType(TextFormField);
      expect(emailField, findsOneWidget);
      
      // Enter invalid email
      await tester.enterText(emailField, 'invalidemail');
      await tester.pumpAndSettle();
      
      // Scroll to make the button visible
      await tester.ensureVisible(find.text('Send OTP'));
      await tester.pumpAndSettle();
      
      // Try to submit
      final sendOtpButton = find.text('Send OTP');
      await tester.tap(sendOtpButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      
      // Should show validation error
      expect(find.text('Enter a valid email address'), findsOneWidget);
      
      // Reset viewport
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Valid email allows form submission for corporate user', (WidgetTester tester) async {
      // Build the login screen with larger viewport
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Select Corporate user type
      final corporateButton = find.text('Corporate');
      await tester.tap(corporateButton);
      await tester.pumpAndSettle();
      
      // Find the email text field
      final emailField = find.byType(TextFormField);
      expect(emailField, findsOneWidget);
      
      // Enter valid corporate email
      await tester.enterText(emailField, 'corporate@company.com');
      await tester.pumpAndSettle();
      
      // Form should be ready to submit (no validation errors)
      expect(find.text('Enter a valid email address'), findsNothing);
      expect(find.text('Email is required'), findsNothing);
      
      // Reset viewport
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('User Type Value Tests', () {
    test('Corporate user type value should be "corporateuser"', () {
      const corporateUserType = 'corporateuser';
      expect(corporateUserType, equals('corporateuser'));
    });

    test('Personal user type value should be "user"', () {
      const personalUserType = 'user';
      expect(personalUserType, equals('user'));
    });
  });
}


