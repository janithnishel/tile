import 'dart:convert';
import 'package:http/http.dart' as http;

class MaterialSaleApiService {
  final String baseUrl;

  MaterialSaleApiService({this.baseUrl = 'http://localhost:5000/api'});

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

  // GET: Get all material sales
  Future<Map<String, dynamic>> getMaterialSales({
    String? token,
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/material-sales');
    final queryParams = <String, String>{};

    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final finalUri = uri.replace(queryParameters: queryParams);

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load material sales: ${response.statusCode}');
    }
  }

  // GET: Get single material sale
  Future<Map<String, dynamic>> getMaterialSale({
    required String id,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.get(Uri.parse('$baseUrl/material-sales/$id'), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? data;
    } else {
      throw Exception('Failed to load material sale: ${response.statusCode}');
    }
  }

  // POST: Create material sale
  Future<Map<String, dynamic>> createMaterialSale({
    required Map<String, dynamic> data,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.post(
      Uri.parse('$baseUrl/material-sales'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return responseData['data'] ?? responseData;
    } else {
      throw Exception('Failed to create material sale: ${response.statusCode}');
    }
  }

  // PUT: Update material sale
  Future<Map<String, dynamic>> updateMaterialSale({
    required String id,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.put(
      Uri.parse('$baseUrl/material-sales/$id'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data'] ?? responseData;
    } else {
      throw Exception('Failed to update material sale: ${response.statusCode}');
    }
  }

  // POST: Add payment
  Future<Map<String, dynamic>> addPayment({
    required String id,
    required Map<String, dynamic> paymentData,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.post(
      Uri.parse('$baseUrl/material-sales/$id/payments'),
      headers: headers,
      body: json.encode(paymentData),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data'] ?? responseData;
    } else {
      throw Exception('Failed to add payment: ${response.statusCode}');
    }
  }

  // PATCH: Update status
  Future<Map<String, dynamic>> updateStatus({
    required String id,
    required String status,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.patch(
      Uri.parse('$baseUrl/material-sales/$id/status'),
      headers: headers,
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data'] ?? responseData;
    } else {
      throw Exception('Failed to update status: ${response.statusCode}');
    }
  }

  // DELETE: Delete material sale
  Future<void> deleteMaterialSale({
    required String id,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.delete(Uri.parse('$baseUrl/material-sales/$id'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete material sale: ${response.statusCode}');
    }
  }

  // GET: Search customer by phone number
  Future<Map<String, dynamic>> searchCustomerByPhone({
    required String phone,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/material-sales/search-customer');
    final queryParams = {'phone': phone};
    final finalUri = uri.replace(queryParameters: queryParams);

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to search customer: ${response.statusCode}');
    }
  }
}
