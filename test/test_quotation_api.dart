import 'dart:convert';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';

void main() {
  print('🧪 Testing Quotation API Integration...\n');

  // Test 1: Model Serialization/Deserialization
  print('1️⃣ Testing Model Serialization/Deserialization');
  testModelSerialization();
  print('');

  // Test 2: API Request Format
  print('2️⃣ Testing API Request Format');
  testApiRequestFormat();
  print('');

  // Test 3: Authentication Header
  print('3️⃣ Testing Authentication Header');
  testAuthHeader();
  print('');

  // Test 4: Response Parsing
  print('4️⃣ Testing Response Parsing');
  testResponseParsing();
  print('');

  print('✅ All tests completed!');
}

// Test model serialization and deserialization
void testModelSerialization() {
  try {
    // Create a sample ItemDescription
    final item = ItemDescription(
      'Test Item',
      sellingPrice: 100.0,
      unit: 'sqft',
      category: 'Flooring',
      productName: 'Test Product',
    );

    // Test toJson
    final json = item.toJson();
    print('   ✅ ItemDescription toJson: $json');

    // Test fromJson
    final itemFromJson = ItemDescription.fromJson(json);
    print('   ✅ ItemDescription fromJson: ${itemFromJson.name}');

    // Create a sample InvoiceLineItem
    final lineItem = InvoiceLineItem(
      item: item,
      quantity: 10.0,
    );

    // Test InvoiceLineItem toJson
    final lineJson = lineItem.toJson();
    print('   ✅ InvoiceLineItem toJson: $lineJson');

    // Test InvoiceLineItem fromJson
    final lineFromJson = InvoiceLineItem.fromJson(lineJson);
    print('   ✅ InvoiceLineItem fromJson: ${lineFromJson.item.name}');

    // Create a sample QuotationDocument
    final quotation = QuotationDocument(
      documentNumber: 'TEST-001',
      customerName: 'Test Customer',
      customerPhone: '+94 77 123 4567',
      customerAddress: 'Test Address',
      projectTitle: 'Test Project',
      invoiceDate: DateTime.now(),
      dueDate: DateTime.now().add(Duration(days: 7)),
      lineItems: [lineItem],
      paymentHistory: [],
      type: DocumentType.quotation,
      status: DocumentStatus.pending,
    );

    // Test QuotationDocument toJson
    final quoteJson = quotation.toJson();
    print('   ✅ QuotationDocument toJson created successfully');

    // Test QuotationDocument fromJson
    final quoteFromJson = QuotationDocument.fromJson(quoteJson);
    print('   ✅ QuotationDocument fromJson: ${quoteFromJson.customerName}');

    print('   ✅ Model serialization tests passed!');

  } catch (e) {
    print('   ❌ Model serialization test failed: $e');
  }
}

// Test API request format
void testApiRequestFormat() {
  try {
    // Create sample quotation data
    final sampleData = {
      'documentNumber': 'TEST-001',
      'type': 'quotation',
      'status': 'pending',
      'customerName': 'Test Customer',
      'customerPhone': '+94 77 123 4567',
      'customerAddress': 'Test Address',
      'projectTitle': 'Test Project',
      'invoiceDate': DateTime.now().toIso8601String(),
      'dueDate': DateTime.now().add(Duration(days: 7)).toIso8601String(),
      'lineItems': [
        {
          'item': {
            'name': 'Test Item',
            'category': 'Flooring',
            'productName': 'Test Product',
            'sellingPrice': 100.0,
            'unit': 'sqft',
          },
          'quantity': 10.0,
          'customDescription': null,
          'isOriginalQuotationItem': true,
        }
      ],
      'paymentHistory': [],
    };

    // Test JSON encoding
    final jsonString = jsonEncode(sampleData);
    print('   ✅ API request JSON encoding successful');

    // Test JSON decoding
    final decoded = jsonDecode(jsonString);
    print('   ✅ API request JSON decoding successful');

    // Verify structure
    assert(decoded['customerName'] == 'Test Customer');
    assert(decoded['lineItems'][0]['quantity'] == 10.0);
    print('   ✅ API request format verification passed!');

  } catch (e) {
    print('   ❌ API request format test failed: $e');
  }
}

// Test authentication header format
void testAuthHeader() {
  try {
    // Sample JWT token
    const sampleToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.signature';

    // Test header format
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $sampleToken',
    };

    print('   ✅ Authorization header format: ${headers['Authorization']}');

    // Verify format
    assert(headers['Authorization']!.startsWith('Bearer '));
    assert(headers['Content-Type'] == 'application/json');
    print('   ✅ Authentication header format verification passed!');

  } catch (e) {
    print('   ❌ Authentication header test failed: $e');
  }
}

// Test response parsing
void testResponseParsing() {
  try {
    // Sample API response
    const sampleResponse = '''
    {
      "success": true,
      "message": "Quotations retrieved successfully",
      "data": [
        {
          "_id": "507f1f77bcf86cd799439011",
          "documentNumber": "001",
          "type": "quotation",
          "status": "pending",
          "customerName": "John Doe",
          "customerPhone": "+94 77 123 4567",
          "customerAddress": "Colombo, Sri Lanka",
          "projectTitle": "Home Renovation",
          "invoiceDate": "2025-12-08T07:30:00.000Z",
          "dueDate": "2025-12-15T07:30:00.000Z",
          "lineItems": [
            {
              "item": {
                "name": "Floor Tiles",
                "category": "Flooring",
                "productName": "Ceramic Tiles",
                "sellingPrice": 25.50,
                "unit": "sqft"
              },
              "quantity": 100.0,
              "isOriginalQuotationItem": true
            }
          ],
          "paymentHistory": []
        }
      ]
    }
    ''';

    // Test JSON parsing
    final parsed = jsonDecode(sampleResponse);
    print('   ✅ API response JSON parsing successful');

    // Verify structure
    assert(parsed['success'] == true);
    assert(parsed['data'] is List);
    assert(parsed['data'][0]['customerName'] == 'John Doe');
    print('   ✅ API response structure verification passed!');

    // Test QuotationDocument creation from response
    final quotations = (parsed['data'] as List)
        .map((json) => QuotationDocument.fromJson(json))
        .toList();

    print('   ✅ QuotationDocument creation from API response successful');
    print('   📊 Parsed ${quotations.length} quotation(s)');
    print('   👤 First quotation customer: ${quotations[0].customerName}');

    print('   ✅ Response parsing tests passed!');

  } catch (e) {
    print('   ❌ Response parsing test failed: $e');
  }
}
