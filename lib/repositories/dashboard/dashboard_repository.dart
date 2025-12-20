import '../../services/dashboard/api_service.dart';

class DashboardRepository {
  final DashboardApiService _apiService;
  final String? _token;

  DashboardRepository(this._apiService, [this._token]);

  // GET: Dashboard Statistics
  Future<Map<String, dynamic>> fetchDashboardStats({
    String? token,
    String? period,
  }) async {
    try {
      final currentToken = token ?? _token;
      print('🔄 DashboardRepository: Calling dashboard stats API...');

      final response = await _apiService.getDashboardStats(
        token: currentToken,
        period: period,
      );

      // Backend returns: {success: true, data: {...}}
      final data = response['data'] ?? response;
      print('📊 DashboardRepository: Dashboard stats loaded successfully');
      return data;
    } catch (e) {
      print('💥 DashboardRepository: Failed to fetch dashboard stats: $e');
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  // GET: Revenue Trend Chart Data
  Future<List<dynamic>> fetchRevenueTrend({
    String? token,
    String? period,
  }) async {
    try {
      final currentToken = token ?? _token;
      print('🔄 DashboardRepository: Calling revenue trend API...');

      final data = await _apiService.getRevenueTrend(
        token: currentToken,
        period: period,
      );

      print('📊 DashboardRepository: Revenue trend loaded successfully: ${data.length} data points');
      return data;
    } catch (e) {
      print('💥 DashboardRepository: Failed to fetch revenue trend: $e');
      throw Exception('Failed to fetch revenue trend: $e');
    }
  }

  // GET: Profit Breakdown Chart Data
  Future<List<dynamic>> fetchProfitBreakdown({
    String? token,
    String? period,
  }) async {
    try {
      final currentToken = token ?? _token;
      print('🔄 DashboardRepository: Calling profit breakdown API...');

      final data = await _apiService.getProfitBreakdown(
        token: currentToken,
        period: period,
      );

      print('📊 DashboardRepository: Profit breakdown loaded successfully: ${data.length} segments');
      return data;
    } catch (e) {
      print('💥 DashboardRepository: Failed to fetch profit breakdown: $e');
      throw Exception('Failed to fetch profit breakdown: $e');
    }
  }

  // GET: Actionable Items
  Future<Map<String, dynamic>> fetchActionableItems({String? token}) async {
    try {
      final currentToken = token ?? _token;
      print('🔄 DashboardRepository: Calling actionable items API...');

      final data = await _apiService.getActionableItems(token: currentToken);

      print('📊 DashboardRepository: Actionable items loaded successfully');
      return data;
    } catch (e) {
      print('💥 DashboardRepository: Failed to fetch actionable items: $e');
      throw Exception('Failed to fetch actionable items: $e');
    }
  }
}
