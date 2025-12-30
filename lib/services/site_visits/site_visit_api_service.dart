import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/site_visits/site_visit_model.dart';
import '../../models/site_visits/inspection_model.dart';

class SiteVisitApiService {
  static const String baseUrl = 'http://localhost:5000/api/site-visits';

  // Headers for authenticated requests
  static Map<String, String> getHeaders(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // Get all site visits with pagination and filters
  static Future<Map<String, dynamic>> getSiteVisits({
    required String token,
    int page = 1,
    int limit = 50,
    String? search,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'siteVisits': (data['data']['siteVisits'] as List)
              .map((visit) => SiteVisitModel.fromJson(visit))
              .toList(),
          'pagination': data['data']['pagination'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to fetch site visits',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get single site visit
  static Future<Map<String, dynamic>> getSiteVisit(String id, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'siteVisit': SiteVisitModel.fromJson(data['data']),
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to fetch site visit',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Create new site visit
  static Future<Map<String, dynamic>> createSiteVisit(Map<String, dynamic> siteVisitData, String token) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: getHeaders(token),
        body: json.encode(siteVisitData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'siteVisit': SiteVisitModel.fromJson(data['data']),
          'message': data['message'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to create site visit',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Update site visit
  static Future<Map<String, dynamic>> updateSiteVisit(String id, Map<String, dynamic> siteVisitData, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: getHeaders(token),
        body: json.encode(siteVisitData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'siteVisit': SiteVisitModel.fromJson(data['data']),
          'message': data['message'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to update site visit',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Delete site visit
  static Future<Map<String, dynamic>> deleteSiteVisit(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to delete site visit',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get site visit statistics
  static Future<Map<String, dynamic>> getSiteVisitStats({
    required String token,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }

      final uri = Uri.parse('$baseUrl/stats/summary').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'stats': data['data'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to fetch statistics',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get site visits grouped by customer
  static Future<Map<String, dynamic>> getSiteVisitsGroupedByCustomer({
    required String token,
    String? search,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }

      final uri = Uri.parse('$baseUrl/grouped-by-customer').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: getHeaders(token));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'groupedVisits': data['data'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to fetch grouped site visits',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Update site visit status
  static Future<Map<String, dynamic>> updateSiteVisitStatus(String id, String status, String token) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/status'),
        headers: getHeaders(token),
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'siteVisit': SiteVisitModel.fromJson(data['data']),
          'message': data['message'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to update status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
