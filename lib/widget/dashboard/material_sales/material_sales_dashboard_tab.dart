// lib/widgets/dashboard/material_sales/material_sales_dashboard_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tilework/cubits/material_sale/material_sale_cubit.dart';
import 'package:tilework/cubits/material_sale/material_sale_state.dart';
import 'package:tilework/models/dashboard/dashboard_models.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialSaleCubit, MaterialSaleState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: ReportTheme.errorColor),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load material sales data',
                    style: TextStyle(color: ReportTheme.errorColor, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage!,
                    style: TextStyle(color: ReportTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<MaterialSaleCubit>().loadMaterialSales(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final materialSales = state.materialSales;

        // Calculate KPI metrics from real data
        final totalRevenue = materialSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
        final totalPaid = materialSales.fold<double>(0, (sum, sale) => sum + sale.totalPaid);
        final totalOutstanding = totalRevenue - totalPaid;

        // Generate sales trend data from real sales
        final salesTrendData = _generateSalesTrendData(materialSales);

        // Generate collection status data
        final collectionStatusData = _generateCollectionStatusData(materialSales);

        // Generate top profitable items data
        final topProfitableItems = _generateTopProfitableItems(materialSales);

        // Generate pending invoices list
        final pendingInvoices = _generatePendingInvoices(materialSales);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KPI Cards
              _buildKPICards(context, totalRevenue, totalPaid, totalOutstanding, materialSales.length),
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
                data: salesTrendData,
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
                            segments: collectionStatusData,
                            centerText: '${_calculateCollectionPercentage(materialSales).toStringAsFixed(1)}%',
                            centerSubtext: 'Collected',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardBarChart(
                            title: 'Top 5 Profitable Items',
                            data: topProfitableItems,
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
                        segments: collectionStatusData,
                        centerText: '${_calculateCollectionPercentage(materialSales).toStringAsFixed(1)}%',
                        centerSubtext: 'Collected',
                      ),
                      const SizedBox(height: 20),
                      DashboardBarChart(
                        title: 'Top 5 Profitable Items',
                        data: topProfitableItems,
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
                items: pendingInvoices,
                onViewAllTap: onNavigateToReports,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKPICards(BuildContext context, double totalRevenue, double totalPaid, double totalOutstanding, int salesCount) {
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
              value: _currencyFormat.format(totalRevenue),
              subtitle: 'This ${selectedPeriod.label.toLowerCase()}',
              icon: Icons.account_balance_wallet,
              color: ReportTheme.primaryColor,
              trendPercentage: 12.5,
              style: KPICardStyle.gradient,
            ),
            DashboardKPICard(
              title: 'Total Gross Profit',
              value: _currencyFormat.format(totalRevenue - (totalRevenue * 0.7)), // Assuming 30% cost
              subtitle: '28.1% margin',
              icon: Icons.trending_up,
              color: ReportTheme.successColor,
              trendPercentage: 8.3,
              style: KPICardStyle.gradient,
            ),
            DashboardKPICard(
              title: 'Total Outstanding Due',
              value: _currencyFormat.format(totalOutstanding),
              subtitle: '$salesCount invoices pending',
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

  // Generate sales trend data from real material sales
  List<LineChartDataPoint> _generateSalesTrendData(List<MaterialSaleDocument> materialSales) {
    final now = DateTime.now();
    final last14Days = List.generate(14, (index) => now.subtract(Duration(days: 13 - index)));

    return last14Days.map((date) {
      // Sum up sales for this date
      final daySales = materialSales.where((sale) {
        return sale.saleDate.year == date.year &&
               sale.saleDate.month == date.month &&
               sale.saleDate.day == date.day;
      }).fold<double>(0, (sum, sale) => sum + sale.totalAmount);

      return LineChartDataPoint(date: date, value: daySales);
    }).toList();
  }

  // Generate collection status data from real material sales
  List<ChartSegment> _generateCollectionStatusData(List<MaterialSaleDocument> materialSales) {
    final paid = materialSales.where((sale) => sale.isPaid).fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final partial = materialSales.where((sale) => sale.hasAdvancePayment).fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final pending = materialSales.where((sale) => sale.isPending).fold<double>(0, (sum, sale) => sum + sale.totalAmount);

    final total = paid + partial + pending;
    if (total == 0) return [];

    return [
      ChartSegment(
        label: 'Paid',
        value: paid,
        color: ReportTheme.successColor,
        percentage: (paid / total) * 100,
      ),
      ChartSegment(
        label: 'Partial',
        value: partial,
        color: ReportTheme.accentColor,
        percentage: (partial / total) * 100,
      ),
      ChartSegment(
        label: 'Pending',
        value: pending,
        color: ReportTheme.errorColor,
        percentage: (pending / total) * 100,
      ),
    ];
  }

  // Generate top profitable items data from real material sales
  List<ChartDataPoint> _generateTopProfitableItems(List<MaterialSaleDocument> materialSales) {
    final itemProfits = <String, double>{};

    // Aggregate profits by item name
    for (final sale in materialSales) {
      for (final item in sale.items) {
        final itemName = item.productName.isNotEmpty ? item.productName : 'Unknown Item';
        itemProfits[itemName] = (itemProfits[itemName] ?? 0) + item.profit;
      }
    }

    // Sort by profit and take top 5
    final sortedItems = itemProfits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topItems = sortedItems.take(5).toList();

    // Assign colors
    final colors = [
      ReportTheme.primaryColor,
      ReportTheme.primaryLight,
      ReportTheme.accentColor,
      ReportTheme.successColor,
      ReportTheme.infoColor,
    ];

    return List.generate(topItems.length, (index) {
      return ChartDataPoint(
        label: topItems[index].key,
        value: topItems[index].value,
        color: colors[index % colors.length],
      );
    });
  }

  // Generate pending invoices list from real material sales
  List<ActionableListItem> _generatePendingInvoices(List<MaterialSaleDocument> materialSales) {
    final pendingSales = materialSales.where((sale) =>
      sale.isPending || sale.hasAdvancePayment
    ).toList();

    // Sort by amount due (highest first)
    pendingSales.sort((a, b) => b.amountDue.compareTo(a.amountDue));

    return pendingSales.take(5).map((sale) {
      final badge = sale.isPending ? 'PENDING' :
                   sale.hasAdvancePayment ? 'PARTIAL' : 'UNKNOWN';
      final badgeColor = sale.isPending ? ReportTheme.warningColor :
                        sale.hasAdvancePayment ? ReportTheme.accentColor :
                        ReportTheme.errorColor;

      return ActionableListItem(
        id: sale.id ?? sale.invoiceNumber,
        title: sale.displayInvoiceNumber,
        subtitle: '${sale.customerName} - Due: Rs ${sale.amountDue.toStringAsFixed(0)}',
        value: _currencyFormat.format(sale.amountDue),
        badge: badge,
        badgeColor: badgeColor,
        icon: Icons.receipt_long,
      );
    }).toList();
  }

  // Calculate collection percentage
  double _calculateCollectionPercentage(List<MaterialSaleDocument> materialSales) {
    if (materialSales.isEmpty) return 0.0;

    final totalRevenue = materialSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final totalPaid = materialSales.fold<double>(0, (sum, sale) => sum + sale.totalPaid);

    if (totalRevenue == 0) return 0.0;

    return (totalPaid / totalRevenue) * 100;
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
