import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';
import 'package:tilework/services/material_sale/material_sale_api_service.dart';

class MaterialSaleRepository {
  final MaterialSaleApiService _apiService;
  final String? _token;

  MaterialSaleRepository(this._apiService, [this._token]);

  // GET: Fetch all material sales
  Future<List<MaterialSaleDocument>> fetchMaterialSales({Map<String, String>? queryParams}) async {
    try {
      // Backend returns: {success: true, data: [...], pagination: {...}}
      final response = await _apiService.getAllMaterialSales(token: _token, queryParams: queryParams);

      // Handle paginated response
      if (response['data'] != null && response['data'] is List) {
        final List data = response['data'] as List;
        return data.map((json) => MaterialSaleDocument.fromJson(json as Map<String, dynamic>)).toList();
      } else if (response is List) {
        return (response as List).map((json) => MaterialSaleDocument.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch material sales: $e');
    }
  }

  // GET: Fetch single material sale
  Future<MaterialSaleDocument> fetchMaterialSale(String id) async {
    try {
      final response = await _apiService.getMaterialSale(id, token: _token);
      final data = response['data'];
      return MaterialSaleDocument.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch material sale: $e');
    }
  }

  // POST: Create a new material sale
  Future<MaterialSaleDocument> createMaterialSale(MaterialSaleDocument materialSale) async {
    try {
      final response = await _apiService.createMaterialSale(materialSale.toJson(), token: _token);
      final data = response['data'];
      return MaterialSaleDocument.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create material sale: $e');
    }
  }

  // PUT: Update a material sale
  Future<MaterialSaleDocument> updateMaterialSale(MaterialSaleDocument materialSale) async {
    try {
      final response = await _apiService.updateMaterialSale(materialSale.id ?? '', materialSale.toJson(), token: _token);
      final data = response['data'];
      return MaterialSaleDocument.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update material sale: $e');
    }
  }

  // DELETE: Delete a material sale
  Future<void> deleteMaterialSale(String id) async {
    try {
      await _apiService.deleteMaterialSale(id, token: _token);
    } catch (e) {
      throw Exception('Failed to delete material sale: $e');
    }
  }

  // POST: Add payment to material sale
  Future<MaterialSaleDocument> addPayment(String id, Map<String, dynamic> paymentData) async {
    try {
      final response = await _apiService.addPayment(id, paymentData, token: _token);
      final data = response['data'];
      return MaterialSaleDocument.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to add payment: $e');
    }
  }

  // PATCH: Update status
  Future<MaterialSaleDocument> updateStatus(String id, String status) async {
    try {
      final response = await _apiService.updateStatus(id, {'status': status}, token: _token);
      final data = response['data'];
      return MaterialSaleDocument.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }
}
