import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://cloud.jezt.tech/api/';

  // Login API
  static Future<Map<String, dynamic>> login(String companyId, String password) async {
    final url = Uri.parse('${baseUrl}jezt/token/');
    final response = await http.post(url, body: {
      'company_id': companyId,
      'password': password,
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }

  // Dashboard API
  static Future<List<dynamic>> fetchDashboard() async {
    final url = Uri.parse('${baseUrl}viewfromjson/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load dashboard');
    }
  }

  // Logout API
  static Future<void> logout() async {
    final url = Uri.parse('${baseUrl}logout/');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Logout failed');
    }
  }
}
