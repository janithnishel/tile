import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/models/site_visits/site_visit_model.dart';
import 'package:tilework/repositories/site_visits/site_visit_repository.dart';
import 'site_visit_state.dart';

class SiteVisitCubit extends Cubit<SiteVisitState> {
  final SiteVisitRepository _siteVisitRepository;
  final AuthCubit _authCubit;

  SiteVisitCubit(this._siteVisitRepository, this._authCubit) : super(SiteVisitState());

  // Helper method to get current token
  String? get _currentToken {
    if (_authCubit.state is AuthAuthenticated) {
      final token = (_authCubit.state as AuthAuthenticated).token;
      debugPrint('🔑 SiteVisitCubit: Retrieved token: ${token.substring(0, min(20, token.length))}...');
      return token;
    }
    debugPrint('❌ SiteVisitCubit: No valid token found. Auth state: ${_authCubit.state.runtimeType}');
    return null;
  }

  // 1. 🔄 Load Site Visits
  Future<void> loadSiteVisits({Map<String, String>? queryParams}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 SiteVisitCubit: Starting to load site visits...');
      final loadedSiteVisits = await _siteVisitRepository.fetchSiteVisits(queryParams: queryParams, token: _currentToken);
      debugPrint('📦 SiteVisitCubit: Loaded ${loadedSiteVisits.length} site visits');
      emit(state.copyWith(siteVisits: loadedSiteVisits, isLoading: false));
      debugPrint('✅ SiteVisitCubit: Successfully updated state with site visits');
    } catch (e) {
      debugPrint('💥 SiteVisitCubit: Failed to load site visits: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load site visits. Please check your connection.',
      ));
    }
  }

  // 2. ➕ Create Site Visit
  Future<void> createSiteVisit(SiteVisitModel siteVisit) async {
    try {
      debugPrint('📝 SiteVisitCubit: Creating site visit...');

      // Validate site visit data before sending
      if (siteVisit.customerName.trim().isEmpty) {
        throw Exception('Customer name is required');
      }
      if (siteVisit.contactNo.trim().isEmpty) {
        throw Exception('Contact number is required');
      }
      if (siteVisit.location.trim().isEmpty) {
        throw Exception('Location is required');
      }

      debugPrint('✅ SiteVisitCubit: Validation passed, sending to backend...');
      final createdSiteVisit = await _siteVisitRepository.createSiteVisit(siteVisit, token: _currentToken);
      debugPrint('✨ SiteVisitCubit: Site visit created successfully: ${createdSiteVisit.id}');

      // Add to local state
      final updatedList = List<SiteVisitModel>.from(state.siteVisits)..insert(0, createdSiteVisit);
      emit(state.copyWith(siteVisits: updatedList));
      debugPrint('📦 SiteVisitCubit: Updated local state with ${updatedList.length} site visits');
    } catch (e) {
      debugPrint('💥 SiteVisitCubit: Failed to create site visit: $e');
      emit(state.copyWith(errorMessage: 'Failed to create site visit: ${e.toString()}'));
      rethrow;
    }
  }

  // 3. ✏️ Update Site Visit
  Future<void> updateSiteVisit(SiteVisitModel siteVisit) async {
    try {
      final updatedSiteVisit = await _siteVisitRepository.updateSiteVisit(siteVisit, token: _currentToken);

      // Update local state
      final updatedList = state.siteVisits.map((sv) {
        return sv.id == updatedSiteVisit.id ? updatedSiteVisit : sv;
      }).toList();

      emit(state.copyWith(siteVisits: updatedList));
    } catch (e) {
      debugPrint('💥 SiteVisitCubit: Failed to update site visit: $e');
      emit(state.copyWith(errorMessage: 'Failed to update site visit.'));
      rethrow;
    }
  }

  // 4. 🗑️ Delete Site Visit
  Future<void> deleteSiteVisit(String id) async {
    try {
      await _siteVisitRepository.deleteSiteVisit(id, token: _currentToken);

      // Remove from local state
      final updatedList = state.siteVisits.where((sv) => sv.id != id).toList();
      emit(state.copyWith(siteVisits: updatedList));
    } catch (e) {
      debugPrint('💥 SiteVisitCubit: Failed to delete site visit: $e');
      emit(state.copyWith(errorMessage: 'Failed to delete site visit.'));
      rethrow;
    }
  }

  // 5. 🔄 Update Site Visit Status
  Future<void> updateSiteVisitStatus(String id, String status) async {
    try {
      final updatedSiteVisit = await _siteVisitRepository.updateSiteVisitStatus(id, status, token: _currentToken);

      // Update local state
      final updatedList = state.siteVisits.map((sv) {
        return sv.id == updatedSiteVisit.id ? updatedSiteVisit : sv;
      }).toList();

      emit(state.copyWith(siteVisits: updatedList));
    } catch (e) {
      debugPrint('💥 SiteVisitCubit: Failed to update site visit status: $e');
      emit(state.copyWith(errorMessage: 'Failed to update site visit status.'));
      rethrow;
    }
  }

  // 6. 💰 Convert to Quotation
  Future<SiteVisitModel> convertToQuotation(String id) async {
    try {
      final convertedSiteVisit = await _siteVisitRepository.convertToQuotation(id, token: _currentToken);

      // Update local state
      final updatedList = state.siteVisits.map((sv) {
        return sv.id == convertedSiteVisit.id ? convertedSiteVisit : sv;
      }).toList();

      emit(state.copyWith(siteVisits: updatedList));

      return convertedSiteVisit;
    } catch (e) {
      debugPrint('💥 SiteVisitCubit: Failed to convert to quotation: $e');
      emit(state.copyWith(errorMessage: 'Failed to convert to quotation.'));
      rethrow;
    }
  }

  // 7. 📊 Get Statistics
  Future<void> loadStatistics({Map<String, String>? queryParams}) async {
    try {
      final stats = await _siteVisitRepository.getStatistics(queryParams: queryParams, token: _currentToken);
      emit(state.copyWith(statistics: stats));
    } catch (e) {
      debugPrint('💥 SiteVisitCubit: Failed to load statistics: $e');
      emit(state.copyWith(errorMessage: 'Failed to load statistics.'));
    }
  }

  // 8. 🎯 Select Site Visit
  void selectSiteVisit(SiteVisitModel? siteVisit) {
    emit(state.copyWith(selectedSiteVisit: siteVisit));
  }

  // 9. 🧹 Clear Error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
