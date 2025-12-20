import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardApiService {
  final String baseUrl;

  DashboardApiService({this.baseUrl = 'http://localhost:5000/api'});

  // Helper method to get auth token from local storage or wherever it's stored
  Future<String?> _getToken() async {
    // TODO: Implement token retrieval from secure storage
    // For now, return null - the actual token should be passed from the cubit
    return null;
  }

  // Helper method to get common headers
  Future<Map<String, String>> _getHeaders({String? token}) async {
    final currentToken = token ?? await _getToken();
    if (currentToken == null) {
      throw Exception('No authentication token available');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $currentToken',
    };
  }

  // GET: Dashboard Statistics
  Future<Map<String, dynamic>> getDashboardStats({
    String? token,
    String? period,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/dashboard/stats');
    final queryParams = <String, String>{};

    if (period != null) queryParams['period'] = period;

    final finalUri = queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams)
        : uri;

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load dashboard stats: ${response.statusCode}');
    }
  }

  // GET: Revenue Trend Chart Data
  Future<List<dynamic>> getRevenueTrend({
    String? token,
    String? period,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/dashboard/charts/revenue-trend');
    final queryParams = <String, String>{};

    if (period != null) queryParams['period'] = period;

    final finalUri = queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams)
        : uri;

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load revenue trend: ${response.statusCode}');
    }
  }

  // GET: Profit Breakdown Chart Data
  Future<List<dynamic>> getProfitBreakdown({
    String? token,
    String? period,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/dashboard/charts/profit-breakdown');
    final queryParams = <String, String>{};

    if (period != null) queryParams['period'] = period;

    final finalUri = queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams)
        : uri;

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load profit breakdown: ${response.statusCode}');
    }
  }

  // GET: Actionable Items
  Future<Map<String, dynamic>> getActionableItems({String? token}) async {
    final headers = await _getHeaders(token: token);
    final response = await http.get(Uri.parse('$baseUrl/dashboard/actionable-items'), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load actionable items: ${response.statusCode}');
    }
  }
}
