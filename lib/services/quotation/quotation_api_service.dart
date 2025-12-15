import 'dart:convert';
import 'package:http/http.dart' as http;

class QuotationApiService {
  static const String baseUrl = 'http://localhost:5000/api'; // Update this to your backend URL

  // Quotation endpoints
  static const String quotationsEndpoint = '/quotations';

  final http.Client _client;

  QuotationApiService({http.Client? client}) : _client = client ?? http.Client();

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

  // Generic PATCH request
  Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> data, {String? token}) async {
    try {
      final headers = _getHeaders(token);
      final response = await _client.patch(
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

  // Get all quotations
  Future<Map<String, dynamic>> getAllQuotations({String? token, Map<String, String>? queryParams}) async {
    String endpoint = quotationsEndpoint;
    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      endpoint = '$endpoint?$queryString';
    }
    return await get(endpoint, token: token);
  }

  // Create a new quotation
  Future<Map<String, dynamic>> createQuotation(Map<String, dynamic> data, {String? token}) async {
    return await post(quotationsEndpoint, data, token: token);
  }

  // Update a quotation
  Future<Map<String, dynamic>> updateQuotation(String id, Map<String, dynamic> data, {String? token}) async {
    return await put('$quotationsEndpoint/$id', data, token: token);
  }

  // Delete a quotation
  Future<Map<String, dynamic>> deleteQuotation(String id, {String? token}) async {
    return await delete('$quotationsEndpoint/$id', token: token);
  }

  // Add payment to quotation
  Future<Map<String, dynamic>> addPayment(String id, Map<String, dynamic> paymentData, {String? token}) async {
    return await post('$quotationsEndpoint/$id/payments', paymentData, token: token);
  }

  // Convert quotation to invoice
  Future<Map<String, dynamic>> convertToInvoice(String id, {String? token}) async {
    print('🔄 API Service: Converting quotation $id to invoice');
    print('🔑 API Service: Token provided: ${token != null ? "Yes (${token.substring(0, 20)}...)" : "No"}');
    return await patch('$quotationsEndpoint/$id/convert-to-invoice', {}, token: token);
  }

  // Update quotation status
  Future<Map<String, dynamic>> updateQuotationStatus(String id, Map<String, dynamic> statusData, {String? token}) async {
    return await patch('$quotationsEndpoint/$id/status', statusData, token: token);
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
