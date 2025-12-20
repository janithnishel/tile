import 'dart:convert';
import 'package:http/http.dart' as http;

class PurchaseOrderApiService {
  final String baseUrl;

  PurchaseOrderApiService({this.baseUrl = 'http://localhost:5000/api'});

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

  // GET: Get all purchase orders
  Future<Map<String, dynamic>> getPurchaseOrders({
    String? token,
    int page = 1,
    int limit = 10,
    String? status,
    String? supplier,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/purchase-orders');
    final queryParams = <String, String>{};

    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    if (status != null) queryParams['status'] = status;
    if (supplier != null) queryParams['supplier'] = supplier;
    if (search != null) queryParams['search'] = search;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final finalUri = uri.replace(queryParameters: queryParams);

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load purchase orders: ${response.statusCode}');
    }
  }

  // GET: Get single purchase order
  Future<Map<String, dynamic>> getPurchaseOrder({
    required String id,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.get(Uri.parse('$baseUrl/purchase-orders/$id'), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? data;
    } else {
      throw Exception('Failed to load purchase order: ${response.statusCode}');
    }
  }

  // POST: Create purchase order
  Future<Map<String, dynamic>> createPurchaseOrder({
    required Map<String, dynamic> data,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.post(
      Uri.parse('$baseUrl/purchase-orders'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return responseData['data'] ?? responseData;
    } else {
      throw Exception('Failed to create purchase order: ${response.statusCode}');
    }
  }

  // PUT: Update purchase order
  Future<Map<String, dynamic>> updatePurchaseOrder({
    required String id,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.put(
      Uri.parse('$baseUrl/purchase-orders/$id'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data'] ?? responseData;
    } else {
      throw Exception('Failed to update purchase order: ${response.statusCode}');
    }
  }

  // PATCH: Update purchase order status
  Future<Map<String, dynamic>> updateStatus({
    required String id,
    required String status,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.patch(
      Uri.parse('$baseUrl/purchase-orders/$id/status'),
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

  // DELETE: Delete purchase order
  Future<void> deletePurchaseOrder({
    required String id,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.delete(Uri.parse('$baseUrl/purchase-orders/$id'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete purchase order: ${response.statusCode}');
    }
  }

  // POST: Upload invoice image
  Future<Map<String, dynamic>> uploadInvoiceImage({
    required String id,
    required String filePath,
    String? token,
  }) async {
    // Note: File upload requires multipart/form-data, this is a simplified version
    // In a real implementation, you'd use http.MultipartRequest
    final headers = await _getHeaders(token: token);
    // This is a placeholder - actual file upload implementation would be more complex
    final response = await http.post(
      Uri.parse('$baseUrl/purchase-orders/$id/invoice-image'),
      headers: headers,
      body: json.encode({'filePath': filePath}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data'] ?? responseData;
    } else {
      throw Exception('Failed to upload invoice image: ${response.statusCode}');
    }
  }
}
