import '../../services/reports/api_service.dart';

class ReportsRepository {
  final ReportsApiService _apiService;
  final String? _token;

  ReportsRepository(this._apiService, [this._token]);

  // GET: Sales Summary Report
  Future<Map<String, dynamic>> fetchSalesSummary({
    String? token,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final currentToken = token ?? _token;
      print('🔄 ReportsRepository: Calling sales summary API...');

      final response = await _apiService.getSalesSummary(
        token: currentToken,
        startDate: startDate,
        endDate: endDate,
      );

      print('📊 ReportsRepository: Sales summary loaded successfully');
      return response;
    } catch (e) {
      print('💥 ReportsRepository: Failed to fetch sales summary: $e');
      throw Exception('Failed to fetch sales summary: $e');
    }
  }

  // GET: Profit Analysis Report
  Future<Map<String, dynamic>> fetchProfitAnalysis({
    String? token,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final currentToken = token ?? _token;
      print('🔄 ReportsRepository: Calling profit analysis API...');

      final response = await _apiService.getProfitAnalysis(
        token: currentToken,
        startDate: startDate,
        endDate: endDate,
      );

      print('📊 ReportsRepository: Profit analysis loaded successfully');
      return response;
    } catch (e) {
      print('💥 ReportsRepository: Failed to fetch profit analysis: $e');
      throw Exception('Failed to fetch profit analysis: $e');
    }
  }

  // GET: Customer Summary Report
  Future<List<dynamic>> fetchCustomerSummary({
    String? token,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final currentToken = token ?? _token;
      print('🔄 ReportsRepository: Calling customer summary API...');

      final response = await _apiService.getCustomerSummary(
        token: currentToken,
        startDate: startDate,
        endDate: endDate,
      );

      // Backend returns: {success: true, data: [...]}
      final data = response['data'] ?? [];
      print('📊 ReportsRepository: Customer summary loaded successfully: ${data.length} customers');
      return data;
    } catch (e) {
      print('💥 ReportsRepository: Failed to fetch customer summary: $e');
      throw Exception('Failed to fetch customer summary: $e');
    }
  }

  // GET: Supplier Summary Report
  Future<List<dynamic>> fetchSupplierSummary({
    String? token,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final currentToken = token ?? _token;
      print('🔄 ReportsRepository: Calling supplier summary API...');

      final response = await _apiService.getSupplierSummary(
        token: currentToken,
        startDate: startDate,
        endDate: endDate,
      );

      // Backend returns: {success: true, data: [...]}
      final data = response['data'] ?? [];
      print('📊 ReportsRepository: Supplier summary loaded successfully: ${data.length} suppliers');
      return data;
    } catch (e) {
      print('💥 ReportsRepository: Failed to fetch supplier summary: $e');
      throw Exception('Failed to fetch supplier summary: $e');
    }
  }

  // GET: Outstanding Payments Report
  Future<Map<String, dynamic>> fetchOutstandingPayments({String? token}) async {
    try {
      final currentToken = token ?? _token;
      print('🔄 ReportsRepository: Calling outstanding payments API...');

      final response = await _apiService.getOutstandingPayments(token: currentToken);

      // Backend returns: {success: true, data: {...}}
      final data = response['data'] ?? {};
      print('📊 ReportsRepository: Outstanding payments loaded successfully');
      return data;
    } catch (e) {
      print('💥 ReportsRepository: Failed to fetch outstanding payments: $e');
      throw Exception('Failed to fetch outstanding payments: $e');
    }
  }
}
