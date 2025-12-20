import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/repositories/dashboard/dashboard_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;
  final AuthCubit _authCubit;

  DashboardCubit(this._dashboardRepository, this._authCubit) : super(const DashboardState());

  // Helper method to get current token
  String? get _currentToken {
    if (_authCubit.state is AuthAuthenticated) {
      final token = (_authCubit.state as AuthAuthenticated).token;
      debugPrint('🔑 DashboardCubit: Retrieved token: ${token.substring(0, min(20, token.length))}...');
      return token;
    }
    debugPrint('❌ DashboardCubit: No valid token found. Auth state: ${_authCubit.state.runtimeType}');
    return null;
  }

  // Helper method to convert period enum to API string
  String _periodToApiString(String period) {
    switch (period) {
      case 'last7Days':
        return 'last7days';
      case 'last30Days':
        return 'last30days';
      case 'last3Months':
        return 'last3months';
      case 'last6Months':
        return 'last6months';
      case 'lastYear':
        return 'lastyear';
      case 'today':
        return 'today';
      case 'thisMonth':
        return 'thisMonth';
      case 'ytd':
        return 'ytd';
      default:
        return 'last30days';
    }
  }

  // 1. 🔄 Load Dashboard Statistics
  Future<void> loadDashboardStats({String? period}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 DashboardCubit: Loading dashboard stats...');

      final apiPeriod = period ?? state.selectedPeriod;
      final apiPeriodString = apiPeriod != null ? _periodToApiString(apiPeriod) : null;

      final stats = await _dashboardRepository.fetchDashboardStats(
        token: _currentToken,
        period: apiPeriodString,
      );

      emit(state.copyWith(
        dashboardStats: stats,
        selectedPeriod: apiPeriod ?? state.selectedPeriod,
        isLoading: false,
      ));
      debugPrint('✅ DashboardCubit: Dashboard stats loaded successfully');
    } catch (e) {
      debugPrint('💥 DashboardCubit: Failed to load dashboard stats: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load dashboard stats. Please try again.',
      ));
    }
  }

  // 2. 🔄 Load Revenue Trend Chart Data
  Future<void> loadRevenueTrend({String? period}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 DashboardCubit: Loading revenue trend...');

      final apiPeriod = period ?? state.selectedPeriod;
      final apiPeriodString = apiPeriod != null ? _periodToApiString(apiPeriod) : null;

      final trendData = await _dashboardRepository.fetchRevenueTrend(
        token: _currentToken,
        period: apiPeriodString,
      );

      emit(state.copyWith(
        revenueTrend: trendData,
        selectedPeriod: apiPeriod ?? state.selectedPeriod,
        isLoading: false,
      ));
      debugPrint('✅ DashboardCubit: Revenue trend loaded successfully: ${trendData.length} data points');
    } catch (e) {
      debugPrint('💥 DashboardCubit: Failed to load revenue trend: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load revenue trend. Please try again.',
      ));
    }
  }

  // 3. 🔄 Load Profit Breakdown Chart Data
  Future<void> loadProfitBreakdown({String? period}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 DashboardCubit: Loading profit breakdown...');

      final apiPeriod = period ?? state.selectedPeriod;
      final apiPeriodString = apiPeriod != null ? _periodToApiString(apiPeriod) : null;

      final breakdownData = await _dashboardRepository.fetchProfitBreakdown(
        token: _currentToken,
        period: apiPeriodString,
      );

      emit(state.copyWith(
        profitBreakdown: breakdownData,
        selectedPeriod: apiPeriod ?? state.selectedPeriod,
        isLoading: false,
      ));
      debugPrint('✅ DashboardCubit: Profit breakdown loaded successfully: ${breakdownData.length} segments');
    } catch (e) {
      debugPrint('💥 DashboardCubit: Failed to load profit breakdown: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profit breakdown. Please try again.',
      ));
    }
  }

  // 4. 🔄 Load Actionable Items
  Future<void> loadActionableItems() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 DashboardCubit: Loading actionable items...');

      final items = await _dashboardRepository.fetchActionableItems(
        token: _currentToken,
      );

      emit(state.copyWith(
        actionableItems: items,
        isLoading: false,
      ));
      debugPrint('✅ DashboardCubit: Actionable items loaded successfully');
    } catch (e) {
      debugPrint('💥 DashboardCubit: Failed to load actionable items: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load actionable items. Please try again.',
      ));
    }
  }

  // 5. 🔄 Load All Dashboard Data
  Future<void> loadAllDashboardData({String? period}) async {
    await Future.wait([
      loadDashboardStats(period: period),
      loadRevenueTrend(period: period),
      loadProfitBreakdown(period: period),
      loadActionableItems(),
    ]);
  }

  // 6. 📅 Update Selected Period
  void updateSelectedPeriod(String period) {
    emit(state.copyWith(selectedPeriod: period));
  }

  // 7. 🔄 Refresh Dashboard Data
  Future<void> refreshDashboard() async {
    await loadAllDashboardData(period: state.selectedPeriod);
  }

  // 8. 🧹 Clear Error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
