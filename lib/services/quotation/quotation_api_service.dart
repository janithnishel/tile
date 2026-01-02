import 'dart:convert';
import 'package:http/http.dart' as http;

class QuotationApiService {
  final String baseUrl;

  QuotationApiService({this.baseUrl = 'http://localhost:5000/api'});

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

  // GET: Get all quotations/invoices
  Future<Map<String, dynamic>> getQuotations({
    String? token,
    int page = 1,
    int limit = 10,
    String? type,
    String? status,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/quotations');
    final queryParams = <String, String>{};

    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final finalUri = uri.replace(queryParameters: queryParams);

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load quotations: ${response.statusCode}');
    }
  }

  // GET: Get single quotation/invoice
  Future<Map<String, dynamic>> getQuotation({
    required String id,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.get(Uri.parse('$baseUrl/quotations/$id'), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? data;
    } else {
      throw Exception('Failed to load quotation: ${response.statusCode}');
    }
  }

  // POST: Create quotation
  Future<Map<String, dynamic>> createQuotation({
    required Map<String, dynamic> data,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.post(
      Uri.parse('$baseUrl/quotations'),
      headers: headers,
      body: json.encode(data),
    );

    print('📤 Quotation API - Status Code: ${response.statusCode}');
    print('📤 Quotation API - Response Body: ${response.body}');

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      print('📤 Quotation API - Parsed Response: $responseData');
      print('📤 Quotation API - Has data field: ${responseData.containsKey('data')}');

      // Always return the full response object for consistency
      return responseData;
    } else {
      print('❌ Quotation API - Error response: ${response.body}');
      try {
        final errorData = json.decode(response.body);
        if (errorData['errors'] != null && errorData['errors'] is List) {
          final errors = errorData['errors'] as List;
          throw Exception(errors.join(', '));
        } else {
          throw Exception(errorData['message'] ?? 'Failed to create quotation');
        }
      } catch (parseError) {
        throw Exception('Failed to create quotation: ${response.statusCode}');
      }
    }
  }

  // PUT: Update quotation
  Future<Map<String, dynamic>> updateQuotation({
    required String id,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    print('🔄 Update Quotation API - ID: $id');
    print('🔄 Update Quotation API - Data keys: ${data.keys.toList()}');

    // Log the full JSON payload being sent
    final jsonPayload = json.encode(data);
    print('🔄 Update Quotation API - Full JSON Payload: $jsonPayload');

    // Check for null values in critical fields
    print('🔄 Update Quotation API - Checking for null values:');
    print('   - customerName: ${data['customerName']}');
    print('   - customerPhone: ${data['customerPhone']}');
    print('   - lineItems count: ${(data['lineItems'] as List?)?.length ?? 0}');

    // Check lineItems for null values
    if (data['lineItems'] != null) {
      final lineItems = data['lineItems'] as List;
      for (int i = 0; i < lineItems.length; i++) {
        final item = lineItems[i] as Map<String, dynamic>;
        print('   - Item $i: name=${item['item']?['name']}, sellingPrice=${item['item']?['sellingPrice']}, unit=${item['item']?['unit']}, categoryId=${item['item']?['categoryId']}');
      }
    }

    final headers = await _getHeaders(token: token);
    final response = await http.put(
      Uri.parse('$baseUrl/quotations/$id'),
      headers: headers,
      body: jsonPayload,
    );

    print('🔄 Update Quotation API - Status Code: ${response.statusCode}');
    print('🔄 Update Quotation API - Response Body Length: ${response.body.length}');
    print('🔄 Update Quotation API - Response Body: "${response.body}"');

    if (response.statusCode == 200) {
      // Handle empty response body
      if (response.body.trim().isEmpty) {
        print('🔄 Update Quotation API - Empty response body, returning success data');
        return {
          'id': id,
          'updated': true,
          'message': 'Quotation updated successfully'
        };
      }

      try {
        final responseData = json.decode(response.body);
        print('🔄 Update Quotation API - Parsed Response: $responseData');

        // Handle different response formats
        if (responseData is Map<String, dynamic>) {
          return responseData['data'] ?? responseData;
        } else {
          print('❌ Update Quotation API - Response is not a Map: $responseData');
          return {
            'id': id,
            'updated': true,
            'rawResponse': responseData
          };
        }
      } catch (e) {
        print('❌ Update Quotation API - Failed to parse JSON: $e');
        // If JSON parsing fails but status is 200, assume success
        return {
          'id': id,
          'updated': true,
          'parseError': e.toString()
        };
      }
    } else {
      print('❌ Update Quotation API - Error response: ${response.body}');
      try {
        final errorData = json.decode(response.body);
        if (errorData['errors'] != null && errorData['errors'] is List) {
          final errors = errorData['errors'] as List;
          throw Exception(errors.join(', '));
        } else {
          throw Exception(errorData['message'] ?? 'Failed to update quotation');
        }
      } catch (parseError) {
        throw Exception('Failed to update quotation: ${response.statusCode}');
      }
    }
  }

  // PATCH: Convert quotation to invoice
  Future<Map<String, dynamic>> convertToInvoice({
    required String id,
    List<Map<String, dynamic>>? advancePayments,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final body = advancePayments != null && advancePayments.isNotEmpty
        ? json.encode({'payments': advancePayments})
        : null;

    final response = await http.patch(
      Uri.parse('$baseUrl/quotations/$id/convert-to-invoice'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data'] ?? responseData;
    } else {
      try {
        final errorData = json.decode(response.body);
        if (errorData['errors'] != null && errorData['errors'] is List) {
          final errors = errorData['errors'] as List;
          throw Exception(errors.join(', '));
        } else {
          throw Exception(errorData['message'] ?? 'Failed to convert to invoice');
        }
      } catch (parseError) {
        throw Exception('Failed to convert to invoice: ${response.statusCode}');
      }
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
      Uri.parse('$baseUrl/quotations/$id/status'),
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

  // POST: Add payment
  Future<Map<String, dynamic>> addPayment({
    required String id,
    required Map<String, dynamic> paymentData,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.post(
      Uri.parse('$baseUrl/quotations/$id/payments'),
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

  // DELETE: Delete quotation
  Future<void> deleteQuotation({
    required String id,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.delete(Uri.parse('$baseUrl/quotations/$id'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete quotation: ${response.statusCode}');
    }
  }
}
