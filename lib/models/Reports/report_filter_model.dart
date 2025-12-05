// lib/models/reports/report_filter_model.dart

import 'package:flutter/material.dart';

/// Base filter model for all reports
class ReportFilterModel {
  final DateTimeRange? dateRange;
  final String? searchQuery;
  final String? status;
  final String? groupBy;
  final Map<String, dynamic>? additionalFilters;

  const ReportFilterModel({
    this.dateRange,
    this.searchQuery,
    this.status,
    this.groupBy,
    this.additionalFilters,
  });

  ReportFilterModel copyWith({
    DateTimeRange? dateRange,
    String? searchQuery,
    String? status,
    String? groupBy,
    Map<String, dynamic>? additionalFilters,
    bool clearDateRange = false,
    bool clearSearchQuery = false,
    bool clearStatus = false,
  }) {
    return ReportFilterModel(
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      status: clearStatus ? null : (status ?? this.status),
      groupBy: groupBy ?? this.groupBy,
      additionalFilters: additionalFilters ?? this.additionalFilters,
    );
  }

  bool get hasActiveFilters =>
      dateRange != null ||
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      (status != null && status != 'All');

  ReportFilterModel clear() {
    return const ReportFilterModel();
  }

  @override
  String toString() {
    return 'ReportFilterModel(dateRange: $dateRange, searchQuery: $searchQuery, status: $status, groupBy: $groupBy)';
  }
}

/// Project-specific filter model
class ProjectReportFilter extends ReportFilterModel {
  final String? projectStatus;
  final String? clientName;

  const ProjectReportFilter({
    super.dateRange,
    super.searchQuery,
    this.projectStatus,
    this.clientName,
  });

  @override
  ProjectReportFilter copyWith({
    DateTimeRange? dateRange,
    String? searchQuery,
    String? status,
    String? groupBy,
    Map<String, dynamic>? additionalFilters,
    bool clearDateRange = false,
    bool clearSearchQuery = false,
    bool clearStatus = false,
    String? projectStatus,
    String? clientName,
  }) {
    return ProjectReportFilter(
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      projectStatus: clearStatus ? null : (projectStatus ?? this.projectStatus),
      clientName: clientName ?? this.clientName,
    );
  }
}

/// Invoice-specific filter model
class InvoiceReportFilter extends ReportFilterModel {
  final String? paymentStatus;
  final String? customerName;

  const InvoiceReportFilter({
    super.dateRange,
    super.searchQuery,
    this.paymentStatus,
    this.customerName,
  });

  @override
  InvoiceReportFilter copyWith({
    DateTimeRange? dateRange,
    String? searchQuery,
    String? status,
    String? groupBy,
    Map<String, dynamic>? additionalFilters,
    bool clearDateRange = false,
    bool clearSearchQuery = false,
    bool clearStatus = false,
    String? paymentStatus,
    String? customerName,
  }) {
    return InvoiceReportFilter(
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      paymentStatus: clearStatus ? null : (paymentStatus ?? this.paymentStatus),
      customerName: customerName ?? this.customerName,
    );
  }
}

/// Item profitability filter model
class ItemProfitFilter extends ReportFilterModel {
  final String groupByField;

  const ItemProfitFilter({
    super.dateRange,
    this.groupByField = 'Category',
  });

  @override
  ItemProfitFilter copyWith({
    DateTimeRange? dateRange,
    String? searchQuery,
    String? status,
    String? groupBy,
    Map<String, dynamic>? additionalFilters,
    bool clearDateRange = false,
    bool clearSearchQuery = false,
    bool clearStatus = false,
    String? groupByField,
  }) {
    return ItemProfitFilter(
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      groupByField: groupByField ?? this.groupByField,
    );
  }
}