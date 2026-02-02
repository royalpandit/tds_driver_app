import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:traveldesk_driver/core/constants/api_constants.dart';
import 'package:traveldesk_driver/data/services/api_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ApiService Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    test('sendOtp returns success when API call is successful', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == '${ApiConstants.baseUrl}${ApiConstants.sendOtp}') {
          return http.Response(jsonEncode({'success': true, 'message': 'OTP sent'}), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: client);
      final result = await apiService.sendOtp('user@example.com', 'user', 'login');

      expect(result['success'], true);
      expect(result['message'], 'OTP sent');
    });

    test('verifyOtp returns success when API call is successful', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == '${ApiConstants.baseUrl}${ApiConstants.verifyOtp}') {
          return http.Response(jsonEncode({'success': true, 'message': 'Login successful'}), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: client);
      final result = await apiService.verifyOtp('user@example.com', '123456', 'user');

      expect(result['success'], true);
      expect(result['message'], 'Login successful');
    });

    test('getCabBooking returns vehicle types', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == '${ApiConstants.baseUrl}${ApiConstants.cabBooking}') {
          return http.Response(jsonEncode({
            'success': true,
            'data': {
              'vehicle_types': [
                {'id': 1, 'name': 'Economy', 'display_name': 'Economy Class', 'seats': 4, 'description': 'Budget', 'image': 'url', 'transfer_details': [], 'status': true}
              ]
            }
          }), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: client);
      final result = await apiService.getCabBooking();

      expect(result['success'], true);
      expect(result['data']['vehicle_types'].length, 1);
    });

    test('login returns success when API call is successful', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == '${ApiConstants.baseUrl}${ApiConstants.login}') {
          return http.Response(jsonEncode({
            'status': true,
            'code': 200,
            'message': 'Login successful',
            'data': {
              'user': {
                'id': 1,
                'name': 'John Doe',
                'email': 'user@example.com',
                'phone': '1234567890',
                'api_token': 'abcdef123456'
              }
            }
          }), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: client);
      final result = await apiService.login('user@example.com', '123456');

      expect(result['status'], true);
      expect(result['data']['user']['api_token'], 'abcdef123456');
    });

    test('resendOtp returns success when API call is successful', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == '${ApiConstants.baseUrl}${ApiConstants.resendOtp}') {
          return http.Response(jsonEncode({'success': true, 'message': 'OTP resent successfully'}), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: client);
      final result = await apiService.resendOtp('user@example.com', 'user', 'login');

      expect(result['success'], true);
      expect(result['message'], 'OTP resent successfully');
    });
  });
}


