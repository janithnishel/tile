import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/repositories/reports/reports_repository.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository _reportsRepository;
  final AuthCubit _authCubit;

  ReportsCubit(this._reportsRepository, this._authCubit) : super(ReportsState());

  // Helper method to get current token
  String? get _currentToken {
    if (_authCubit.state is AuthAuthenticated) {
      final token = (_authCubit.state as AuthAuthenticated).token;
      debugPrint('🔑 ReportsCubit: Retrieved token: ${token.substring(0, min(20, token.length))}...');
      return token;
    }
    debugPrint('❌ ReportsCubit: No valid token found. Auth state: ${_authCubit.state.runtimeType}');
    return null;
  }

  // Helper method to format dates for API
  String? _formatDate(DateTime? date) {
    return date?.toIso8601String().split('T')[0]; // YYYY-MM-DD format
  }

  // 1. 🔄 Load Sales Summary
  Future<void> loadSalesSummary({DateTime? startDate, DateTime? endDate}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 ReportsCubit: Loading sales summary...');

      final response = await _reportsRepository.fetchSalesSummary(
        token: _currentToken,
        startDate: _formatDate(startDate ?? state.startDate),
        endDate: _formatDate(endDate ?? state.endDate),
      );

      // Backend returns: {success: true, data: {...}}
      final data = response['data'];
      if (data == null) {
        throw Exception('No data returned from sales summary API');
      }

      emit(state.copyWith(
        salesSummary: data,
        startDate: startDate ?? state.startDate,
        endDate: endDate ?? state.endDate,
        isLoading: false,
      ));
      debugPrint('✅ ReportsCubit: Sales summary loaded successfully');
    } catch (e) {
      debugPrint('💥 ReportsCubit: Failed to load sales summary: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load sales summary. Please try again.',
      ));
    }
  }

  // 2. 🔄 Load Profit Analysis
  Future<void> loadProfitAnalysis({DateTime? startDate, DateTime? endDate}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 ReportsCubit: Loading profit analysis...');

      final response = await _reportsRepository.fetchProfitAnalysis(
        token: _currentToken,
        startDate: _formatDate(startDate ?? state.startDate),
        endDate: _formatDate(endDate ?? state.endDate),
      );

      // Backend returns: {success: true, data: {...}}
      final data = response['data'];
      if (data == null) {
        throw Exception('No data returned from profit analysis API');
      }

      emit(state.copyWith(
        profitAnalysis: data,
        startDate: startDate ?? state.startDate,
        endDate: endDate ?? state.endDate,
        isLoading: false,
      ));
      debugPrint('✅ ReportsCubit: Profit analysis loaded successfully');
    } catch (e) {
      debugPrint('💥 ReportsCubit: Failed to load profit analysis: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profit analysis. Please try again.',
      ));
    }
  }

  // 3. 🔄 Load Customer Summary
  Future<void> loadCustomerSummary({DateTime? startDate, DateTime? endDate}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 ReportsCubit: Loading customer summary...');

      final customers = await _reportsRepository.fetchCustomerSummary(
        token: _currentToken,
        startDate: _formatDate(startDate ?? state.startDate),
        endDate: _formatDate(endDate ?? state.endDate),
      );

      emit(state.copyWith(
        customerSummary: customers,
        startDate: startDate ?? state.startDate,
        endDate: endDate ?? state.endDate,
        isLoading: false,
      ));
      debugPrint('✅ ReportsCubit: Customer summary loaded successfully: ${customers.length} customers');
    } catch (e) {
      debugPrint('💥 ReportsCubit: Failed to load customer summary: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load customer summary. Please try again.',
      ));
    }
  }

  // 4. 🔄 Load Supplier Summary
  Future<void> loadSupplierSummary({DateTime? startDate, DateTime? endDate}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 ReportsCubit: Loading supplier summary...');

      final suppliers = await _reportsRepository.fetchSupplierSummary(
        token: _currentToken,
        startDate: _formatDate(startDate ?? state.startDate),
        endDate: _formatDate(endDate ?? state.endDate),
      );

      emit(state.copyWith(
        supplierSummary: suppliers,
        startDate: startDate ?? state.startDate,
        endDate: endDate ?? state.endDate,
        isLoading: false,
      ));
      debugPrint('✅ ReportsCubit: Supplier summary loaded successfully: ${suppliers.length} suppliers');
    } catch (e) {
      debugPrint('💥 ReportsCubit: Failed to load supplier summary: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load supplier summary. Please try again.',
      ));
    }
  }

  // 5. 🔄 Load Outstanding Payments
  Future<void> loadOutstandingPayments() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 ReportsCubit: Loading outstanding payments...');

      final payments = await _reportsRepository.fetchOutstandingPayments(
        token: _currentToken,
      );

      emit(state.copyWith(
        outstandingPayments: payments,
        isLoading: false,
      ));
      debugPrint('✅ ReportsCubit: Outstanding payments loaded successfully');
    } catch (e) {
      debugPrint('💥 ReportsCubit: Failed to load outstanding payments: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load outstanding payments. Please try again.',
      ));
    }
  }

  // 6. 📅 Update Date Range
  void updateDateRange({DateTime? startDate, DateTime? endDate}) {
    emit(state.copyWith(
      startDate: startDate ?? state.startDate,
      endDate: endDate ?? state.endDate,
    ));
  }

  // 7. 🔄 Refresh All Reports
  Future<void> refreshAllReports() async {
    await Future.wait([
      loadSalesSummary(),
      loadProfitAnalysis(),
      loadCustomerSummary(),
      loadSupplierSummary(),
      loadOutstandingPayments(),
    ]);
  }

  // 8. 🧹 Clear Error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
