import '../../models/job_cost_screen/job_cost_document.dart';
import '../../services/job_cost/api_service.dart';

class JobCostRepository {
  final JobCostApiService _apiService;
  final String? _token;

  JobCostRepository(this._apiService, [this._token]);

  // GET: Fetch all job costs
  Future<List<JobCostDocument>> fetchJobCosts({
    Map<String, String>? queryParams,
    String? token,
  }) async {
    try {
      final currentToken = token ?? _token;
      print('🔄 JobCostRepository: Calling API with token: ${currentToken?.substring(0, 20)}...');
      print('🔍 JobCostRepository: Query params: $queryParams');

      final response = await _apiService.getAllJobCosts(
        token: currentToken,
        queryParams: queryParams,
      );

      print('📡 JobCostRepository: API Response keys: ${response.keys.toList()}');
      print('📊 JobCostRepository: Response success: ${response['success']}');

      // Backend returns: {success: true, data: [...]}
      List data = [];
      if (response['data'] != null) {
        data = response['data'] as List;
        print('📦 JobCostRepository: Found ${data.length} items in data array');
      } else if (response is List) {
        data = response as List;
        print('📦 JobCostRepository: Response is direct list with ${data.length} items');
      } else {
        print('⚠️ JobCostRepository: No data found in response');
        return [];
      }

      final jobCosts = data.where((json) => json != null).map((json) {
        try {
          return JobCostDocument.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('❌ JobCostRepository: Failed to parse job cost: $e, JSON: $json');
          rethrow;
        }
      }).toList();

      print('✅ JobCostRepository: Successfully parsed ${jobCosts.length} job costs');
      return jobCosts;
    } catch (e) {
      print('💥 JobCostRepository: Failed to fetch job costs: $e');
      throw Exception('Failed to fetch job costs: $e');
    }
  }

  // GET: Fetch single job cost
  Future<JobCostDocument> fetchJobCost(String id, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      final response = await _apiService.getJobCost(id, token: currentToken);

      // Backend should return the job cost data directly
      final data = response['data'] ?? response;
      return JobCostDocument.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      print('💥 Failed to fetch job cost: $e');
      throw Exception('Failed to fetch job cost: $e');
    }
  }

  // POST: Create job cost
  Future<JobCostDocument> createJobCost(
    JobCostDocument jobCost, {
    String? token,
  }) async {
    try {
      final jsonData = jobCost.toJson();
      final currentToken = token ?? _token;

      final response = await _apiService.createJobCost(jsonData, token: currentToken);

      // Backend should return the created job cost data
      final data = response['data'];
      if (data == null) {
        throw Exception('No data returned from create job cost API');
      }

      final createdJobCost = JobCostDocument.fromJson(data);
      return createdJobCost;
    } catch (e) {
      print('❌ Failed to create job cost: $e');
      throw Exception('Failed to create job cost: $e');
    }
  }

  // PUT: Update job cost
  Future<JobCostDocument> updateJobCost(
    JobCostDocument jobCost, {
    String? token,
  }) async {
    try {
      final currentToken = token ?? _token;
      final response = await _apiService.updateJobCost(
        jobCost.id ?? '',
        jobCost.toJson(),
        token: currentToken,
      );

      // Backend should return the updated job cost data
      final data = response['data'];
      return JobCostDocument.fromJson(data);
    } catch (e) {
      print('💥 Failed to update job cost: $e');
      throw Exception('Failed to update job cost: $e');
    }
  }

  // DELETE: Delete job cost
  Future<void> deleteJobCost(String id, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      await _apiService.deleteJobCost(id, token: currentToken);
    } catch (e) {
      print('💥 Failed to delete job cost: $e');
      throw Exception('Failed to delete job cost: $e');
    }
  }
}
