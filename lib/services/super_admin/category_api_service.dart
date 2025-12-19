import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryApiService {
  static const String baseUrl = 'http://localhost:5000/api'; // Update this to your backend URL

  // Category endpoints
  static const String categoriesEndpoint = '/categories';

  final http.Client _client;

  CategoryApiService({http.Client? client}) : _client = client ?? http.Client();

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

  // =================== CATEGORY API METHODS ===================

  // Get all categories for current company
  Future<Map<String, dynamic>> getCategories({String? token, String? companyId}) async {
    final endpoint = companyId != null ? '/super-admin/companies/$companyId/categories' : categoriesEndpoint;
    return await get(endpoint, token: token);
  }

  // Create new category
  Future<Map<String, dynamic>> createCategory(String name, {String? token, String? companyId}) async {
    final data = {'name': name};
    if (companyId != null) {
      data['companyId'] = companyId;
    }
    return await post(categoriesEndpoint, data, token: token);
  }

  // Update category
  Future<Map<String, dynamic>> updateCategory(String id, String name, {String? token}) async {
    return await put('$categoriesEndpoint/$id', {'name': name}, token: token);
  }

  // Delete category
  Future<Map<String, dynamic>> deleteCategory(String id, {String? token}) async {
    return await delete('$categoriesEndpoint/$id', token: token);
  }

  // =================== ITEM CONFIGURATIONS ===================

  // Get item configurations (units and pricing logic)
  Future<Map<String, dynamic>> getItemConfigs({String? token}) async {
    return await get('/super-admin/item-configs', token: token);
  }

  // =================== ITEM API METHODS ===================

  // Add item to category
  Future<Map<String, dynamic>> addItemToCategory(
    String categoryId,
    String itemName,
    String baseUnit,
    String? packagingUnit,
    double sqftPerUnit,
    bool isService,
    String? pricingType, {
    String? token
  }) async {
    final data = {
      'itemName': itemName,
      'baseUnit': baseUnit,
      'sqftPerUnit': sqftPerUnit,
      'isService': isService,
    };

    if (packagingUnit != null) {
      data['packagingUnit'] = packagingUnit;
    }

    if (pricingType != null) {
      data['pricingType'] = pricingType;
    }

    return await post('$categoriesEndpoint/$categoryId/items', data, token: token);
  }

  // Update item
  Future<Map<String, dynamic>> updateItem(
    String categoryId,
    String itemId,
    String itemName,
    String baseUnit,
    String? packagingUnit,
    double sqftPerUnit,
    bool isService,
    String? pricingType, {
    String? token
  }) async {
    final data = {
      'itemName': itemName,
      'baseUnit': baseUnit,
      'sqftPerUnit': sqftPerUnit,
      'isService': isService,
    };

    if (packagingUnit != null) {
      data['packagingUnit'] = packagingUnit;
    }

    if (pricingType != null) {
      data['pricingType'] = pricingType;
    }

    return await put('$categoriesEndpoint/$categoryId/items/$itemId', data, token: token);
  }

  // Delete item
  Future<Map<String, dynamic>> deleteItem(String categoryId, String itemId, {String? token}) async {
    return await delete('$categoriesEndpoint/$categoryId/items/$itemId', token: token);
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
