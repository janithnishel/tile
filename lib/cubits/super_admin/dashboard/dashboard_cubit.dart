import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/super_admin/dashboard_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardCubit(this._dashboardRepository) : super(DashboardState());

  // =================== DASHBOARD OPERATIONS ===================

  // 1. Load Dashboard Data
  Future<void> loadDashboardData({String? token}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final dashboardData = await _dashboardRepository.fetchDashboardStats(token: token);

      final stats = dashboardData['stats'] ?? {};
      final recentActivity = (dashboardData['recentActivity'] as List<dynamic>?)
          ?.map((item) => Map<String, dynamic>.from(item))
          .toList() ?? [];
      final recentCompanies = (dashboardData['recentCompanies'] as List<dynamic>?)
          ?.map((item) => Map<String, dynamic>.from(item))
          .toList() ?? [];

      emit(state.copyWith(
        isLoading: false,
        totalCompanies: (stats['totalCompanies'] as int?) ?? 0,
        activeCompanies: (stats['activeCompanies'] as int?) ?? 0,
        inactiveCompanies: (stats['inactiveCompanies'] as int?) ?? 0,
        totalCategories: (stats['totalCategories'] as int?) ?? 0,
        totalItems: (stats['totalItems'] as int?) ?? 0,
        totalServices: (stats['totalServices'] as int?) ?? 0,
        recentActivity: recentActivity,
        recentCompanies: recentCompanies,
      ));
    } catch (e) {
      debugPrint('💥 DashboardCubit: Failed to load dashboard data: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load dashboard data.',
      ));
    }
  }

  // =================== UTILITY METHODS ===================

  // Clear Error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  // Refresh Data
  Future<void> refreshData({String? token}) async {
    await loadDashboardData(token: token);
  }
}
