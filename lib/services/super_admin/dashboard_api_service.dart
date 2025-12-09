import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardApiService {
  static const String baseUrl = 'http://localhost:5000/api'; // Update this to your backend URL

  // Dashboard endpoints
  static const String dashboardStatsEndpoint = '/super-admin/dashboard/stats';

  final http.Client _client;

  DashboardApiService({http.Client? client}) : _client = client ?? http.Client();

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    try {
      final headers = _getHeaders(token);
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // =================== DASHBOARD API METHODS ===================

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats({String? token}) async {
    return await get(dashboardStatsEndpoint, token: token);
  }

  // Helper methods
  Map<String, String> _getHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'API Error: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}
