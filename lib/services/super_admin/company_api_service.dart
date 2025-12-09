import 'dart:convert';
import 'package:http/http.dart' as http;

class CompanyApiService {
  static const String baseUrl = 'http://localhost:5000/api'; // Update this to your backend URL

  // Company endpoints
  static const String companiesEndpoint = '/super-admin/companies';

  final http.Client _client;

  CompanyApiService({http.Client? client}) : _client = client ?? http.Client();

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

  // Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data, {String? token}) async {
    try {
      final headers = _getHeaders(token);
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    try {
      final headers = _getHeaders(token);
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get all companies
  Future<Map<String, dynamic>> getAllCompanies({String? token}) async {
    return await get(companiesEndpoint, token: token);
  }

  // Update a company
  Future<Map<String, dynamic>> updateCompany(String id, Map<String, dynamic> data, {String? token}) async {
    return await put('$companiesEndpoint/$id', data, token: token);
  }

  // Delete a company
  Future<Map<String, dynamic>> deleteCompany(String id, {String? token}) async {
    return await delete('$companiesEndpoint/$id', token: token);
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {String? token}) async {
    try {
      final headers = _getHeaders(token);
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
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
