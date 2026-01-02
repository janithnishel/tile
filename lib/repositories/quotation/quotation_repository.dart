import '../../models/quotation_Invoice_screen/project/quotation_document.dart';
import '../../services/quotation/quotation_api_service.dart';

class QuotationRepository {
  final QuotationApiService _apiService;
  final String? _token;

  QuotationRepository(this._apiService, [this._token]);

  // GET: Fetch all quotations (returns paginated result)
  Future<Map<String, dynamic>> fetchQuotations({Map<String, String>? queryParams, String? token}) async {
    try {
      final currentToken = token ?? _token;

      // Extract pagination parameters
      final page = int.tryParse(queryParams?['page'] ?? '1') ?? 1;
      final limit = int.tryParse(queryParams?['limit'] ?? '10') ?? 10;
      final type = queryParams?['type'];
      final status = queryParams?['status'];
      final search = queryParams?['search'];
      final startDate = queryParams?['startDate'];
      final endDate = queryParams?['endDate'];

      // Backend returns: {success: true, data: [...]}
      final response = await _apiService.getQuotations(
        token: currentToken,
        page: page,
        limit: limit,
        type: type,
        status: status,
        search: search,
        startDate: startDate,
        endDate: endDate,
      );
      print('🔍 Raw API Response: $response');
      print('🔍 Response type: ${response.runtimeType}');

      // Try different response formats
      List data = [];
      if (response['data'] != null) {
        data = response['data'] as List;
        print('📊 Found data array with ${data.length} items');
      } else if (response is List) {
        data = response as List;
        print('📊 Response is directly a list with ${data.length} items');
      } else {
        print('❌ No data field found in response');
        return {
          'items': [],
          'total': 0,
          'page': page,
          'limit': limit,
        };
      }

      final quotations = data.map((json) {
        try {
          return QuotationDocument.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('❌ Failed to parse quotation: $e, JSON: $json');
          rethrow;
        }
      }).toList();

      // Extract pagination metadata from response if available
      dynamic totalFromBackend = response['total'];
      dynamic pageFromBackend = response['page'];
      dynamic limitFromBackend = response['limit'];

      // Some APIs nest pagination under `pagination` or `meta` keys
      if (response['pagination'] != null) {
        totalFromBackend ??= response['pagination']['total'];
        pageFromBackend ??= response['pagination']['page'];
        limitFromBackend ??= response['pagination']['limit'];
      }
      if (response['meta'] != null) {
        totalFromBackend ??= response['meta']['total'];
        pageFromBackend ??= response['meta']['page'];
        limitFromBackend ??= response['meta']['limit'];
      }

      print('✅ Successfully parsed ${quotations.length} quotations');
      print('📊 DB SUMMARY: Total in DB: ${totalFromBackend ?? 'N/A'} | Loaded: ${quotations.length} | Page: ${pageFromBackend ?? page} | Limit: ${limitFromBackend ?? limit}');

      if (totalFromBackend != null && quotations.length < totalFromBackend) {
        final remaining = (totalFromBackend as int) - quotations.length;
        print('📊 REMAINING: ${remaining} more documents available in database');
      }

      print('📋 FRONTEND: Quotations received:');
      for (var i = 0; i < quotations.length; i++) {
        final q = quotations[i];
        print('   ${i + 1}. ${q.documentNumber} - ${q.customerName} (${q.type})');
      }
      print('📋 FRONTEND: End of list');

      return {
        'items': quotations,
        'total': totalFromBackend ?? quotations.length,
        'page': pageFromBackend ?? page,
        'limit': limitFromBackend ?? limit,
      };
    } catch (e) {
      print('💥 Failed to fetch quotations: $e');
      throw Exception('Failed to fetch quotations: $e');
    }
  }

  // POST: Create a new quotation
  Future<QuotationDocument> createQuotation(QuotationDocument quotation, {String? token}) async {
    try {
      final jsonData = quotation.toJson();
      print('📤 Creating quotation with data: $jsonData');
      print('📤 Data structure validation:');
      print('   - documentNumber: ${jsonData['documentNumber']}');
      print('   - customerName: ${jsonData['customerName']}');
      print('   - customerPhone: ${jsonData['customerPhone']}');
      print('   - projectTitle: ${jsonData['projectTitle']}');
      print('   - lineItems count: ${jsonData['lineItems']?.length ?? 0}');
      print('   - type: ${jsonData['type']}');
      print('   - status: ${jsonData['status']}');

      final currentToken = token ?? _token;
      final response = await _apiService.createQuotation(data: jsonData, token: currentToken);
      print('📥 Create quotation API response: $response');

      // Backend should return the created quotation data
      final data = response['data'];
      if (data == null) {
        throw Exception('No data returned from create quotation API');
      }

      final createdQuotation = QuotationDocument.fromJson(data);
      print('✅ Successfully created quotation: ${createdQuotation.documentNumber}');
      return createdQuotation;
    } catch (e) {
      print('❌ Failed to create quotation: $e');
      throw e; // Pass the original error message
    }
  }

