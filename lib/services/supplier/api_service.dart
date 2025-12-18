import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/purchase_order/supplier.dart';

class SupplierApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  // Supplier endpoints
  static const String suppliersEndpoint = '/suppliers';

  final http.Client _client;

  SupplierApiService({http.Client? client}) : _client = client ?? http.Client();

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

  // Get all suppliers
  Future<List<Supplier>> getSuppliers({String? token, String? search, String? category}) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final uri = Uri.parse('$baseUrl$suppliersEndpoint').replace(queryParameters: queryParams);
      final headers = _getHeaders(token);

      final response = await _client.get(uri, headers: headers);
      final responseData = _handleResponse(response);

      // Assuming the response has a 'data' field with the list of suppliers
      final suppliersData = responseData['data'] ?? responseData;
      if (suppliersData is List) {
        return suppliersData.map((json) => Supplier.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Failed to get suppliers: $e');
    }
  }

  // Get single supplier
  Future<Supplier> getSupplier(String id, {String? token}) async {
    try {
      final responseData = await get('$suppliersEndpoint/$id', token: token);
      final supplierData = responseData['data'] ?? responseData;
      return Supplier.fromJson(supplierData);
    } catch (e) {
      throw Exception('Failed to get supplier: $e');
    }
  }

  // Create supplier
  Future<Supplier> createSupplier(Supplier supplier, {String? token}) async {
    try {
      final responseData = await post(suppliersEndpoint, supplier.toJson(), token: token);
      final supplierData = responseData['data'] ?? responseData;
      return Supplier.fromJson(supplierData);
    } catch (e) {
      throw Exception('Failed to create supplier: $e');
    }
  }

  // Update supplier
  Future<Supplier> updateSupplier(String id, Supplier supplier, {String? token}) async {
    try {
      final responseData = await put('$suppliersEndpoint/$id', supplier.toJson(), token: token);
      final supplierData = responseData['data'] ?? responseData;
      return Supplier.fromJson(supplierData);
    } catch (e) {
      throw Exception('Failed to update supplier: $e');
    }
  }

  // Delete supplier
  Future<void> deleteSupplier(String id, {String? token}) async {
    try {
      await delete('$suppliersEndpoint/$id', token: token);
    } catch (e) {
      throw Exception('Failed to delete supplier: $e');
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
