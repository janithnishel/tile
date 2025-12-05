// lib/models/reports/report_summary_model.dart

import 'package:flutter/material.dart';

/// Base summary model
class ReportSummaryModel {
  final String title;
  final double value;
  final String formattedValue;
  final IconData icon;
  final Color color;
  final double? trendPercentage;
  final String? subtitle;

  const ReportSummaryModel({
    required this.title,
    required this.value,
    required this.formattedValue,
    required this.icon,
    required this.color,
    this.trendPercentage,
    this.subtitle,
  });

  bool get hasTrend => trendPercentage != null;
  bool get isPositiveTrend => (trendPercentage ?? 0) >= 0;
}

/// Project report summary
class ProjectReportSummary {
  final double totalIncome;
  final double totalDirectCost;
  final double netProfit;
  final double avgProfitMargin;
  final int totalProjects;
  final int activeProjects;
  final int completedProjects;

  const ProjectReportSummary({
    required this.totalIncome,
    required this.totalDirectCost,
    required this.netProfit,
    required this.avgProfitMargin,
    required this.totalProjects,
    required this.activeProjects,
    required this.completedProjects,
  });

  factory ProjectReportSummary.empty() {
    return const ProjectReportSummary(
      totalIncome: 0,
      totalDirectCost: 0,
      netProfit: 0,
      avgProfitMargin: 0,
      totalProjects: 0,
      activeProjects: 0,
      completedProjects: 0,
    );
  }

  bool get isProfitable => netProfit >= 0;
  bool get hasGoodMargin => avgProfitMargin >= 20;
}

/// Invoice summary
class InvoiceSummary {
  final double totalSalesAmount;
  final double totalPaidAmount;
  final double totalDueAmount;
  final int totalInvoices;
  final int paidInvoices;
  final int pendingInvoices;
  final int partialInvoices;

  const InvoiceSummary({
    required this.totalSalesAmount,
    required this.totalPaidAmount,
    required this.totalDueAmount,
    required this.totalInvoices,
    required this.paidInvoices,
    required this.pendingInvoices,
    required this.partialInvoices,
  });

  factory InvoiceSummary.empty() {
    return const InvoiceSummary(
      totalSalesAmount: 0,
      totalPaidAmount: 0,
      totalDueAmount: 0,
      totalInvoices: 0,
      paidInvoices: 0,
      pendingInvoices: 0,
      partialInvoices: 0,
    );
  }

  double get collectionRate =>
      totalSalesAmount > 0 ? (totalPaidAmount / totalSalesAmount) * 100 : 0;
}

/// Item profitability summary
class ItemProfitSummary {
  final double totalRevenue;
  final double totalCost;
  final double grossProfit;
  final double overallProfitMargin;
  final double totalSqftSold;
  final int totalCategories;

  const ItemProfitSummary({
    required this.totalRevenue,
    required this.totalCost,
    required this.grossProfit,
    required this.overallProfitMargin,
    required this.totalSqftSold,
    required this.totalCategories,
  });

  factory ItemProfitSummary.empty() {
    return const ItemProfitSummary(
      totalRevenue: 0,
      totalCost: 0,
      grossProfit: 0,
      overallProfitMargin: 0,
      totalSqftSold: 0,
      totalCategories: 0,
    );
  }

  bool get isProfitable => grossProfit >= 0;
  bool get hasGoodMargin => overallProfitMargin >= 25;
}