import '../../models/quotation_Invoice_screen/project/quotation_document.dart';
import '../../services/quotation/quotation_api_service.dart';

class QuotationRepository {
  final QuotationApiService _apiService;
  final String? _token;

  QuotationRepository(this._apiService, [this._token]);

  // GET: Fetch all quotations
  Future<List<QuotationDocument>> fetchQuotations({Map<String, String>? queryParams, String? token}) async {
    try {
      final currentToken = token ?? _token;
      // Backend returns: {success: true, data: [...]}
      final response = await _apiService.getAllQuotations(token: currentToken, queryParams: queryParams);
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
        return [];
      }

      final quotations = data.map((json) {
        try {
          return QuotationDocument.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('❌ Failed to parse quotation: $e, JSON: $json');
          rethrow;
        }
      }).toList();

      print('✅ Successfully parsed ${quotations.length} quotations');
      print('📋 All quotations from backend:');
      for (var i = 0; i < quotations.length; i++) {
        final q = quotations[i];
        print('   ${i + 1}. ID: ${q.id}, Number: ${q.documentNumber}, Customer: ${q.customerName}, Project: ${q.projectTitle}, Type: ${q.type}, Status: ${q.status}');
      }
      print('📋 End of quotations list');
      return quotations;
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
      final response = await _apiService.createQuotation(jsonData, token: currentToken);
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
      print('❌ Error details: ${e.toString()}');

      // If it's a validation error, let's try to understand what went wrong
      if (e.toString().contains('Validation Error')) {
        print('🔍 Backend validation failed. Checking data format...');
        final jsonData = quotation.toJson();
        print('🔍 Sent data keys: ${jsonData.keys.toList()}');

        // Check for common validation issues
        if (jsonData['customerName']?.isEmpty ?? true) {
          print('⚠️  Customer name is empty');
        }
        if (jsonData['customerPhone']?.isEmpty ?? true) {
          print('⚠️  Customer phone is empty');
        }
        if ((jsonData['lineItems'] as List?)?.isEmpty ?? true) {
          print('⚠️  No line items');
        }
      }

      throw Exception('Failed to create quotation: $e');
    }
  }

  // PUT: Update a quotation
  Future<QuotationDocument> updateQuotation(QuotationDocument quotation, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      final response = await _apiService.updateQuotation(quotation.id ?? '', quotation.toJson(), token: currentToken);

      // Backend should return the updated quotation data
      final data = response['data'];
      return QuotationDocument.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update quotation: $e');
    }
  }

  // DELETE: Delete a quotation
  Future<void> deleteQuotation(String id, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      await _apiService.deleteQuotation(id, token: currentToken);
    } catch (e) {
      throw Exception('Failed to delete quotation: $e');
    }
  }

  // POST: Add payment to quotation
  Future<QuotationDocument> addPayment(String id, Map<String, dynamic> paymentData, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      final response = await _apiService.addPayment(id, paymentData, token: currentToken);

      // Backend should return the updated quotation data
      final data = response['data'];
      return QuotationDocument.fromJson(data);
    } catch (e) {
      throw Exception('Failed to add payment: $e');
    }
  }

  // PATCH: Convert quotation to invoice
  Future<QuotationDocument> convertToInvoice(String id, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      print('🔄 Converting quotation $id to invoice...');
      print('🔑 Token available: ${currentToken != null ? "Yes (${currentToken!.substring(0, 20)}...)" : "No"}');

      final response = await _apiService.convertToInvoice(id, token: currentToken);
      print('✅ Convert to invoice API response: $response');

      // Backend should return the converted invoice data
      final data = response['data'];
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
      final response = await _apiService.updateQuotationStatus(id, statusData, token: currentToken);

      // Backend should return the updated quotation data
      final data = response['data'];
      return QuotationDocument.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update quotation status: $e');
    }
  }
}
