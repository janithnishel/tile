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
      return (_authCubit.state as AuthAuthenticated).token;
    }
    return null;
  }

  // 1. 🔄 Load Quotations
  Future<void> loadQuotations({Map<String, String>? queryParams}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      debugPrint('🚀 QuotationCubit: Starting to load quotations...');
      final loadedQuotations = await _quotationRepository.fetchQuotations(queryParams: queryParams);
      debugPrint('📦 QuotationCubit: Loaded ${loadedQuotations.length} quotations');
      emit(state.copyWith(quotations: loadedQuotations, isLoading: false));
      debugPrint('✅ QuotationCubit: Successfully updated state with quotations');
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to load quotations: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load quotations. Please check your connection.',
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
      final createdQuotation = await _quotationRepository.createQuotation(quotation);
      debugPrint('✨ QuotationCubit: Quotation created successfully: ${createdQuotation.documentNumber}');

      // Add to local state
      final updatedList = List<QuotationDocument>.from(state.quotations)..insert(0, createdQuotation);
      emit(state.copyWith(quotations: updatedList));
      debugPrint('📦 QuotationCubit: Updated local state with ${updatedList.length} quotations');
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to create quotation: $e');
      emit(state.copyWith(errorMessage: 'Failed to create quotation: ${e.toString()}'));
      rethrow;
    }
  }

  // 3. ✏️ Update Quotation
  Future<void> updateQuotation(QuotationDocument quotation) async {
    try {
      final updatedQuotation = await _quotationRepository.updateQuotation(quotation);

      // Update local state
      final updatedList = state.quotations.map((q) {
        return q.id == updatedQuotation.id ? updatedQuotation : q;
      }).toList();

      emit(state.copyWith(quotations: updatedList));
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to update quotation: $e');
      emit(state.copyWith(errorMessage: 'Failed to update quotation.'));
      rethrow;
    }
  }

  // 4. 🗑️ Delete Quotation
  Future<void> deleteQuotation(String id) async {
    try {
      await _quotationRepository.deleteQuotation(id);

      // Remove from local state
      final updatedList = state.quotations.where((q) => q.id != id).toList();
      emit(state.copyWith(quotations: updatedList));
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to delete quotation: $e');
      emit(state.copyWith(errorMessage: 'Failed to delete quotation.'));
      rethrow;
    }
  }

  // 5. 💰 Add Payment to Quotation
  Future<void> addPayment(String id, Map<String, dynamic> paymentData) async {
    try {
      final updatedQuotation = await _quotationRepository.addPayment(id, paymentData);

      // Update local state
      final updatedList = state.quotations.map((q) {
        return q.id == updatedQuotation.id ? updatedQuotation : q;
      }).toList();

      emit(state.copyWith(quotations: updatedList));
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to add payment: $e');
      emit(state.copyWith(errorMessage: 'Failed to add payment.'));
      rethrow;
    }
  }

  // 6. 🔄 Convert Quotation to Invoice
  Future<void> convertToInvoice(String id) async {
    try {
      final convertedInvoice = await _quotationRepository.convertToInvoice(id);

      // Update local state
      final updatedList = state.quotations.map((q) {
        return q.id == convertedInvoice.id ? convertedInvoice : q;
      }).toList();

      emit(state.copyWith(quotations: updatedList));
    } catch (e) {
      debugPrint('💥 QuotationCubit: Failed to convert quotation: $e');
      emit(state.copyWith(errorMessage: 'Failed to convert quotation to invoice.'));
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
