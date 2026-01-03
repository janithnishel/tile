import 'package:tilework/services/customer/customer_api_service.dart';

class CustomerRepository {
  final CustomerApiService _apiService;

  CustomerRepository(this._apiService);

  // GET: Search customer by phone number
  Future<Map<String, dynamic>> searchCustomerByPhone(String phone, {String? token}) async {
    try {
      final response = await _apiService.searchCustomerByPhone(phone: phone, token: token);
      return response;
    } catch (e) {
      throw Exception('Failed to search customer: $e');
    }
  }

  // GET: Fetch all customers
  Future<Map<String, dynamic>> fetchCustomers({
    String? token,
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final response = await _apiService.getCustomers(
        token: token,
        page: page,
        limit: limit,
        search: search,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  // POST: Create customer
  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> data, {String? token}) async {
    try {
      final response = await _apiService.createCustomer(data: data, token: token);
      return response;
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  // PUT: Update customer
  Future<Map<String, dynamic>> updateCustomer(String id, Map<String, dynamic> data, {String? token}) async {
    try {
      final response = await _apiService.updateCustomer(id: id, data: data, token: token);
      return response;
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  // DELETE: Delete customer
  Future<void> deleteCustomer(String id, {String? token}) async {
    try {
      await _apiService.deleteCustomer(id: id, token: token);
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }
}
