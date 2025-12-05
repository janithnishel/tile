// lib/widgets/reports/material_sales_report/item_wise_profitability_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/widget/reports/report_data_table.dart';
import 'package:tilework/widget/reports/report_date_range_picker.dart';
import 'package:tilework/widget/reports/report_dropdown_filter.dart';
import 'package:tilework/widget/reports/report_filter_chip.dart';
import 'package:tilework/widget/reports/report_summary_card.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class ItemProfitData {
  final String groupName;
  final double sqftSold;
  final double totalRevenue;
  final double totalCost;

  ItemProfitData({
    required this.groupName,
    required this.sqftSold,
    required this.totalRevenue,
    required this.totalCost,
  });

  double get grossProfit => totalRevenue - totalCost;
  double get profitMargin => totalRevenue > 0 ? (grossProfit / totalRevenue) * 100 : 0;
}

class ItemWiseProfitabilityTab extends StatefulWidget {
  const ItemWiseProfitabilityTab({Key? key}) : super(key: key);

  @override
  State<ItemWiseProfitabilityTab> createState() => _ItemWiseProfitabilityTabState();
}

class _ItemWiseProfitabilityTabState extends State<ItemWiseProfitabilityTab> {
  String _groupBy = 'Category';
  DateTimeRange? _dateRange;

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_LK',
    symbol: 'Rs. ',
    decimalDigits: 0,
  );

  // Mock data based on category grouping
  List<ItemProfitData> get _categoryData => [
    ItemProfitData(groupName: 'Floor Tiles', sqftSold: 2500, totalRevenue: 625000, totalCost: 437500),
    ItemProfitData(groupName: 'Wall Tiles', sqftSold: 1800, totalRevenue: 378000, totalCost: 264600),
    ItemProfitData(groupName: 'Bathroom Tiles', sqftSold: 950, totalRevenue: 285000, totalCost: 199500),
    ItemProfitData(groupName: 'Outdoor Tiles', sqftSold: 1200, totalRevenue: 420000, totalCost: 315000),
    ItemProfitData(groupName: 'Mosaic Tiles', sqftSold: 350, totalRevenue: 175000, totalCost: 105000),
  ];

  // Mock data based on color code grouping  
  List<ItemProfitData> get _colorCodeData => [
    ItemProfitData(groupName: 'White Marble (WM-001)', sqftSold: 1500, totalRevenue: 450000, totalCost: 315000),
    ItemProfitData(groupName: 'Grey Stone (GS-002)', sqftSold: 1200, totalRevenue: 336000, totalCost: 235200),
    ItemProfitData(groupName: 'Beige Classic (BC-003)', sqftSold: 900, totalRevenue: 225000, totalCost: 157500),
    ItemProfitData(groupName: 'Black Granite (BG-004)', sqftSold: 600, totalRevenue: 210000, totalCost: 147000),
    ItemProfitData(groupName: 'Brown Wood (BW-005)', sqftSold: 800, totalRevenue: 200000, totalCost: 140000),
    ItemProfitData(groupName: 'Blue Ocean (BO-006)', sqftSold: 400, totalRevenue: 160000, totalCost: 120000),
  ];

  List<ItemProfitData> get _data => _groupBy == 'Category' ? _categoryData : _colorCodeData;

  double get _totalRevenue => _data.fold(0, (sum, item) => sum + item.totalRevenue);
  double get _totalCost => _data.fold(0, (sum, item) => sum + item.totalCost);
  double get _grossProfit => _totalRevenue - _totalCost;
  double get _overallMargin => _totalRevenue > 0 ? (_grossProfit / _totalRevenue) * 100 : 0;

  void _clearFilters() {
    setState(() {
      _groupBy = 'Category';
      _dateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCards(),
          const SizedBox(height: 24),

          // Filters
          _buildFilters(),
          const SizedBox(height: 24),

          // Data Table
          _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
        final aspectRatio = constraints.maxWidth > 900 ? 1.6 : 1.4;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: aspectRatio,
          children: [
            ReportSummaryCard(
              title: 'Total Revenue (Gross)',
              value: _currencyFormat.format(_totalRevenue),
              icon: Icons.attach_money,
              type: CardType.primary,
            ),
            ReportSummaryCard(
              title: 'Total Cost (COGS)',
              value: _currencyFormat.format(_totalCost),
              icon: Icons.shopping_cart,
              type: CardType.warning,
            ),
            ReportSummaryCard(
              title: 'Gross Profit',
              value: _currencyFormat.format(_grossProfit),
              icon: Icons.trending_up,
              type: _grossProfit >= 0 ? CardType.success : CardType.error,
            ),
            ReportSummaryCard(
              title: 'Overall Profit Margin',
              value: '${_overallMargin.toStringAsFixed(1)}%',
              icon: Icons.pie_chart,
              type: _overallMargin >= 25 ? CardType.success : 
                    _overallMargin >= 15 ? CardType.warning : CardType.error,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: ReportTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: ReportTheme.headingSmall.copyWith(
                  color: ReportTheme.primaryColor,
                ),
              ),
              const Spacer(),
              if (_groupBy != 'Category' || _dateRange != null)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: ReportTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ReportDropdownFilter<String>(
                  label: 'Group By',
                  value: _groupBy,
                  items: ['Category', 'Color Code']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) => setState(() => _groupBy = value ?? 'Category'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ReportDateRangePicker(
                  dateRange: _dateRange,
                  onDateRangeChanged: (range) => setState(() => _dateRange = range),
                  label: 'Date Range (Optional)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return ReportDataTable<ItemProfitData>(
      data: _data,
      rowsPerPage: 10,
      emptyMessage: 'No data available',
      header: Row(
        children: [
          Text(
            'Item Analysis by $_groupBy',
            style: ReportTheme.headingSmall,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ReportTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_data.length} groups',
              style: TextStyle(
                fontSize: 12,
                color: ReportTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      columns: [
        ReportDataColumn<ItemProfitData>(
          label: 'Item Group ($_groupBy)',
          sortable: true,
          compareFunction: (a, b) => a.groupName.compareTo(b.groupName),
          cellBuilder: (item) => Row(
            children: [
              Container(
                width: 8,
                height: 40,
                decoration: BoxDecoration(
                  color: _getColorForItem(item.groupName),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.groupName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        ReportDataColumn<ItemProfitData>(
          label: 'Sqft Sold',
          numeric: true,
          sortable: true,
          compareFunction: (a, b) => a.sqftSold.compareTo(b.sqftSold),
          cellBuilder: (item) => Text(
            NumberFormat('#,##0').format(item.sqftSold),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ReportDataColumn<ItemProfitData>(
          label: 'Total Revenue (Rs.)',
          numeric: true,
          sortable: true,
          compareFunction: (a, b) => a.totalRevenue.compareTo(b.totalRevenue),
          cellBuilder: (item) => Text(
            _currencyFormat.format(item.totalRevenue),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ReportDataColumn<ItemProfitData>(
          label: 'Total Cost (Rs.)',
          numeric: true,
          cellBuilder: (item) => Text(
            _currencyFormat.format(item.totalCost),
            style: TextStyle(color: ReportTheme.textSecondary),
          ),
        ),
        ReportDataColumn<ItemProfitData>(
          label: 'Gross Profit (Rs.)',
          numeric: true,
          sortable: true,
          compareFunction: (a, b) => a.grossProfit.compareTo(b.grossProfit),
          cellBuilder: (item) => Text(
            _currencyFormat.format(item.grossProfit),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: item.grossProfit >= 0 
                  ? ReportTheme.successColor 
                  : ReportTheme.errorColor,
            ),
          ),
        ),
        ReportDataColumn<ItemProfitData>(
          label: 'Profit Margin (%)',
          numeric: true,
          sortable: true,
          compareFunction: (a, b) => a.profitMargin.compareTo(b.profitMargin),
          cellBuilder: (item) => _buildProfitMarginCell(item.profitMargin),
        ),
      ],
    );
  }

  Widget _buildProfitMarginCell(double margin) {
    final color = margin >= 30 
        ? ReportTheme.successColor 
        : margin >= 20 
            ? ReportTheme.warningColor 
            : ReportTheme.errorColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            margin >= 25 ? Icons.arrow_upward : 
            margin >= 15 ? Icons.remove : Icons.arrow_downward,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${margin.toStringAsFixed(1)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForItem(String name) {
    final colors = [
      ReportTheme.primaryColor,
      ReportTheme.successColor,
      ReportTheme.warningColor,
      ReportTheme.infoColor,
      ReportTheme.secondaryColor,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[name.hashCode % colors.length];
  }
}
