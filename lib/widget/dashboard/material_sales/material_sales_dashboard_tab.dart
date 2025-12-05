// lib/widgets/dashboard/material_sales/material_sales_dashboard_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/dashboard/dashboard_models.dart';
import 'package:tilework/widget/dashboard/charts/dashboard_donut_chart.dart';
import 'package:tilework/widget/dashboard/charts/dashboard_bar_chart.dart';
import 'package:tilework/widget/dashboard/charts/dashboard_line_chart.dart';
import 'package:tilework/widget/dashboard/dashboard_actionable_list.dart';
import 'package:tilework/widget/dashboard/dashboard_kpi_card.dart';
import 'package:tilework/widget/dashboard/dashboard_section_header.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class MaterialSalesDashboardTab extends StatelessWidget {
  final DashboardPeriod selectedPeriod;
  final DateTimeRange? customDateRange;
  final VoidCallback? onNavigateToReports;

  const MaterialSalesDashboardTab({
    Key? key,
    required this.selectedPeriod,
    this.customDateRange,
    this.onNavigateToReports,
  }) : super(key: key);

  final _currencyFormat = const _CurrencyFormatter();

  // Mock Data - Replace with actual data
  List<LineChartDataPoint> get _salesTrendData {
    final now = DateTime.now();
    return List.generate(14, (index) {
      return LineChartDataPoint(
        date: now.subtract(Duration(days: 13 - index)),
        value: 50000 + (index * 8000) + (index % 3 * 15000),
      );
    });
  }

  List<ChartSegment> get _collectionStatusData => [
    ChartSegment(
      label: 'Paid',
      value: 1250000,
      color: ReportTheme.successColor,
      percentage: 62.5,
    ),
    ChartSegment(
      label: 'Partial',
      value: 450000,
      color: ReportTheme.accentColor,
      percentage: 22.5,
    ),
    ChartSegment(
      label: 'Pending',
      value: 300000,
      color: ReportTheme.errorColor,
      percentage: 15.0,
    ),
  ];

  List<ChartDataPoint> get _topProfitableItems => [
    ChartDataPoint(label: 'Floor Tiles', value: 187500, color: ReportTheme.primaryColor),
    ChartDataPoint(label: 'Wall Tiles', value: 113400, color: ReportTheme.primaryLight),
    ChartDataPoint(label: 'Outdoor', value: 105000, color: ReportTheme.accentColor),
    ChartDataPoint(label: 'Bathroom', value: 85500, color: ReportTheme.successColor),
    ChartDataPoint(label: 'Mosaic', value: 70000, color: ReportTheme.infoColor),
  ];

  List<ActionableListItem> get _pendingInvoices => [
    ActionableListItem(
      id: 'INV-1003',
      title: 'INV-1003',
      subtitle: 'Sunil Silva - 15 days overdue',
      value: _currencyFormat.format(210000),
      badge: 'OVERDUE',
      badgeColor: ReportTheme.errorColor,
      icon: Icons.receipt_long,
    ),
    ActionableListItem(
      id: 'INV-1005',
      title: 'INV-1005',
      subtitle: 'Mahesh Jayasinghe - 8 days overdue',
      value: _currencyFormat.format(100000),
      badge: 'PARTIAL',
      badgeColor: ReportTheme.accentColor,
      icon: Icons.receipt_long,
    ),
    ActionableListItem(
      id: 'INV-1002',
      title: 'INV-1002',
      subtitle: 'Nimal Fernando - Due in 3 days',
      value: _currencyFormat.format(35000),
      badge: 'DUE SOON',
      badgeColor: ReportTheme.warningColor,
      icon: Icons.receipt_long,
    ),
    ActionableListItem(
      id: 'INV-1008',
      title: 'INV-1008',
      subtitle: 'Kasun Bandara - Due in 7 days',
      value: _currencyFormat.format(28000),
      icon: Icons.receipt_long,
    ),
    ActionableListItem(
      id: 'INV-1010',
      title: 'INV-1010',
      subtitle: 'Ruwan Perera - Due in 10 days',
      value: _currencyFormat.format(22000),
      icon: Icons.receipt_long,
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
            title: 'Performance Analytics',
            icon: Icons.analytics,
            actionText: 'View Reports',
            onActionTap: onNavigateToReports,
          ),
          const SizedBox(height: 16),

          // Sales Trend Chart
          DashboardLineChart(
            title: 'Sales Trend',
            data: _salesTrendData,
            lineColor: ReportTheme.primaryColor,
            gradientColor: ReportTheme.primaryColor,
            onPointTap: (point) {
              // Navigate to filtered report
              debugPrint('Tapped: ${point.date}');
            },
          ),
          const SizedBox(height: 20),

          // Two Charts Row
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DashboardDonutChart(
                        title: 'Collections Status',
                        segments: _collectionStatusData,
                        centerText: '62.5%',
                        centerSubtext: 'Collected',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DashboardBarChart(
                        title: 'Top 5 Profitable Items',
                        data: _topProfitableItems,
                        isHorizontal: true,
                        barColor: ReportTheme.primaryColor,
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  DashboardDonutChart(
                    title: 'Collections Status',
                    segments: _collectionStatusData,
                    centerText: '62.5%',
                    centerSubtext: 'Collected',
                  ),
                  const SizedBox(height: 20),
                  DashboardBarChart(
                    title: 'Top 5 Profitable Items',
                    data: _topProfitableItems,
                    isHorizontal: true,
                    barColor: ReportTheme.primaryColor,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Actionable List Section
          DashboardSectionHeader(
            title: 'Action Required',
            icon: Icons.priority_high,
          ),
          const SizedBox(height: 16),
          DashboardActionableList(
            title: 'Top Pending Invoices',
            titleIcon: Icons.receipt_long,
            items: _pendingInvoices,
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
              title: 'Total Revenue',
              value: _currencyFormat.format(2000000),
              subtitle: 'This ${selectedPeriod.label.toLowerCase()}',
              icon: Icons.account_balance_wallet,
              color: ReportTheme.primaryColor,
              trendPercentage: 12.5,
              style: KPICardStyle.gradient,
            ),
            DashboardKPICard(
              title: 'Total Gross Profit',
              value: _currencyFormat.format(561400),
              subtitle: '28.1% margin',
              icon: Icons.trending_up,
              color: ReportTheme.successColor,
              trendPercentage: 8.3,
              style: KPICardStyle.gradient,
            ),
            DashboardKPICard(
              title: 'Total Outstanding Due',
              value: _currencyFormat.format(750000),
              subtitle: '12 invoices pending',
              icon: Icons.pending_actions,
              color: ReportTheme.errorColor,
              trendPercentage: -5.2,
              style: KPICardStyle.gradient,
            ),
          ],
        );
      },
    );
  }
}

class _CurrencyFormatter {
  const _CurrencyFormatter();
  
  String format(double value) {
    final formatter = NumberFormat.currency(
      locale: 'en_LK',
      symbol: 'Rs. ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }
}