// lib/models/dashboard/dashboard_models.dart

import 'package:flutter/material.dart';

/// Period Selection Enum
enum DashboardPeriod {
  today('Today', 1),
  last7Days('Last 7 Days', 7),
  last30Days('Last 30 Days', 30),
  thisMonth('This Month', 0),
  lastQuarter('Last Quarter', 90),
  ytd('Year to Date', 365),
  custom('Custom', -1);

  final String label;
  final int days;
  
  const DashboardPeriod(this.label, this.days);

  DateTimeRange get dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (this) {
      case DashboardPeriod.today:
        return DateTimeRange(start: today, end: today);
      case DashboardPeriod.last7Days:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        );
      case DashboardPeriod.last30Days:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
        );
      case DashboardPeriod.thisMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: today,
        );
      case DashboardPeriod.lastQuarter:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 89)),
          end: today,
        );
      case DashboardPeriod.ytd:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: today,
        );
      case DashboardPeriod.custom:
        return DateTimeRange(start: today, end: today);
    }
  }
}

/// KPI Card Data Model
class KPICardData {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final double? trendPercentage;
  final bool isLoading;
  final VoidCallback? onTap;

  const KPICardData({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.trendPercentage,
    this.isLoading = false,
    this.onTap,
  });
}

/// Chart Data Models
class ChartDataPoint {
  final String label;
  final double value;
  final Color? color;

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.color,
  });
}

class LineChartDataPoint {
  final DateTime date;
  final double value;

  const LineChartDataPoint({
    required this.date,
    required this.value,
  });
}

class ScatterDataPoint {
  final String label;
  final double xValue;
  final double yValue;
  final Color? color;

  const ScatterDataPoint({
    required this.label,
    required this.xValue,
    required this.yValue,
    this.color,
  });
}

/// Actionable List Item Model
class ActionableListItem {
  final String id;
  final String title;
  final String subtitle;
  final String value;
  final String? badge;
  final Color? badgeColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const ActionableListItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.value,
    this.badge,
    this.badgeColor,
    this.icon,
    this.onTap,
  });
}

/// Donut/Pie Chart Segment
class ChartSegment {
  final String label;
  final double value;
  final Color color;
  final double percentage;

  const ChartSegment({
    required this.label,
    required this.value,
    required this.color,
    required this.percentage,
  });
}