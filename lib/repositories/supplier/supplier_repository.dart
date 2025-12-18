import '../../services/supplier/api_service.dart';
import '../../models/purchase_order/supplier.dart';

class SupplierRepository {
  final SupplierApiService _apiService;

  SupplierRepository(this._apiService);

  // Get all suppliers
  Future<List<Supplier>> getSuppliers({
    String? token,
    String? search,
    String? category,
  }) async {
    try {
      return await _apiService.getSuppliers(
        token: token,
        search: search,
        category: category,
      );
    } catch (e) {
      throw Exception('Failed to get suppliers: ${e.toString()}');
    }
  }

  // Get single supplier
  Future<Supplier> getSupplier(String id, {String? token}) async {
    try {
      return await _apiService.getSupplier(id, token: token);
    } catch (e) {
      throw Exception('Failed to get supplier: ${e.toString()}');
    }
  }

  // Create supplier
  Future<Supplier> createSupplier(Supplier supplier, {String? token}) async {
    try {
      return await _apiService.createSupplier(supplier, token: token);
    } catch (e) {
      throw Exception('Failed to create supplier: ${e.toString()}');
    }
  }

  // Update supplier
  Future<Supplier> updateSupplier(String id, Supplier supplier, {String? token}) async {
    try {
      return await _apiService.updateSupplier(id, supplier, token: token);
    } catch (e) {
      throw Exception('Failed to update supplier: ${e.toString()}');
    }
  }

  // Delete supplier
  Future<void> deleteSupplier(String id, {String? token}) async {
    try {
      await _apiService.deleteSupplier(id, token: token);
    } catch (e) {
      throw Exception('Failed to delete supplier: ${e.toString()}');
    }
  }
}
