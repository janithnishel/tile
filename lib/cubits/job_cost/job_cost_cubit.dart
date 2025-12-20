import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';
import 'package:tilework/repositories/job_cost/job_cost_repository.dart';
import 'job_cost_state.dart';

class JobCostCubit extends Cubit<JobCostState> {
  final JobCostRepository _jobCostRepository;
  final AuthCubit _authCubit;

  JobCostCubit(this._jobCostRepository, this._authCubit) : super(JobCostState());

  // Helper method to get current token
  String? get _currentToken {
    if (_authCubit.state is AuthAuthenticated) {
      final token = (_authCubit.state as AuthAuthenticated).token;
      debugPrint('🔑 JobCostCubit: Retrieved token: ${token.substring(0, min(20, token.length))}...');
      return token;
    }
    debugPrint('❌ JobCostCubit: No valid token found. Auth state: ${_authCubit.state.runtimeType}');
    return null;
  }

  // 1. 🔄 Load Job Costs
  Future<void> loadJobCosts({Map<String, String>? queryParams}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 JobCostCubit: Starting to load job costs...');
      debugPrint('🔍 JobCostCubit: Query params: $queryParams');
      debugPrint('🔑 JobCostCubit: Token available: ${_currentToken != null}');

      final loadedJobCosts = await _jobCostRepository.fetchJobCosts(
        queryParams: queryParams,
        token: _currentToken,
      );

      debugPrint('📦 JobCostCubit: Loaded ${loadedJobCosts.length} job costs');
      if (loadedJobCosts.isNotEmpty) {
        debugPrint('📋 JobCostCubit: First job cost: ${loadedJobCosts.first.invoiceId} - ${loadedJobCosts.first.customerName}');
      }

      emit(state.copyWith(jobCosts: loadedJobCosts, isLoading: false));
      debugPrint('✅ JobCostCubit: Successfully updated state with job costs');
    } catch (e) {
      debugPrint('💥 JobCostCubit: Failed to load job costs: $e');
      debugPrint('🔍 JobCostCubit: Error details: ${e.toString()}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load job costs. Please check your connection.',
      ));
    }
  }

  // 2. ➕ Create Job Cost
  Future<void> createJobCost(JobCostDocument jobCost) async {
    try {
      debugPrint('📝 JobCostCubit: Creating job cost...');

      // Validate job cost data before sending
      if (jobCost.customerName.trim().isEmpty) {
        throw Exception('Customer name is required');
      }
      if (jobCost.projectTitle.trim().isEmpty) {
        throw Exception('Project title is required');
      }
      if (jobCost.invoiceItems.isEmpty) {
        throw Exception('At least one invoice item is required');
      }

      debugPrint('✅ JobCostCubit: Validation passed, sending to backend...');
      final createdJobCost = await _jobCostRepository.createJobCost(
        jobCost,
        token: _currentToken,
      );
      debugPrint('✨ JobCostCubit: Job cost created successfully: ${createdJobCost.invoiceId}');

      // Add to local state
      final updatedList = List<JobCostDocument>.from(state.jobCosts)..insert(0, createdJobCost);
      emit(state.copyWith(jobCosts: updatedList));
      debugPrint('📦 JobCostCubit: Updated local state with ${updatedList.length} job costs');
    } catch (e) {
      debugPrint('💥 JobCostCubit: Failed to create job cost: $e');
      emit(state.copyWith(errorMessage: 'Failed to create job cost: ${e.toString()}'));
      rethrow;
    }
  }

  // 3. ✏️ Update Job Cost
  Future<void> updateJobCost(JobCostDocument jobCost) async {
    try {
      final updatedJobCost = await _jobCostRepository.updateJobCost(
        jobCost,
        token: _currentToken,
      );

      // Update local state
      final updatedList = state.jobCosts.map((jc) {
        return jc.id == updatedJobCost.id ? updatedJobCost : jc;
      }).toList();

      emit(state.copyWith(jobCosts: updatedList));
    } catch (e) {
      debugPrint('💥 JobCostCubit: Failed to update job cost: $e');
      emit(state.copyWith(errorMessage: 'Failed to update job cost.'));
      rethrow;
    }
  }

  // 4. 🗑️ Delete Job Cost
  Future<void> deleteJobCost(String id) async {
    try {
      await _jobCostRepository.deleteJobCost(id, token: _currentToken);

      // Remove from local state
      final updatedList = state.jobCosts.where((jc) => jc.id != id).toList();
      emit(state.copyWith(jobCosts: updatedList));
    } catch (e) {
      debugPrint('💥 JobCostCubit: Failed to delete job cost: $e');
      emit(state.copyWith(errorMessage: 'Failed to delete job cost.'));
      rethrow;
    }
  }

  // 5. 🎯 Select Job Cost
  void selectJobCost(JobCostDocument? jobCost) {
    emit(state.copyWith(selectedJobCost: jobCost));
  }

  // 6. 🧹 Clear Error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
