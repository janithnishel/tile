import 'package:tilework/models/company_model.dart';

import '../../services/super_admin/company_api_service.dart';

class CompanyRepository {
  final CompanyApiService _companyApiService;

  CompanyRepository(this._companyApiService);

  // GET: Fetch all companies
  Future<List<CompanyModel>> fetchCompanies({String? token}) async {
    try {
      // Backend returns: {success: true, data: [...]}
      final response = await _companyApiService.getAllCompanies(token: token);
      final List data = response['data'] ?? [];

      return data.map((json) => CompanyModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch companies: $e');
    }
  }

  // PUT: Update a company
  Future<CompanyModel> updateCompany(CompanyModel company, {String? token}) async {
    try {
      final response = await _companyApiService.updateCompany(company.id, company.toJson(), token: token);

      // Backend should return the updated company data
      final data = response['data'];
      return CompanyModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update company: $e');
    }
  }

  // DELETE: Delete a company
  Future<void> deleteCompany(String id, {String? token}) async {
    try {
      await _companyApiService.deleteCompany(id, token: token);
    } catch (e) {
      throw Exception('Failed to delete company: $e');
    }
  }
}
