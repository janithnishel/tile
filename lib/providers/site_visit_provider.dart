// Site Visit Provider
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/site_visits/site_visit_model.dart';
import '../models/site_visits/inspection_model.dart';
import '../services/site_visits/site_visit_api_service.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';

class SiteVisitProvider with ChangeNotifier {
  List<SiteVisitModel> _siteVisits = [];
  Map<String, dynamic>? _stats;
  String _searchTerm = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isLoading = false;
  String? _errorMessage;
  String? _authToken;

  // Getters
  List<SiteVisitModel> get siteVisits => _siteVisits;
  Map<String, dynamic>? get stats => _stats;
  String get searchTerm => _searchTerm;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SiteVisitProvider() {
    // Don't load immediately - token will be set later
  }

  // Set auth token (called from UI when auth state is available)
  void setAuthToken(String? token) {
    _authToken = token;
    if (_authToken != null && _siteVisits.isEmpty) {
      loadSiteVisits();
    }
  }

  // Load site visits from API
  Future<void> loadSiteVisits() async {
    if (_authToken == null) return; // Wait for token

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await SiteVisitApiService.getSiteVisits(
        token: _authToken!,
        search: _searchTerm.isNotEmpty ? _searchTerm : null,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      if (result['success']) {
        _siteVisits = result['siteVisits'];
        await loadStats();
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Failed to load site visits: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load statistics from API
  Future<void> loadStats() async {
    if (_authToken == null) return;

    try {
      final result = await SiteVisitApiService.getSiteVisitStats(
        token: _authToken!,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      if (result['success']) {
        _stats = result['stats'];
      }
    } catch (e) {
      // Stats loading failure shouldn't block the UI
      print('Failed to load stats: $e');
    }
  }

  // Get visits grouped by customer (using API data)
  Future<Map<String, dynamic>> getGroupedSiteVisits() async {
    if (_authToken == null) {
      return {'success': false, 'message': 'No authentication token'};
    }

    try {
      final result = await SiteVisitApiService.getSiteVisitsGroupedByCustomer(
        token: _authToken!,
        search: _searchTerm.isNotEmpty ? _searchTerm : null,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load grouped visits: $e',
      };
    }
  }

  // Get visits grouped by customer (local computation for UI)
  Map<String, List<SiteVisitModel>> get visitsByCustomer {
    final Map<String, List<SiteVisitModel>> grouped = {};
    for (var visit in _siteVisits) {
      if (grouped.containsKey(visit.customerName)) {
        grouped[visit.customerName]!.add(visit);
      } else {
        grouped[visit.customerName] = [visit];
      }
    }
    return grouped;
  }

  // Filtered visits (local filtering)
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

  // Statistics (computed from API data or local data)
  int get totalVisits => _stats?['totalVisits'] ?? _siteVisits.length;
  int get convertedCount => _stats?['convertedCount'] ?? _siteVisits.where((v) => v.status == SiteVisitStatus.converted).length;
  int get invoicedCount => _stats?['invoicedCount'] ?? _siteVisits.where((v) => v.status == SiteVisitStatus.invoiced).length;
  int get paidCount => _stats?['paidCount'] ?? _siteVisits.where((v) => v.status == SiteVisitStatus.paid).length;
  int get pendingCount => _stats?['pendingCount'] ?? _siteVisits.where((v) => v.status == SiteVisitStatus.pending).length;
  double get totalRevenue => _stats?['totalRevenue']?.toDouble() ?? _siteVisits.fold(0.0, (sum, visit) => sum + visit.charge);

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

  // CRUD Operations with API integration

  Future<SiteVisitModel?> createSiteVisit({
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
    if (_authToken == null) return null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final siteVisitData = {
        'customerName': customerName,
        'projectTitle': projectTitle,
        'contactNo': contactNo,
        'location': location,
        'siteType': siteType,
        'charge': charge,
        'colorCode': colorCode,
        'thickness': thickness,
        'floorCondition': floorCondition,
        'targetArea': targetArea,
        'inspection': inspection.toJson(),
        'otherDetails': otherDetails,
      };

      final result = await SiteVisitApiService.createSiteVisit(siteVisitData, _authToken!);

      if (result['success']) {
        final newVisit = result['siteVisit'];
        _siteVisits.add(newVisit);
        await loadStats(); // Refresh stats
        return newVisit;
      } else {
        _errorMessage = result['message'];
        return null;
      }
    } catch (e) {
      _errorMessage = 'Failed to create site visit: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSiteVisit(SiteVisitModel updatedVisit) async {
    if (_authToken == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await SiteVisitApiService.updateSiteVisit(
        updatedVisit.id,
        updatedVisit.toJson(),
        _authToken!,
      );

      if (result['success']) {
        final index = _siteVisits.indexWhere((v) => v.id == updatedVisit.id);
        if (index != -1) {
          _siteVisits[index] = result['siteVisit'];
        }
        await loadStats(); // Refresh stats
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update site visit: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSiteVisit(String id) async {
    if (_authToken == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await SiteVisitApiService.deleteSiteVisit(id, _authToken!);

      if (result['success']) {
        _siteVisits.removeWhere((v) => v.id == id);
        await loadStats(); // Refresh stats
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to delete site visit: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSiteVisitStatus(String id, String status) async {
    if (_authToken == null) return false;

    try {
      final result = await SiteVisitApiService.updateSiteVisitStatus(id, status, _authToken!);

      if (result['success']) {
        final index = _siteVisits.indexWhere((v) => v.id == id);
        if (index != -1) {
          _siteVisits[index] = result['siteVisit'];
        }
        await loadStats(); // Refresh stats
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update status: $e';
      return false;
    }
  }

  Future<bool> convertToQuotation(String id) async {
    return await updateSiteVisitStatus(id, 'converted');
  }

  Future<bool> markAsInvoiced(String id) async {
    return await updateSiteVisitStatus(id, 'invoiced');
  }

  Future<bool> markAsPaid(String id) async {
    return await updateSiteVisitStatus(id, 'paid');
  }

  // Legacy method for backward compatibility
  void addSiteVisitModel(SiteVisitModel visit) {
    _siteVisits.add(visit);
    notifyListeners();
  }

  // Refresh method to reload data
  Future<void> refreshSiteVisits() async {
    await loadSiteVisits();
  }
}
