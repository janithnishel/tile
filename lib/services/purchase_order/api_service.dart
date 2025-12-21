import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tilework/models/purchase_order/purchase_order.dart';

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

  // GET: Fetch all purchase orders
  Future<Map<String, dynamic>> getAllPurchaseOrders({
    String? token,
    Map<String, String>? queryParams,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/purchase-orders');
    final finalUri = queryParams != null ? uri.replace(queryParameters: queryParams) : uri;

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load purchase orders: ${response.statusCode}');
    }
  }

  // GET: Fetch single purchase order
  Future<Map<String, dynamic>> getPurchaseOrder(String id, {String? token}) async {
    final headers = await _getHeaders(token: token);
    final response = await http.get(Uri.parse('$baseUrl/purchase-orders/$id'), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load purchase order: ${response.statusCode}');
    }
  }

  // POST: Create purchase order
  Future<Map<String, dynamic>> createPurchaseOrder(
    Map<String, dynamic> purchaseOrderData, {
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.post(
      Uri.parse('$baseUrl/purchase-orders'),
      headers: headers,
      body: json.encode(purchaseOrderData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create purchase order: ${response.statusCode} - ${response.body}');
    }
  }

  // PUT: Update purchase order
  Future<Map<String, dynamic>> updatePurchaseOrder(
    String id,
    Map<String, dynamic> purchaseOrderData, {
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.put(
      Uri.parse('$baseUrl/purchase-orders/$id'),
      headers: headers,
      body: json.encode(purchaseOrderData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update purchase order: ${response.statusCode}');
    }
  }

  // DELETE: Delete purchase order
  Future<void> deletePurchaseOrder(String id, {String? token}) async {
    final headers = await _getHeaders(token: token);
    final response = await http.delete(Uri.parse('$baseUrl/purchase-orders/$id'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete purchase order: ${response.statusCode}');
    }
  }

  // PATCH: Update purchase order status
  Future<Map<String, dynamic>> updatePurchaseOrderStatus(
    String id,
    Map<String, dynamic> statusData, {
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.patch(
      Uri.parse('$baseUrl/purchase-orders/$id/status'),
      headers: headers,
      body: json.encode(statusData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update purchase order status: ${response.statusCode}');
    }
  }

  // POST: Upload invoice image
  Future<Map<String, dynamic>> uploadInvoiceImage(
    String id,
    String filePath, {
    String? token,
  }) async {
    final currentToken = token ?? await _getToken();
    if (currentToken == null) {
      throw Exception('No authentication token available');
    }

    // Create multipart request for file upload
    final uri = Uri.parse('$baseUrl/purchase-orders/$id/invoice-image');
    final request = http.MultipartRequest('POST', uri);

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $currentToken';

    // Add file to request
    request.files.add(await http.MultipartFile.fromPath('invoice', filePath));

    // Use a timeout for the file upload
    final response = await request.send().timeout(const Duration(seconds: 30));
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseData);
    } else {
      throw Exception('Failed to upload invoice image: ${response.statusCode} - $responseData');
    }
  }

  // PUT: Update delivery verification
  Future<Map<String, dynamic>> updateDeliveryVerification(
    String id,
    List<Map<String, dynamic>> deliveryItems, {
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.put(
      Uri.parse('$baseUrl/purchase-orders/$id/delivery-verification'),
      headers: headers,
      body: json.encode({'deliveryItems': deliveryItems}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update delivery verification: ${response.statusCode}');
    }
  }
}
