import 'dart:convert';
import 'package:http/http.dart' as http;

class SupplierApiService {
  final String baseUrl;

  SupplierApiService({this.baseUrl = 'http://localhost:5000/api'});

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

  // GET: Get all suppliers
  Future<Map<String, dynamic>> getSuppliers({
    String? token,
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/suppliers');
    final queryParams = <String, String>{};

    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    if (search != null) queryParams['search'] = search;
    if (category != null) queryParams['category'] = category;

    final finalUri = uri.replace(queryParameters: queryParams);

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load suppliers: ${response.statusCode}');
    }
  }

  // GET: Get single supplier
  Future<Map<String, dynamic>> getSupplier({
    required String id,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.get(Uri.parse('$baseUrl/suppliers/$id'), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? data;
    } else {
      throw Exception('Failed to load supplier: ${response.statusCode}');
    }
  }

  // POST: Create supplier
  Future<Map<String, dynamic>> createSupplier({
    required Map<String, dynamic> data,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.post(
      Uri.parse('$baseUrl/suppliers'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return responseData['data'] ?? responseData;
    } else {
      throw Exception('Failed to create supplier: ${response.statusCode}');
    }
  }

  // PUT: Update supplier
  Future<Map<String, dynamic>> updateSupplier({
    required String id,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.put(
      Uri.parse('$baseUrl/suppliers/$id'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data'] ?? responseData;
    } else {
      throw Exception('Failed to update supplier: ${response.statusCode}');
    }
  }

  // DELETE: Delete supplier
  Future<void> deleteSupplier({
    required String id,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.delete(Uri.parse('$baseUrl/suppliers/$id'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete supplier: ${response.statusCode}');
    }
  }
}
