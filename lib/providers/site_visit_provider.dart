// Site Visit Provider
import 'package:flutter/material.dart';
import '../models/site_visits/site_visit_model.dart';
import '../models/site_visits/inspection_model.dart';

class SiteVisitProvider with ChangeNotifier {
  List<SiteVisitModel> _siteVisits = [];
  String _searchTerm = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isLoading = false;

  List<SiteVisitModel> get siteVisits => _siteVisits;
  String get searchTerm => _searchTerm;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  bool get isLoading => _isLoading;

  SiteVisitProvider() {
    _loadInitialData();
  }

  void _loadInitialData() {
    _siteVisits = [
      SiteVisitModel(
        id: 'SV-001',
        customerName: 'Janith Nishel',
        projectTitle: 'Residential Flooring - Living Room',
        contactNo: '0771234567',
        location: 'No. 45, Galle Road, Colombo 03',
        date: DateTime(2025, 12, 28),
        siteType: 'Residential',
        charge: 5000,
        status: SiteVisitStatus.invoiced,
        colorCode: 'Grey',
        thickness: '8mm',
        floorCondition: ['Cement', 'Tile'],
        targetArea: ['Living', 'Hall'],
        inspection: InspectionModel(
          skirting: 'Required - 3 inch',
          floorPreparation: 'Level checking needed',
          groundSetting: 'Stable',
          door: 'Adequate clearance',
          window: 'N/A',
          evenUneven: 'Even',
          areaCondition: 'Good condition',
        ),
      ),
      SiteVisitModel(
        id: 'SV-002',
        customerName: 'Janith Nishel',
        projectTitle: 'Bedroom Flooring',
        contactNo: '0771234567',
        location: 'No. 45, Galle Road, Colombo 03',
        date: DateTime(2025, 12, 25),
        siteType: 'Residential',
        charge: 4500,
        status: SiteVisitStatus.converted,
        colorCode: 'Oak',
        thickness: '10mm',
        floorCondition: ['Cement'],
        targetArea: ['Room'],
        inspection: InspectionModel(
          skirting: 'Required - 2 inch',
          floorPreparation: 'Minor leveling',
          groundSetting: 'Good',
          door: 'OK',
          window: 'OK',
          evenUneven: 'Even',
          areaCondition: 'Excellent',
        ),
      ),
      SiteVisitModel(
        id: 'SV-003',
        customerName: 'Kasun Perera',
        projectTitle: 'Commercial Office Space',
        contactNo: '0712345678',
        location: 'Level 5, Trade Center, Negombo',
        date: DateTime(2025, 12, 29),
        siteType: 'Commercial',
        charge: 7500,
        status: SiteVisitStatus.pending,
        colorCode: 'Beige',
        thickness: '10mm',
        floorCondition: ['Concrete'],
        targetArea: ['Room', 'Kitchen'],
        inspection: InspectionModel(
          skirting: 'Not required',
          floorPreparation: 'Major work needed',
          groundSetting: 'Requires leveling',
          door: 'Needs adjustment',
          window: 'Good',
          evenUneven: 'Uneven',
          areaCondition: 'Requires preparation',
        ),
      ),
      SiteVisitModel(
        id: 'SV-004',
        customerName: 'Nethmi Silva',
        projectTitle: 'Villa Renovation Project',
        contactNo: '0763456789',
        location: '123/A, Temple Road, Gampaha',
        date: DateTime(2025, 12, 30),
        siteType: 'Residential',
        charge: 5000,
        status: SiteVisitStatus.converted,
        colorCode: 'White',
        thickness: '8mm',
        floorCondition: ['Wood', 'Tile'],
        targetArea: ['Living', 'Dining', 'Passage'],
        inspection: InspectionModel(
          skirting: 'Required',
          floorPreparation: 'Minimal work',
          groundSetting: 'Good',
          door: 'Good clearance',
          window: 'Adequate',
          evenUneven: 'Even',
          areaCondition: 'Excellent',
        ),
      ),
    ];
    notifyListeners();
  }

