import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';
import 'package:tilework/repositories/quotation/quotation_repository.dart';
import 'quotation_state.dart';

class QuotationCubit extends Cubit<QuotationState> {
  final QuotationRepository _quotationRepository;
  final AuthCubit _authCubit;

  QuotationCubit(this._quotationRepository, this._authCubit) : super(QuotationState());

  // Helper method to get current token
  String? get _currentToken {
    if (_authCubit.state is AuthAuthenticated) {
      final token = (_authCubit.state as AuthAuthenticated).token;
      debugPrint('🔑 QuotationCubit: Retrieved token: ${token.substring(0, min(20, token.length))}...');
      debugPrint('🔑 QuotationCubit: Token length: ${token.length}');
      debugPrint('🔑 QuotationCubit: Token starts with: ${token.substring(0, 10)}');
      return token;
    }
    debugPrint('❌ QuotationCubit: No valid token found. Auth state: ${_authCubit.state.runtimeType}');
    return null;
  }

  // 1. 🔄 Load Quotations (First page - replaces existing data)
  Future<void> loadQuotations({Map<String, String>? queryParams}) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 1,
      hasMoreData: true,
      quotations: [], // Clear existing data for fresh load
    ));
    try {
      debugPrint('🚀 QuotationCubit: Starting to load quotations...');
      final queryParamsWithPage = {
        'page': '1',
        'limit': '50', // TEMPORARY: Match backend limit to show all records
        ...?queryParams,
      };
      final result = await _quotationRepository.fetchQuotations(queryParams: queryParamsWithPage, token: _currentToken);
      debugPrint('� QuotationCubit: Token being passed to fetchQuotations: ${_currentToken != null ? 'Available' : 'NULL'}');

      final loadedQuotations = (result['items'] as List<QuotationDocument>);
      final total = result['total'] is int ? result['total'] as int : int.tryParse('${result['total']}') ?? loadedQuotations.length;
      final page = result['page'] is int ? result['page'] as int : int.tryParse('${result['page']}') ?? 1;
      final limit = result['limit'] is int ? result['limit'] as int : int.tryParse('${result['limit']}') ?? 50;

      debugPrint('�📦 QuotationCubit: Loaded ${loadedQuotations.length} quotations (page $page / limit $limit / total $total)');

      // Compute hasMore properly using total, page and limit
      final hasMore = (page * limit) < total;

      emit(state.copyWith(
        quotations: loadedQuotations,
        isLoading: false,
        currentPage: page,
        hasMoreData: hasMore,
      ));
      debugPrint('✅ QuotationCubit: Successfully updated state with quotations');
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to load quotations: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load quotations. Please check your connection.',
        hasMoreData: false,
      ));
    }
  }

  // 1.5. 📄 Fetch More Quotations (Infinite scroll - appends to existing data)
  Future<void> fetchMoreQuotations({Map<String, String>? queryParams}) async {
    if (state.isFetchingMoreValue || !state.hasMoreDataValue) {
      debugPrint('🚫 QuotationCubit: Skipping fetch - isFetchingMore: ${state.isFetchingMoreValue}, hasMoreData: ${state.hasMoreDataValue}');
      return;
    }

    emit(state.copyWith(isFetchingMore: true, errorMessage: null));
    try {
      final nextPage = state.currentPageValue + 1;
      debugPrint('🚀 QuotationCubit: Fetching more quotations (page $nextPage)...');
      debugPrint('🚀 QuotationCubit: Current state - page: ${state.currentPageValue}, total items: ${state.quotations.length}, hasMore: ${state.hasMoreDataValue}');

      final queryParamsWithPage = {
        'page': nextPage.toString(),
        'limit': '50', // TEMPORARY: Match backend limit
        ...?queryParams,
      };

      final result = await _quotationRepository.fetchQuotations(queryParams: queryParamsWithPage, token: _currentToken);
      final moreQuotations = (result['items'] as List<QuotationDocument>);
      final total = result['total'] is int ? result['total'] as int : int.tryParse('${result['total']}') ?? (state.quotations.length + moreQuotations.length);
      final page = result['page'] is int ? result['page'] as int : int.tryParse('${result['page']}') ?? nextPage;
      final limit = result['limit'] is int ? result['limit'] as int : int.tryParse('${result['limit']}') ?? 50;

      debugPrint('📦 QuotationCubit: Loaded ${moreQuotations.length} more quotations (page $page / limit $limit / total $total)');

      // Determine if more pages remain
      final hasMore = (page * limit) < total;
      debugPrint('📦 QuotationCubit: Has more data: $hasMore (received ${moreQuotations.length} items)');

      // Append new data to existing list
      final updatedList = List<QuotationDocument>.from(state.quotations)..addAll(moreQuotations);
      debugPrint('📦 QuotationCubit: Total items after append: ${updatedList.length} (was ${state.quotations.length})');

      emit(state.copyWith(
        quotations: updatedList,
        isFetchingMore: false,
        currentPage: page,
        hasMoreData: hasMore,
      ));
      debugPrint('✅ QuotationCubit: Successfully appended ${moreQuotations.length} more quotations (page $nextPage)');
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to fetch more quotations: $e');
      emit(state.copyWith(
        isFetchingMore: false,
        errorMessage: 'Failed to load more quotations.',
      ));
    }
  }

  // 2. ➕ Create Quotation
  Future<void> createQuotation(QuotationDocument quotation) async {
    try {
      debugPrint('📝 QuotationCubit: Creating quotation...');

      // Validate quotation data before sending
      if (quotation.customerName.trim().isEmpty) {
        throw Exception('Customer name is required');
      }
      if (quotation.customerPhone.trim().isEmpty) {
        throw Exception('Customer phone is required');
      }
      if (quotation.lineItems.isEmpty) {
        throw Exception('At least one item is required');
      }
      if (quotation.lineItems.any((item) => item.quantity <= 0)) {
        throw Exception('All items must have quantity greater than 0');
      }

      debugPrint('✅ QuotationCubit: Validation passed, sending to backend...');
      final createdQuotation = await _quotationRepository.createQuotation(quotation, token: _currentToken);
      debugPrint('✨ QuotationCubit: Quotation created successfully: ${createdQuotation.documentNumber}');

      // Add to local state
      final updatedList = List<QuotationDocument>.from(state.quotations)..insert(0, createdQuotation);
      emit(state.copyWith(quotations: updatedList));
      debugPrint('📦 QuotationCubit: Added new quotation to state');
      debugPrint('📦 QuotationCubit: Total quotations in state: ${updatedList.length}');
      debugPrint('📦 QuotationCubit: New quotation: ${createdQuotation.documentNumber} - ${createdQuotation.customerName}');
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to create quotation: $e');
      emit(state.copyWith(errorMessage: e.toString()));
      rethrow;
    }
  }

  // 3. ✏️ Update Quotation
  Future<QuotationDocument> updateQuotation(QuotationDocument quotation) async {
    try {
      final updatedQuotation = await _quotationRepository.updateQuotation(quotation, token: _currentToken);

      // Update local state
      final updatedList = state.quotations.map((q) {
        return q.id == updatedQuotation.id ? updatedQuotation : q;
      }).toList();

      emit(state.copyWith(quotations: updatedList));
      return updatedQuotation;
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to update quotation: $e');
      emit(state.copyWith(errorMessage: e.toString()));
      rethrow;
    }
  }

  // 4. 🗑️ Delete Quotation
  Future<void> deleteQuotation(String id) async {
    try {
      await _quotationRepository.deleteQuotation(id, token: _currentToken);

      // Remove from local state
      final updatedList = state.quotations.where((q) => q.id != id).toList();
      emit(state.copyWith(quotations: updatedList));
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to delete quotation: $e');
      emit(state.copyWith(errorMessage: e.toString()));
      rethrow;
    }
  }

  // 5. 💰 Add Payment to Quotation
  Future<void> addPayment(String id, Map<String, dynamic> paymentData) async {
    try {
      final updatedQuotation = await _quotationRepository.addPayment(id, paymentData, token: _currentToken);

      // Update local state
      final updatedList = state.quotations.map((q) {
        return q.id == updatedQuotation.id ? updatedQuotation : q;
      }).toList();

      emit(state.copyWith(quotations: updatedList));
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to add payment: $e');
      emit(state.copyWith(errorMessage: e.toString()));
      rethrow;
    }
  }

  // 6. 🔄 Convert Quotation to Invoice
  Future<QuotationDocument> convertToInvoice(String id, {List<Map<String, dynamic>>? advancePayments, DateTime? customDueDate}) async {
    debugPrint('🔄 QuotationCubit: Starting conversion process...');
    debugPrint('🔄 QuotationCubit: Auth state: ${_authCubit.state.runtimeType}');
    debugPrint('🔄 QuotationCubit: Current token available: ${_currentToken != null ? 'YES' : 'NO'}');

    if (_currentToken == null) {
      const errorMsg = 'Authentication session expired. Please log out and log back in to continue.';
      debugPrint('❌ QuotationCubit: $errorMsg');
      emit(state.copyWith(errorMessage: errorMsg));
      throw Exception(errorMsg);
    }

    try {
      debugPrint('🔄 QuotationCubit: Calling repository convertToInvoice with token...');
      final convertedInvoice = await _quotationRepository.convertToInvoice(id, advancePayments: advancePayments, customDueDate: customDueDate, token: _currentToken);

      // Update local state
      final updatedList = state.quotations.map((q) {
        return q.id == convertedInvoice.id ? convertedInvoice : q;
      }).toList();

      emit(state.copyWith(quotations: updatedList));
      debugPrint('✅ QuotationCubit: Conversion successful');

      return convertedInvoice;
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to convert quotation: $e');
      emit(state.copyWith(errorMessage: e.toString()));
      rethrow;
    }
  }

  // 7. 📊 Update Quotation Status
  Future<void> updateQuotationStatus(String id, Map<String, dynamic> statusData) async {
    try {
      final updatedQuotation = await _quotationRepository.updateQuotationStatus(id, statusData, token: _currentToken);

      // Update local state
      final updatedList = state.quotations.map((q) {
        return q.id == updatedQuotation.id ? updatedQuotation : q;
      }).toList();

      emit(state.copyWith(quotations: updatedList));
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to update quotation status: $e');
      emit(state.copyWith(errorMessage: e.toString()));
      rethrow;
    }
  }

  // 7. 🎯 Select Quotation
  void selectQuotation(QuotationDocument? quotation) {
    emit(state.copyWith(selectedQuotation: quotation));
  }

  // 8. 🧹 Clear Error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
