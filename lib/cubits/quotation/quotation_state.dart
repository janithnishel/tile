import '../../models/quotation_Invoice_screen/project/quotation_document.dart';

class QuotationState {
  final List<QuotationDocument> quotations;
  final bool isLoading;
  final String? errorMessage;
  final QuotationDocument? selectedQuotation;

  // Pagination variables
  final int? currentPage;
  final bool? isFetchingMore;
  final bool? hasMoreData;

  QuotationState({
    this.quotations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedQuotation,
    this.currentPage = 1,
    this.isFetchingMore = false,
    this.hasMoreData = true,
  });

  // Getters with defaults to ensure non-null values
  int get currentPageValue => currentPage ?? 1;
  bool get isFetchingMoreValue => isFetchingMore ?? false;
  bool get hasMoreDataValue => hasMoreData ?? true;

  QuotationState copyWith({
    List<QuotationDocument>? quotations,
    bool? isLoading,
    String? errorMessage,
    QuotationDocument? selectedQuotation,
    int? currentPage,
    bool? isFetchingMore,
    bool? hasMoreData,
  }) {
    return QuotationState(
      quotations: quotations ?? this.quotations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedQuotation: selectedQuotation ?? this.selectedQuotation,
      currentPage: currentPage ?? this.currentPageValue,
      isFetchingMore: isFetchingMore ?? this.isFetchingMoreValue,
      hasMoreData: hasMoreData ?? this.hasMoreDataValue,
    );
  }
}
