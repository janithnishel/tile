import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/super_admin/company/company_state.dart';
import 'package:tilework/models/company_model.dart';
import 'package:tilework/repositories/super_admin/company_repository.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepository _companyRepository;

  CompanyCubit(this._companyRepository) : super(CompanyState());

  // Helper method to get token from AuthCubit
  String? _getToken(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      return authState.token;
    }
    return null;
  }

  // 1. 🔄 Load Companies
  Future<void> loadCompanies({String? token}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final loadedCompanies = await _companyRepository.fetchCompanies(token: token);
      emit(state.copyWith(companies: loadedCompanies, isLoading: false));
    } catch (e) {
      debugPrint('💥 CompanyCubit: Failed to load companies: $e');
      emit(state.copyWith(
          isLoading: false, errorMessage: 'Failed to load companies.'));
    }
  }

  // 2. ✏️ Update Company
  Future<void> updateCompany(CompanyModel company, {String? token}) async {
    try {
      // 1. API Call
      final updatedCompany = await _companyRepository.updateCompany(company, token: token);

      // 2. Local State Update
      final updatedList = state.companies.map((c) {
        return c.id == updatedCompany.id ? updatedCompany : c;
      }).toList();

      emit(state.copyWith(companies: updatedList, isLoading: false));
    } catch (e) {
      debugPrint('💥 CompanyCubit: Failed to update company: $e');
      emit(state.copyWith(errorMessage: 'Failed to update company.'));
      rethrow;
    }
  }

  // 3. 🗑️ Delete Company
  Future<void> deleteCompany(String companyId, {String? token}) async {
    try {
      // 1. API Call
      await _companyRepository.deleteCompany(companyId, token: token);

      // 2. Local State Update
      final updatedList =
          state.companies.where((c) => c is CompanyModel && c.id != companyId).toList();

      emit(state.copyWith(companies: updatedList, isLoading: false));
    } catch (e) {
      debugPrint('💥 CompanyCubit: Failed to delete company: $e');
      emit(state.copyWith(errorMessage: 'Failed to delete company.'));
      rethrow;
    }
  }
}
