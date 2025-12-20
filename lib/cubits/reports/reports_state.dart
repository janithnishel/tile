import 'package:equatable/equatable.dart';

class ReportsState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  // Sales Summary
  final Map<String, dynamic>? salesSummary;

  // Profit Analysis
  final Map<String, dynamic>? profitAnalysis;

  // Customer Summary
  final List<dynamic>? customerSummary;

  // Supplier Summary
  final List<dynamic>? supplierSummary;

  // Outstanding Payments
  final Map<String, dynamic>? outstandingPayments;

  // Date Range Filters
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportsState({
    this.isLoading = false,
    this.errorMessage,
    this.salesSummary,
    this.profitAnalysis,
    this.customerSummary,
    this.supplierSummary,
    this.outstandingPayments,
    this.startDate,
    this.endDate,
  });

  ReportsState copyWith({
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? salesSummary,
    Map<String, dynamic>? profitAnalysis,
    List<dynamic>? customerSummary,
    List<dynamic>? supplierSummary,
    Map<String, dynamic>? outstandingPayments,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      salesSummary: salesSummary ?? this.salesSummary,
      profitAnalysis: profitAnalysis ?? this.profitAnalysis,
      customerSummary: customerSummary ?? this.customerSummary,
      supplierSummary: supplierSummary ?? this.supplierSummary,
      outstandingPayments: outstandingPayments ?? this.outstandingPayments,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    salesSummary,
    profitAnalysis,
    customerSummary,
    supplierSummary,
    outstandingPayments,
    startDate,
    endDate,
  ];
}