  // PUT: Update a quotation
  Future<QuotationDocument> updateQuotation(QuotationDocument quotation, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      final response = await _apiService.updateQuotation(id: quotation.id ?? '', data: quotation.toJson(), token: currentToken);

      print('📦 Update Repository - API Response: $response');

      // Handle different response formats
      Map<String, dynamic>? data;

      if (response.containsKey('data') && response['data'] != null) {
        data = response['data'] as Map<String, dynamic>;
        print('📦 Update Repository - Found data field: $data');
      } else if (response is Map<String, dynamic> && response.containsKey('id')) {
        // Response is directly the quotation data
        data = response;
        print('📦 Update Repository - Response is direct data: $data');
      } else {
        print('📦 Update Repository - No valid data found, using original quotation');
        // If no data returned, return the original quotation (assuming update was successful)
        return quotation;
      }

      // Try to create the quotation document
      try {
        return QuotationDocument.fromJson(data);
      } catch (e) {
        print('❌ Update Repository - Failed to parse quotation from response: $e');
        print('❌ Update Repository - Response data: $data');
        // If parsing fails, return the original quotation
        return quotation;
      }
    } catch (e) {
      print('❌ Update Repository - API call failed: $e');
      throw Exception('Failed to update quotation: $e');
    }
  }

  // DELETE: Delete a quotation
  Future<void> deleteQuotation(String id, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      await _apiService.deleteQuotation(id: id, token: currentToken);
    } catch (e) {
      throw Exception('Failed to delete quotation: $e');
    }
  }

  // POST: Add payment to quotation
  Future<QuotationDocument> addPayment(String id, Map<String, dynamic> paymentData, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      final response = await _apiService.addPayment(id: id, paymentData: paymentData, token: currentToken);

      // Backend should return the updated quotation data
      final data = response['data'];
      return QuotationDocument.fromJson(data);
    } catch (e) {
      throw Exception('Failed to add payment: $e');
    }
  }

  // PATCH: Convert quotation to invoice
  Future<QuotationDocument> convertToInvoice(String id, {List<Map<String, dynamic>>? advancePayments, DateTime? customDueDate, String? token}) async {
    try {
      final currentToken = token ?? _token;
      print('🔄 Converting quotation $id to invoice...');
      print('🔑 Token available: ${currentToken != null ? "Yes (${currentToken!.substring(0, 20)}...)" : "No"}');
      print('💰 Advance payments: ${advancePayments?.length ?? 0} items');
      print('📅 Custom due date: $customDueDate');

      final response = await _apiService.convertToInvoice(id: id, advancePayments: advancePayments, customDueDate: customDueDate, token: currentToken);
      print('✅ Convert to invoice API response: $response');
      print('✅ Response type: ${response.runtimeType}');

      // Handle different response formats
      Map<String, dynamic>? data;

      if (response.containsKey('data') && response['data'] != null) {
        data = response['data'] as Map<String, dynamic>;
        print('📦 Convert - Found data field: $data');
      } else if (response is Map<String, dynamic> && response.containsKey('id')) {
        // Response is directly the invoice data
        data = response;
        print('📦 Convert - Response is direct data: $data');
      } else {
        print('❌ Convert - No valid data found in response');
        print('❌ Convert - Full response: $response');
        throw Exception('Invalid response format from server');
      }

      if (data == null) {
        throw Exception('Server returned null data for converted invoice');
      }

      print('✅ Convert - Parsing invoice data...');
      return QuotationDocument.fromJson(data);
    } catch (e) {
      print('❌ Failed to convert quotation to invoice: $e');
      throw Exception('Failed to convert quotation to invoice: $e');
    }
  }

  // PATCH: Update quotation status
  Future<QuotationDocument> updateQuotationStatus(String id, Map<String, dynamic> statusData, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      final response = await _apiService.updateStatus(id: id, status: statusData['status'] as String, token: currentToken);

      // Backend should return the updated quotation data
      final data = response['data'];
      return QuotationDocument.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update quotation status: $e');
    }
  }
}
