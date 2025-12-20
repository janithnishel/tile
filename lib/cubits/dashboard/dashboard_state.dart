import 'package:equatable/equatable.dart';

class DashboardState extends Equatable {
  final Map<String, dynamic>? dashboardStats;
  final List<dynamic>? revenueTrend;
  final List<dynamic>? profitBreakdown;
  final Map<String, dynamic>? actionableItems;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedPeriod;

  const DashboardState({
    this.dashboardStats,
    this.revenueTrend,
    this.profitBreakdown,
    this.actionableItems,
    this.isLoading = false,
    this.errorMessage,
    this.selectedPeriod = 'last30days',
  });

  DashboardState copyWith({
    Map<String, dynamic>? dashboardStats,
    List<dynamic>? revenueTrend,
    List<dynamic>? profitBreakdown,
    Map<String, dynamic>? actionableItems,
    bool? isLoading,
    String? errorMessage,
    String? selectedPeriod,
  }) {
    return DashboardState(
      dashboardStats: dashboardStats ?? this.dashboardStats,
      revenueTrend: revenueTrend ?? this.revenueTrend,
      profitBreakdown: profitBreakdown ?? this.profitBreakdown,
      actionableItems: actionableItems ?? this.actionableItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }

  @override
  List<Object?> get props => [
        dashboardStats,
        revenueTrend,
        profitBreakdown,
        actionableItems,
        isLoading,
        errorMessage,
        selectedPeriod,
      ];
}
