import 'dart:convert';
import 'package:http/http.dart' as http;

class MaterialSaleApiService {
  static const String baseUrl = 'http://localhost:5000/api'; // Update this to your backend URL

  // Material Sale endpoints
  static const String materialSalesEndpoint = '/material-sales';

  final http.Client _client;

  MaterialSaleApiService({http.Client? client}) : _client = client ?? http.Client();

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint, {String? token, Map<String, String>? queryParams}) async {
    try {
      final headers = _getHeaders(token);
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: headers);

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

  // Get all material sales
  Future<Map<String, dynamic>> getAllMaterialSales({String? token, Map<String, String>? queryParams}) async {
    return await get(materialSalesEndpoint, token: token, queryParams: queryParams);
  }

  // Get single material sale
  Future<Map<String, dynamic>> getMaterialSale(String id, {String? token}) async {
    return await get('$materialSalesEndpoint/$id', token: token);
  }

  // Create material sale
  Future<Map<String, dynamic>> createMaterialSale(Map<String, dynamic> data, {String? token}) async {
    return await post(materialSalesEndpoint, data, token: token);
  }

  // Update material sale
  Future<Map<String, dynamic>> updateMaterialSale(String id, Map<String, dynamic> data, {String? token}) async {
    return await put('$materialSalesEndpoint/$id', data, token: token);
  }

  // Delete material sale
  Future<Map<String, dynamic>> deleteMaterialSale(String id, {String? token}) async {
    return await delete('$materialSalesEndpoint/$id', token: token);
  }

  // Add payment
  Future<Map<String, dynamic>> addPayment(String id, Map<String, dynamic> paymentData, {String? token}) async {
    return await post('$materialSalesEndpoint/$id/payments', paymentData, token: token);
  }

  // Update status
  Future<Map<String, dynamic>> updateStatus(String id, Map<String, dynamic> statusData, {String? token}) async {
    return await put('$materialSalesEndpoint/$id/status', statusData, token: token);
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
