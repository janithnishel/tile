import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';

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

  // GET: Fetch all job costs
  Future<Map<String, dynamic>> getAllJobCosts({
    String? token,
    Map<String, String>? queryParams,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/job-costs');
    final finalUri = queryParams != null ? uri.replace(queryParameters: queryParams) : uri;

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load job costs: ${response.statusCode}');
    }
  }

  // GET: Fetch single job cost
  Future<Map<String, dynamic>> getJobCost(String id, {String? token}) async {
    final headers = await _getHeaders(token: token);
    final response = await http.get(Uri.parse('$baseUrl/job-costs/$id'), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load job cost: ${response.statusCode}');
    }
  }

  // POST: Create job cost
  Future<Map<String, dynamic>> createJobCost(
    Map<String, dynamic> jobCostData, {
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.post(
      Uri.parse('$baseUrl/job-costs'),
      headers: headers,
      body: json.encode(jobCostData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create job cost: ${response.statusCode} - ${response.body}');
    }
  }

  // PUT: Update job cost
  Future<Map<String, dynamic>> updateJobCost(
    String id,
    Map<String, dynamic> jobCostData, {
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.put(
      Uri.parse('$baseUrl/job-costs/$id'),
      headers: headers,
      body: json.encode(jobCostData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update job cost: ${response.statusCode}');
    }
  }

  // DELETE: Delete job cost
  Future<void> deleteJobCost(String id, {String? token}) async {
    final headers = await _getHeaders(token: token);
    final response = await http.delete(Uri.parse('$baseUrl/job-costs/$id'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete job cost: ${response.statusCode}');
    }
  }
}
