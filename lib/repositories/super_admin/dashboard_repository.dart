import '../../services/super_admin/dashboard_api_service.dart';

class DashboardRepository {
  final DashboardApiService _dashboardApiService;

  DashboardRepository() : _dashboardApiService = DashboardApiService();

  // GET: Fetch dashboard statistics
  Future<Map<String, dynamic>> fetchDashboardStats({String? token}) async {
    try {
      final response = await _dashboardApiService.getDashboardStats(token: token);
      return response['data'];
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }
}