  // Get visits grouped by customer
  Map<String, List<SiteVisitModel>> get visitsByCustomer {
    final Map<String, List<SiteVisitModel>> grouped = {};
    for (var visit in filteredVisits) {
      if (grouped.containsKey(visit.customerName)) {
        grouped[visit.customerName]!.add(visit);
      } else {
        grouped[visit.customerName] = [visit];
      }
    }
    return grouped;
  }

  // Filtered visits
  List<SiteVisitModel> get filteredVisits {
    return _siteVisits.where((visit) {
      final matchesSearch = visit.customerName
              .toLowerCase()
              .contains(_searchTerm.toLowerCase()) ||
          visit.id.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          visit.projectTitle.toLowerCase().contains(_searchTerm.toLowerCase());

      final matchesFromDate =
          _fromDate == null || visit.date.isAfter(_fromDate!) ||
              visit.date.isAtSameMomentAs(_fromDate!);

      final matchesToDate =
          _toDate == null || visit.date.isBefore(_toDate!) ||
              visit.date.isAtSameMomentAs(_toDate!);

      return matchesSearch && matchesFromDate && matchesToDate;
    }).toList();
  }

  // Get visits for a specific customer
  List<SiteVisitModel> getVisitsForCustomer(String customerName) {
    return _siteVisits
        .where((visit) => visit.customerName == customerName)
        .toList();
  }

  // Statistics
  int get totalVisits => _siteVisits.length;

  int get convertedCount =>
      _siteVisits.where((v) => v.status == SiteVisitStatus.converted).length;

  int get invoicedCount =>
      _siteVisits.where((v) => v.status == SiteVisitStatus.invoiced).length;

  int get pendingCount =>
      _siteVisits.where((v) => v.status == SiteVisitStatus.pending).length;

  double get totalRevenue =>
      _siteVisits.fold(0, (sum, visit) => sum + visit.charge);

  // Search and Filter
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  void setFromDate(DateTime? date) {
    _fromDate = date;
    notifyListeners();
  }

  void setToDate(DateTime? date) {
    _toDate = date;
    notifyListeners();
  }

  void clearFilters() {
    _searchTerm = '';
    _fromDate = null;
    _toDate = null;
    notifyListeners();
  }

  // CRUD Operations
  String _generateId() {
    final count = _siteVisits.length + 1;
    return 'SV-${count.toString().padLeft(3, '0')}';
  }

  Future<SiteVisitModel> addSiteVisit({
    required String customerName,
    required String projectTitle,
    required String contactNo,
    required String location,
    required String siteType,
    required double charge,
    required String colorCode,
    required String thickness,
    required List<String> floorCondition,
    required List<String> targetArea,
    required InspectionModel inspection,
    String? otherDetails,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final newVisit = SiteVisitModel(
      id: _generateId(),
      customerName: customerName,
      projectTitle: projectTitle,
      contactNo: contactNo,
      location: location,
      date: DateTime.now(),
      siteType: siteType,
      charge: charge,
      status: SiteVisitStatus.pending,
      colorCode: colorCode,
      thickness: thickness,
      floorCondition: floorCondition,
      targetArea: targetArea,
      inspection: inspection,
      otherDetails: otherDetails,
    );

    _siteVisits.add(newVisit);
    _isLoading = false;
    notifyListeners();

    return newVisit;
  }

  Future<void> updateSiteVisit(SiteVisitModel updatedVisit) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final index = _siteVisits.indexWhere((v) => v.id == updatedVisit.id);
    if (index != -1) {
      _siteVisits[index] = updatedVisit.copyWith(updatedAt: DateTime.now());
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateStatus(String id, SiteVisitStatus newStatus) async {
    final index = _siteVisits.indexWhere((v) => v.id == id);
    if (index != -1) {
      _siteVisits[index] = _siteVisits[index].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> deleteSiteVisit(String id) async {
    _siteVisits.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  Future<void> convertToQuotation(String id) async {
    await updateStatus(id, SiteVisitStatus.converted);
  }

  Future<void> markAsInvoiced(String id) async {
    await updateStatus(id, SiteVisitStatus.invoiced);
  }

  void addSiteVisitModel(SiteVisitModel visit) {
    _siteVisits.add(visit);
    notifyListeners();
  }

  // Refresh method to reload site visits data
  void refreshSiteVisits() {
    _loadInitialData();
  }
}
