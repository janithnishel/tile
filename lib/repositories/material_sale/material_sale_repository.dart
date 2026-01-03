import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';
import 'package:tilework/services/material_sale/material_sale_api_service.dart';

class MaterialSaleRepository {
  final MaterialSaleApiService _apiService;

  MaterialSaleRepository(this._apiService);

  // GET: Fetch all material sales
  Future<Map<String, dynamic>> fetchMaterialSales({
    String? token,
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _apiService.getMaterialSales(
        token: token,
        page: page,
        limit: limit,
        status: status,
        search: search,
        startDate: startDate,
        endDate: endDate,
      );

      // Backend returns: {success: true, data: [...], pagination: {...}}
      return response;
    } catch (e) {
      throw Exception('Failed to fetch material sales: $e');
    }
  }

  // GET: Fetch single material sale
  Future<Map<String, dynamic>> fetchMaterialSale(String id, {String? token}) async {
    try {
      final response = await _apiService.getMaterialSale(id: id, token: token);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch material sale: $e');
    }
  }

  // POST: Create a new material sale
  Future<Map<String, dynamic>> createMaterialSale(Map<String, dynamic> data, {String? token}) async {
    try {
      final response = await _apiService.createMaterialSale(data: data, token: token);
      return response;
    } catch (e) {
      throw Exception('Failed to create material sale: $e');
    }
  }

  // PUT: Update a material sale
  Future<Map<String, dynamic>> updateMaterialSale(String id, Map<String, dynamic> data, {String? token}) async {
    try {
      final response = await _apiService.updateMaterialSale(id: id, data: data, token: token);
      return response;
    } catch (e) {
      throw Exception('Failed to update material sale: $e');
    }
  }

  // DELETE: Delete a material sale
  Future<void> deleteMaterialSale(String id, {String? token}) async {
    try {
      await _apiService.deleteMaterialSale(id: id, token: token);
    } catch (e) {
      throw Exception('Failed to delete material sale: $e');
    }
  }

  // POST: Add payment to material sale
  Future<Map<String, dynamic>> addPayment(String id, Map<String, dynamic> paymentData, {String? token}) async {
    try {
      final response = await _apiService.addPayment(id: id, paymentData: paymentData, token: token);
      return response;
    } catch (e) {
      throw Exception('Failed to add payment: $e');
    }
  }

  // PATCH: Update status
  Future<Map<String, dynamic>> updateStatus(String id, String status, {String? token}) async {
    try {
      final response = await _apiService.updateStatus(id: id, status: status, token: token);
      return response;
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  // GET: Search customer by phone number
  Future<Map<String, dynamic>> searchCustomerByPhone(String phone, {String? token}) async {
    try {
      final response = await _apiService.searchCustomerByPhone(phone: phone, token: token);
      return response;
    } catch (e) {
      throw Exception('Failed to search customer: $e');
    }
  }
}
