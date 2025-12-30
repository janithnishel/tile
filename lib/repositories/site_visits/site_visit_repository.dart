import '../../models/site_visits/site_visit_model.dart';
import '../../services/site_visits/site_visit_api_service.dart';

class SiteVisitRepository {
  final SiteVisitApiService _apiService;
  final String? _token;

  SiteVisitRepository(this._apiService, [this._token]);

  // GET: Fetch all site visits
  Future<List<SiteVisitModel>> fetchSiteVisits({Map<String, String>? queryParams, String? token}) async {
    try {
      final currentToken = token ?? _token;
      if (currentToken == null) throw Exception('No authentication token');
      final response = await SiteVisitApiService.getSiteVisits(token: currentToken);

      List data = [];
      if (response['data'] != null) {
        data = response['data'] as List;
      } else if (response is List) {
        data = response as List;
      } else {
        return [];
      }

      final siteVisits = data.map((json) {
        try {
          return SiteVisitModel.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('❌ Failed to parse site visit: $e, JSON: $json');
          rethrow;
        }
      }).toList();

      print('✅ Successfully parsed ${siteVisits.length} site visits');
      return siteVisits;
    } catch (e) {
      print('💥 Failed to fetch site visits: $e');
      throw Exception('Failed to fetch site visits: $e');
    }
  }

  // POST: Create a new site visit
  Future<SiteVisitModel> createSiteVisit(SiteVisitModel siteVisit, {String? token}) async {
    try {
      final jsonData = siteVisit.toJson();
      print('📤 Creating site visit with data: $jsonData');

      final currentToken = token ?? _token;
      if (currentToken == null) throw Exception('No authentication token');
      final response = await SiteVisitApiService.createSiteVisit(jsonData, currentToken);
      print('📥 Create site visit API response: $response');

      final data = response['data'];
      if (data == null) {
        throw Exception('No data returned from create site visit API');
      }

      final createdSiteVisit = SiteVisitModel.fromJson(data);
      print('✅ Successfully created site visit: ${createdSiteVisit.id}');
      return createdSiteVisit;
    } catch (e) {
      print('❌ Failed to create site visit: $e');
      throw Exception('Failed to create site visit: $e');
    }
  }

  // PUT: Update a site visit
  Future<SiteVisitModel> updateSiteVisit(SiteVisitModel siteVisit, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      if (currentToken == null) throw Exception('No authentication token');
      final response = await SiteVisitApiService.updateSiteVisit(siteVisit.id, siteVisit.toJson(), currentToken);

      print('📦 Update Repository - API Response: $response');

      Map<String, dynamic>? data;

      if (response.containsKey('data') && response['data'] != null) {
        data = response['data'] as Map<String, dynamic>;
      } else if (response is Map<String, dynamic> && response.containsKey('id')) {
        data = response;
      } else {
        return siteVisit;
      }

      try {
        return SiteVisitModel.fromJson(data);
      } catch (e) {
        print('❌ Update Repository - Failed to parse site visit from response: $e');
        return siteVisit;
      }
    } catch (e) {
      print('❌ Update Repository - API call failed: $e');
      throw Exception('Failed to update site visit: $e');
    }
  }

  // DELETE: Delete a site visit
  Future<void> deleteSiteVisit(String id, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      if (currentToken == null) throw Exception('No authentication token');
      await SiteVisitApiService.deleteSiteVisit(id, currentToken);
    } catch (e) {
      throw Exception('Failed to delete site visit: $e');
    }
  }

  // PATCH: Update site visit status
  Future<SiteVisitModel> updateSiteVisitStatus(String id, String status, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      if (currentToken == null) throw Exception('No authentication token');
      final response = await SiteVisitApiService.updateSiteVisitStatus(id, status, currentToken);

      final data = response['data'];
      return SiteVisitModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update site visit status: $e');
    }
  }

  // PATCH: Convert to quotation
  Future<SiteVisitModel> convertToQuotation(String id, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      if (currentToken == null) throw Exception('No authentication token');
      print('🔄 Converting site visit $id to quotation...');

      final response = await SiteVisitApiService.updateSiteVisitStatus(id, 'converted', currentToken);
      print('✅ Convert to quotation API response: $response');

      final data = response['data'];
      return SiteVisitModel.fromJson(data);
    } catch (e) {
      print('❌ Failed to convert site visit to quotation: $e');
      throw Exception('Failed to convert site visit to quotation: $e');
    }
  }

  // GET: Get statistics
  Future<Map<String, dynamic>> getStatistics({Map<String, String>? queryParams, String? token}) async {
    try {
      final currentToken = token ?? _token;
      if (currentToken == null) throw Exception('No authentication token');
      final response = await SiteVisitApiService.getSiteVisitStats(token: currentToken);

      if (response['success']) {
        return response['stats'];
      } else {
        throw Exception(response['message'] ?? 'Failed to get statistics');
      }
    } catch (e) {
      print('💥 Failed to get statistics: $e');
      throw Exception('Failed to get statistics: $e');
    }
  }
}
