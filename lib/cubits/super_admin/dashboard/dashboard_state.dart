class DashboardState {
  final bool isLoading;
  final String? errorMessage;

  // Stats
  final int totalCompanies;
  final int activeCompanies;
  final int inactiveCompanies;
  final int totalCategories;
  final int totalItems;
  final int totalServices;

  // Recent data
  final List<Map<String, dynamic>> recentActivity;
  final List<Map<String, dynamic>> recentCompanies;

  DashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.totalCompanies = 0,
    this.activeCompanies = 0,
    this.inactiveCompanies = 0,
    this.totalCategories = 0,
    this.totalItems = 0,
    this.totalServices = 0,
    this.recentActivity = const [],
    this.recentCompanies = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    int? totalCompanies,
    int? activeCompanies,
    int? inactiveCompanies,
    int? totalCategories,
    int? totalItems,
    int? totalServices,
    List<Map<String, dynamic>>? recentActivity,
    List<Map<String, dynamic>>? recentCompanies,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      totalCompanies: totalCompanies ?? this.totalCompanies,
      activeCompanies: activeCompanies ?? this.activeCompanies,
      inactiveCompanies: inactiveCompanies ?? this.inactiveCompanies,
      totalCategories: totalCategories ?? this.totalCategories,
      totalItems: totalItems ?? this.totalItems,
      totalServices: totalServices ?? this.totalServices,
      recentActivity: recentActivity ?? this.recentActivity,
      recentCompanies: recentCompanies ?? this.recentCompanies,
    );
  }
}
