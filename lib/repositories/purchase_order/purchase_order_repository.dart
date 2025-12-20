import '../../models/purchase_order/purchase_order.dart';
import '../../services/purchase_order/api_service.dart';

class PurchaseOrderRepository {
  final PurchaseOrderApiService _apiService;
  final String? _token;

  PurchaseOrderRepository(this._apiService, [this._token]);

  // GET: Fetch all purchase orders
  Future<List<PurchaseOrder>> fetchPurchaseOrders({
    Map<String, String>? queryParams,
    String? token,
  }) async {
    try {
      final currentToken = token ?? _token;
      print('🔄 PurchaseOrderRepository: Calling API with token: ${currentToken?.substring(0, 20)}...');
      print('🔍 PurchaseOrderRepository: Query params: $queryParams');

      final response = await _apiService.getAllPurchaseOrders(
        token: currentToken,
        queryParams: queryParams,
      );

      print('📡 PurchaseOrderRepository: API Response keys: ${response.keys.toList()}');
      print('📊 PurchaseOrderRepository: Response success: ${response['success']}');

      // Backend returns: {success: true, data: [...]}
      List data = [];
      if (response['data'] != null) {
        data = response['data'] as List;
        print('📦 PurchaseOrderRepository: Found ${data.length} items in data array');
      } else if (response is List) {
        data = response as List;
        print('📦 PurchaseOrderRepository: Response is direct list with ${data.length} items');
      } else {
        print('⚠️ PurchaseOrderRepository: No data found in response');
        return [];
      }

      final purchaseOrders = data.where((json) => json != null && json['supplier'] != null).map((json) {
        try {
          return PurchaseOrder.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('❌ PurchaseOrderRepository: Failed to parse purchase order: $e, JSON: $json');
          rethrow;
        }
      }).toList();

      print('✅ PurchaseOrderRepository: Successfully parsed ${purchaseOrders.length} purchase orders');
      return purchaseOrders;
    } catch (e) {
      print('💥 PurchaseOrderRepository: Failed to fetch purchase orders: $e');
      throw Exception('Failed to fetch purchase orders: $e');
    }
  }

  // GET: Fetch single purchase order
  Future<PurchaseOrder> fetchPurchaseOrder(String id, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      final response = await _apiService.getPurchaseOrder(id, token: currentToken);

      // Backend should return the purchase order data directly
      final data = response['data'] ?? response;
      return PurchaseOrder.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      print('💥 Failed to fetch purchase order: $e');
      throw Exception('Failed to fetch purchase order: $e');
    }
  }

  // POST: Create purchase order
  Future<PurchaseOrder> createPurchaseOrder(
    PurchaseOrder purchaseOrder, {
    String? token,
  }) async {
    try {
      final jsonData = purchaseOrder.toJson();
      final currentToken = token ?? _token;

      final response = await _apiService.createPurchaseOrder(jsonData, token: currentToken);

      // Backend should return the created purchase order data
      final data = response['data'];
      if (data == null) {
        throw Exception('No data returned from create purchase order API');
      }

      final createdPurchaseOrder = PurchaseOrder.fromJson(data);
      return createdPurchaseOrder;
    } catch (e) {
      print('❌ Failed to create purchase order: $e');
      throw Exception('Failed to create purchase order: $e');
    }
  }

  // PUT: Update purchase order
  Future<PurchaseOrder> updatePurchaseOrder(
    PurchaseOrder purchaseOrder, {
    String? token,
  }) async {
    try {
      final currentToken = token ?? _token;
      final response = await _apiService.updatePurchaseOrder(
        purchaseOrder.id ?? '',
        purchaseOrder.toJson(),
        token: currentToken,
      );

      // Backend should return the updated purchase order data
      final data = response['data'];
      return PurchaseOrder.fromJson(data);
    } catch (e) {
      print('💥 Failed to update purchase order: $e');
      throw Exception('Failed to update purchase order: $e');
    }
  }

  // DELETE: Delete purchase order
  Future<void> deletePurchaseOrder(String id, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      await _apiService.deletePurchaseOrder(id, token: currentToken);
    } catch (e) {
      print('💥 Failed to delete purchase order: $e');
      throw Exception('Failed to delete purchase order: $e');
    }
  }

  // PATCH: Update purchase order status
  Future<PurchaseOrder> updatePurchaseOrderStatus(
    String id,
    Map<String, dynamic> statusData, {
    String? token,
  }) async {
    try {
      final currentToken = token ?? _token;
      final response = await _apiService.updatePurchaseOrderStatus(
        id,
        statusData,
        token: currentToken,
      );

      // Backend should return the updated purchase order data
      final data = response['data'];
      return PurchaseOrder.fromJson(data);
    } catch (e) {
      print('💥 Failed to update purchase order status: $e');
      throw Exception('Failed to update purchase order status: $e');
    }
  }
}
