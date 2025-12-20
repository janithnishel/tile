import 'dart:convert';
import 'package:http/http.dart' as http;

class JobCostApiService {
  final String baseUrl;

  JobCostApiService({this.baseUrl = 'http://localhost:5000/api'});

  // Helper method to get auth token from local storage or wherever it's stored
  Future<String?> _getToken() async {
    // TODO: Implement token retrieval from secure storage
    // For now, return null - the actual token should be passed from the cubit
    return null;
  }

  // Helper method to get common headers
  Future<Map<String, String>> _getHeaders({String? token}) async {
    final currentToken = token ?? await _getToken();
    if (currentToken == null) {
      throw Exception('No authentication token available');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $currentToken',
    };
  }

  // GET: Get all job costs
  Future<Map<String, dynamic>> getJobCosts({
    String? token,
    int page = 1,
    int limit = 10,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/job-costs');
    final queryParams = <String, String>{};

    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    if (search != null) queryParams['search'] = search;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final finalUri = uri.replace(queryParameters: queryParams);

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load job costs: ${response.statusCode}');
    }
  }

  // GET: Get single job cost
  Future<Map<String, dynamic>> getJobCost({
    required String id,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.get(Uri.parse('$baseUrl/job-costs/$id'), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? data;
    } else {
      throw Exception('Failed to load job cost: ${response.statusCode}');
    }
  }

  // POST: Create job cost
  Future<Map<String, dynamic>> createJobCost({
    required Map<String, dynamic> data,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.post(
      Uri.parse('$baseUrl/job-costs'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return responseData['data'] ?? responseData;
    } else {
      throw Exception('Failed to create job cost: ${response.statusCode}');
    }
  }

  // PUT: Update job cost
  Future<Map<String, dynamic>> updateJobCost({
    required String id,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.put(
      Uri.parse('$baseUrl/job-costs/$id'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data'] ?? responseData;
    } else {
      throw Exception('Failed to update job cost: ${response.statusCode}');
    }
  }

  // DELETE: Delete job cost
  Future<void> deleteJobCost({
    required String id,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.delete(Uri.parse('$baseUrl/job-costs/$id'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete job cost: ${response.statusCode}');
    }
  }
}
