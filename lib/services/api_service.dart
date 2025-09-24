import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class ApiService {
  static Future<String> login(String companyId, String password) async {
    final url = Uri.parse('${Env.baseUrl}jezt/token/');
    final response = await http.post(
      url,
      body: {
        'company_id': companyId,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.containsKey('access')) {
        return data['access'];
      } else {
        throw Exception('Access token not found in login response');
      }
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> fetchDashboard(String accessToken) async {
    final url = Uri.parse('${Env.baseUrl}viewfromjson/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load dashboard: ${response.statusCode}');
    }
  }

  static Future<void> logout(String accessToken) async {
    final url = Uri.parse('${Env.baseUrl}logout/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Logout failed: ${response.statusCode}');
    }
  }
}