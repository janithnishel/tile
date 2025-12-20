import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportsApiService {
  final String baseUrl;

  ReportsApiService({this.baseUrl = 'http://localhost:5000/api'});

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

  // GET: Sales Summary Report
  Future<Map<String, dynamic>> getSalesSummary({
    String? token,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/reports/sales-summary');
    final queryParams = <String, String>{};

    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final finalUri = queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams)
        : uri;

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load sales summary: ${response.statusCode}');
    }
  }

  // GET: Profit Analysis Report
  Future<Map<String, dynamic>> getProfitAnalysis({
    String? token,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/reports/profit-analysis');
    final queryParams = <String, String>{};

    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final finalUri = queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams)
        : uri;

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profit analysis: ${response.statusCode}');
    }
  }

  // GET: Customer Summary Report
  Future<Map<String, dynamic>> getCustomerSummary({
    String? token,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/reports/customer-summary');
    final queryParams = <String, String>{};

    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final finalUri = queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams)
        : uri;

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load customer summary: ${response.statusCode}');
    }
  }

  // GET: Supplier Summary Report
  Future<Map<String, dynamic>> getSupplierSummary({
    String? token,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders(token: token);
    final uri = Uri.parse('$baseUrl/reports/supplier-summary');
    final queryParams = <String, String>{};

    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final finalUri = queryParams.isNotEmpty
        ? uri.replace(queryParameters: queryParams)
        : uri;

    final response = await http.get(finalUri, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load supplier summary: ${response.statusCode}');
    }
  }

  // GET: Outstanding Payments Report
  Future<Map<String, dynamic>> getOutstandingPayments({String? token}) async {
    final headers = await _getHeaders(token: token);
    final response = await http.get(Uri.parse('$baseUrl/reports/outstanding-payments'), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load outstanding payments: ${response.statusCode}');
    }
  }
}
