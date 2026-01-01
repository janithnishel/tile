import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportApiService {
  final String baseUrl;

  ReportApiService({this.baseUrl = 'http://localhost:5000/api'});

  Future<String?> _getToken() async {
    // TODO: Implement token retrieval from secure storage
    // For now, return null - the actual token should be passed from the cubit
    return null;
  }

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

  // GET: Get project profitability report data
  Future<Map<String, dynamic>> getProjectReport({
    String? token,
    int page = 1,
    int limit = 50,
    String? status,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/reports/projects');
    final queryParams = <String, String>{};

    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    if (status != null && status != 'All') queryParams['status'] = status;
    if (type != null && type != 'All') queryParams['type'] = type;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final finalUri = uri.replace(queryParameters: queryParams);

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load project report: ${response.statusCode}');
    }
  }

  // GET: Get invoice summary report data
  Future<Map<String, dynamic>> getInvoiceReport({
    String? token,
    int page = 1,
    int limit = 50,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/reports/invoices');
    final queryParams = <String, String>{};

    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    if (status != null && status != 'All') queryParams['status'] = status;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final finalUri = uri.replace(queryParameters: queryParams);

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load invoice report: ${response.statusCode}');
    }
  }

  // GET: Get material sales report data
  Future<Map<String, dynamic>> getMaterialSalesReport({
    String? token,
    int page = 1,
    int limit = 50,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/reports/material-sales');
    final queryParams = <String, String>{};

    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    if (status != null && status != 'All') queryParams['status'] = status;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final finalUri = uri.replace(queryParameters: queryParams);

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load material sales report: ${response.statusCode}');
    }
  }

  // GET: Get dashboard summary data
  Future<Map<String, dynamic>> getDashboardSummary({String? token}) async {
    final headers = await _getHeaders(token: token);
    final response = await http.get(Uri.parse('$baseUrl/reports/dashboard'), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load dashboard summary: ${response.statusCode}');
    }
  }

  // POST: Add direct cost to a project
  Future<Map<String, dynamic>> addDirectCost({
    required String documentId,
    required Map<String, dynamic> costData,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.post(
      Uri.parse('$baseUrl/reports/$documentId/costs'),
      headers: headers,
      body: json.encode(costData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add direct cost: ${response.statusCode}');
    }
  }

  // PATCH: Update project status
  Future<Map<String, dynamic>> updateProjectStatus({
    required String documentId,
    required Map<String, dynamic> statusData,
    String? token,
  }) async {
    final headers = await _getHeaders(token: token);
    final response = await http.patch(
      Uri.parse('$baseUrl/reports/$documentId/project-status'),
      headers: headers,
      body: json.encode(statusData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update project status: ${response.statusCode}');
    }
  }
}
