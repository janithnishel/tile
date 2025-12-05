// lib/widgets/dashboard/projects/projects_dashboard_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/dashboard/dashboard_models.dart';
import 'package:tilework/widget/dashboard/charts/dashboard_donut_chart.dart';
import 'package:tilework/widget/dashboard/charts/dashboard_scatter_chart.dart';
import 'package:tilework/widget/dashboard/dashboard_actionable_list.dart';
import 'package:tilework/widget/dashboard/dashboard_kpi_card.dart';
import 'package:tilework/widget/dashboard/dashboard_section_header.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class ProjectsDashboardTab extends StatelessWidget {
  final DashboardPeriod selectedPeriod;
  final DateTimeRange? customDateRange;
  final VoidCallback? onNavigateToReports;

  const ProjectsDashboardTab({
    Key? key,
    required this.selectedPeriod,
    this.customDateRange,
    this.onNavigateToReports,
  }) : super(key: key);

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'en_LK',
      symbol: 'Rs. ',
      decimalDigits: 0,
    ).format(value);
  }

  // Mock Data
  List<ChartSegment> get _costBreakdownData => [
    ChartSegment(
      label: 'Labour',
      value: 450000,
      color: ReportTheme.primaryColor,
      percentage: 35.2,
    ),
    ChartSegment(
      label: 'Materials',
      value: 520000,
      color: ReportTheme.accentColor,
      percentage: 40.6,
    ),
    ChartSegment(
      label: 'Transport',
      value: 180000,
      color: ReportTheme.successColor,
      percentage: 14.1,
    ),
    ChartSegment(
      label: 'Other',
      value: 130000,
      color: ReportTheme.infoColor,
      percentage: 10.1,
    ),
  ];

  List<ChartSegment> get _projectStatusData => [
    ChartSegment(
      label: 'Active',
      value: 8,
      color: ReportTheme.successColor,
      percentage: 53.3,
    ),
    ChartSegment(
      label: 'Completed',
      value: 5,
      color: ReportTheme.primaryColor,
      percentage: 33.3,
    ),
    ChartSegment(
      label: 'On Hold',
      value: 2,
      color: ReportTheme.warningColor,
      percentage: 13.4,
    ),
  ];

  List<ScatterDataPoint> get _profitabilityScatterData => [
    ScatterDataPoint(label: 'Villa Renovation', xValue: 320000, yValue: 130000),
    ScatterDataPoint(label: 'Office Flooring', xValue: 180000, yValue: 100000),
    ScatterDataPoint(label: 'Hotel Lobby', xValue: 620000, yValue: 230000),
    ScatterDataPoint(label: 'Apartment Complex', xValue: 950000, yValue: 250000),
    ScatterDataPoint(label: 'Restaurant', xValue: 210000, yValue: -30000, color: ReportTheme.errorColor),
    ScatterDataPoint(label: 'Showroom', xValue: 150000, yValue: 45000),
    ScatterDataPoint(label: 'Retail Store', xValue: 280000, yValue: 85000),
  ];

  List<ActionableListItem> get _projectsNeedingReview => [
    ActionableListItem(
      id: 'PRJ-005',
      title: 'Restaurant Makeover',
      subtitle: 'Food Paradise - Loss project',
      value: '-14.3%',
      badge: 'LOSS',
      badgeColor: ReportTheme.errorColor,
      icon: Icons.warning_amber,
    ),
    ActionableListItem(
      id: 'PRJ-007',
      title: 'Small Office',
      subtitle: 'Tech Startup - Low margin',
      value: '5.2%',
      badge: 'LOW',
      badgeColor: ReportTheme.warningColor,
      icon: Icons.trending_flat,
    ),
    ActionableListItem(
      id: 'PRJ-004',
      title: 'Apartment Complex',
      subtitle: 'Sky Builders - Under review',
      value: '20.8%',
      badge: 'REVIEW',
      badgeColor: ReportTheme.infoColor,
      icon: Icons.visibility,
    ),
    ActionableListItem(
      id: 'PRJ-009',
      title: 'Warehouse Floor',
      subtitle: 'Logistics Co. - Cost overrun',
      value: '12.1%',
      badge: 'OVERRUN',
      badgeColor: ReportTheme.accentDark,
      icon: Icons.attach_money,
    ),
    ActionableListItem(
      id: 'PRJ-011',
      title: 'Clinic Interior',
      subtitle: 'City Hospital - Delayed',
      value: '18.5%',
      badge: 'DELAYED',
      badgeColor: ReportTheme.warningColor,
      icon: Icons.access_time,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          _buildKPICards(context),
          const SizedBox(height: 24),

          // Charts Section
          DashboardSectionHeader(
            title: 'Cost & Status Analysis',
            icon: Icons.pie_chart,
            actionText: 'View Reports',
            onActionTap: onNavigateToReports,
          ),
          const SizedBox(height: 16),

          // Two Donut Charts Row
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DashboardDonutChart(
                        title: 'Cost Breakdown',
                        segments: _costBreakdownData,
                        centerText: _formatCurrency(1280000),
                        centerSubtext: 'Total Cost',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DashboardDonutChart(
                        title: 'Project Status',
                        segments: _projectStatusData,
                        centerText: '15',
                        centerSubtext: 'Projects',
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  DashboardDonutChart(
                    title: 'Cost Breakdown',
                    segments: _costBreakdownData,
                    centerText: _formatCurrency(1280000),
                    centerSubtext: 'Total Cost',
                  ),
                  const SizedBox(height: 20),
                  DashboardDonutChart(
                    title: 'Project Status',
                    segments: _projectStatusData,
                    centerText: '15',
                    centerSubtext: 'Projects',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Scatter Plot
          DashboardScatterChart(
            title: 'Project Profitability Analysis',
            xAxisLabel: 'Direct Cost',
            yAxisLabel: 'Net Profit',
            data: _profitabilityScatterData,
            height: 250,
            onPointTap: (point) {
              debugPrint('Tapped: ${point.label}');
            },
          ),
          const SizedBox(height: 24),

          // Actionable List Section
          DashboardSectionHeader(
            title: 'Projects Needing Review',
            icon: Icons.warning_amber,
          ),
          const SizedBox(height: 16),
          DashboardActionableList(
            title: 'Low Margin & Problem Projects',
            titleIcon: Icons.trending_down,
            items: _projectsNeedingReview,
            onViewAllTap: onNavigateToReports,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildKPICards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 3 : 
                               constraints.maxWidth > 500 ? 2 : 1;
        final aspectRatio = constraints.maxWidth > 900 ? 1.5 : 
                            constraints.maxWidth > 500 ? 1.3 : 2.5;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: aspectRatio,
          children: [
            DashboardKPICard(
              title: 'Avg. Profit Margin',
              value: '24.8%',
              subtitle: 'Across 15 projects',
              icon: Icons.percent,
              color: ReportTheme.successColor,
              trendPercentage: 3.2,
              style: KPICardStyle.gradient,
            ),
            DashboardKPICard(
              title: 'Total Direct Cost',
              value: _formatCurrency(2750000),
              subtitle: 'All projects combined',
              icon: Icons.payments,
              color: ReportTheme.accentDark,
              trendPercentage: -2.1,
              style: KPICardStyle.gradient,
            ),
            DashboardKPICard(
              title: 'Negative Margin Projects',
              value: '2',
              subtitle: 'Requires attention',
              icon: Icons.warning_amber,
              color: ReportTheme.errorColor,
              style: KPICardStyle.gradient,
              onTap: () {
                // Navigate to problematic projects
              },
            ),
          ],
        );
      },
    );
  }
}