import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/env.dart';

class ApiService {
  static void _logApiCall(String method, String url, Map<String, String>? headers, String? body) {
    developer.log('API Call: $method $url', name: 'ApiService');
    if (headers != null) {
      developer.log('Headers: $headers', name: 'ApiService');
    }
    if (body != null) {
      developer.log('Body: $body', name: 'ApiService');
    }
  }

  static void _logApiResponse(int statusCode, String body) {
    developer.log('Response Status: $statusCode', name: 'ApiService');
    developer.log('Response Body: $body', name: 'ApiService');
  }

  static Future<String> login(String companyId, String password) async {
    try {
      final url = Uri.parse('${Env.baseUrl}jezt/token/');
      final body = {
        'company_id': companyId,
        'password': password,
      };

      _logApiCall('POST', url.toString(), null, body.toString());

      final response = await http.post(
        url,
        body: body,
      );

      _logApiResponse(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('access')) {
          developer.log('Login successful, token received', name: 'ApiService');
          return data['access'];
        } else {
          developer.log('Login response missing access token: ${data.keys}', name: 'ApiService');
          throw Exception('Access token not found in login response');
        }
      } else {
        developer.log('Login failed with status: ${response.statusCode}', name: 'ApiService');
        final errorBody = response.body.isNotEmpty ? response.body : 'No error message';
        throw Exception('Login failed: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      developer.log('Login exception: $e', name: 'ApiService');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchDashboard(String accessToken) async {
    try {
      final url = Uri.parse('${Env.baseUrl}viewfromjson/');
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      _logApiCall('GET', url.toString(), headers, null);

      final response = await http.get(
        url,
        headers: headers,
      );

      _logApiResponse(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('Dashboard data received: ${data.runtimeType}', name: 'ApiService');
        return data;
      } else if (response.statusCode == 401) {
        developer.log('Dashboard request unauthorized - token may be invalid', name: 'ApiService');
        throw Exception('Unauthorized: Please login again');
      } else {
        developer.log('Dashboard failed with status: ${response.statusCode}', name: 'ApiService');
        final errorBody = response.body.isNotEmpty ? response.body : 'No error message';
        throw Exception('Failed to load dashboard: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      developer.log('Dashboard exception: $e', name: 'ApiService');
      rethrow;
    }
  }

  static Future<void> logout(String accessToken) async {
    try {
      final url = Uri.parse('${Env.baseUrl}logout/');
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      _logApiCall('POST', url.toString(), headers, null);

      var response = await http.post(
        url,
        headers: headers,
      );

      _logApiResponse(response.statusCode, response.body);

      if (response.statusCode == 405) {
        developer.log('POST logout failed, trying GET', name: 'ApiService');
        _logApiCall('GET', url.toString(), headers, null);

        response = await http.get(
          url,
          headers: headers,
        );

        _logApiResponse(response.statusCode, response.body);
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        developer.log('Logout successful', name: 'ApiService');
        return;
      } else {
        developer.log('Logout failed with status: ${response.statusCode}', name: 'ApiService');
        final errorBody = response.body.isNotEmpty ? response.body : 'No error message';
        throw Exception('Logout failed: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      developer.log('Logout exception: $e', name: 'ApiService');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchDashboardAlternative(String accessToken) async {
    try {
      final url = Uri.parse('${Env.baseUrl}viewfromjson/');
      final headers = {
        'Authorization': 'Token $accessToken',
        'Content-Type': 'application/json',
      };

      _logApiCall('GET (Alternative)', url.toString(), headers, null);

      final response = await http.get(
        url,
        headers: headers,
      );

      _logApiResponse(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('Dashboard data received (alternative): ${data.runtimeType}', name: 'ApiService');
        return data;
      } else {
        throw Exception('Alternative dashboard fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Alternative dashboard exception: $e', name: 'ApiService');
      rethrow;
    }
  }
}