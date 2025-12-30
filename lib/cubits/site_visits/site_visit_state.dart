import '../../models/site_visits/site_visit_model.dart';

class SiteVisitState {
  final List<SiteVisitModel> siteVisits;
  final Map<String, dynamic>? statistics;
  final bool isLoading;
  final String? errorMessage;
  final SiteVisitModel? selectedSiteVisit;

  SiteVisitState({
    this.siteVisits = const [],
    this.statistics,
    this.isLoading = false,
    this.errorMessage,
    this.selectedSiteVisit,
  });

  SiteVisitState copyWith({
    List<SiteVisitModel>? siteVisits,
    Map<String, dynamic>? statistics,
    bool? isLoading,
    String? errorMessage,
    SiteVisitModel? selectedSiteVisit,
  }) {
    return SiteVisitState(
      siteVisits: siteVisits ?? this.siteVisits,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedSiteVisit: selectedSiteVisit ?? this.selectedSiteVisit,
    );
  }
}
