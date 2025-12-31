import '../../models/job_cost_screen/job_cost_document.dart';
import '../../services/job_cost/api_service.dart';
import '../../data/job_cost_mock_data.dart';

class JobCostRepository {
  final JobCostApiService _apiService;
  final String? _token;

  JobCostRepository(this._apiService, [this._token]);

  // GET: Fetch all job costs
  Future<List<JobCostDocument>> fetchJobCosts({
    Map<String, String>? queryParams,
    String? token,
  }) async {
    // Return mock data for now
    print('� JobCostRepository: Returning mock data with ${MockData.jobCosts.length} job costs');
    return MockData.jobCosts;
  }

  // GET: Fetch single job cost
  Future<JobCostDocument> fetchJobCost(String id, {String? token}) async {
    // Return mock data for the job with matching ID
    final job = MockData.jobCosts.firstWhere(
      (job) => job.id == id || job.invoiceId == id,
      orElse: () => throw Exception('Job cost not found'),
    );
    return job;
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
