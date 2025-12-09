import '../../models/quotation_Invoice_screen/project/quotation_document.dart';

class QuotationState {
  final List<QuotationDocument> quotations;
  final bool isLoading;
  final String? errorMessage;
  final QuotationDocument? selectedQuotation;

  QuotationState({
    this.quotations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedQuotation,
  });

  QuotationState copyWith({
    List<QuotationDocument>? quotations,
    bool? isLoading,
    String? errorMessage,
    QuotationDocument? selectedQuotation,
  }) {
    return QuotationState(
      quotations: quotations ?? this.quotations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedQuotation: selectedQuotation ?? this.selectedQuotation,
    );
  }
}
