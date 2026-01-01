// lib/widgets/reports/material_sales_report/invoice_summary_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/services/reports/report_api_service.dart';
import 'package:tilework/widget/reports/report_data_table.dart';
import 'package:tilework/widget/reports/report_date_range_picker.dart';
import 'package:tilework/widget/reports/report_dropdown_filter.dart';
import 'package:tilework/widget/reports/report_filter_chip.dart';
import 'package:tilework/widget/reports/report_search_field.dart';
import 'package:tilework/widget/reports/report_summary_card.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class MaterialSaleData {
  final String invoiceNo;
  final DateTime date;
  final String customerName;
  final String customerPhone;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final double totalSqft;
  final double totalPlanks;
  final double profitPercentage;

  MaterialSaleData({
    required this.invoiceNo,
    required this.date,
    required this.customerName,
    required this.customerPhone,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    this.totalSqft = 0,
    this.totalPlanks = 0,
    this.profitPercentage = 0,
  });

  double get dueAmount => totalAmount - paidAmount;
}

class InvoiceSummaryTab extends StatefulWidget {
  const InvoiceSummaryTab({Key? key}) : super(key: key);

  @override
  State<InvoiceSummaryTab> createState() => _InvoiceSummaryTabState();
}

class _InvoiceSummaryTabState extends State<InvoiceSummaryTab> {
  DateTimeRange? _dateRange;
  String? _selectedStatus;
  final TextEditingController _searchController = TextEditingController();

  // API Data
  List<MaterialSaleData> _materialSales = [];
  bool _isLoading = true;
  String? _errorMessage;

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_LK',
    symbol: 'Rs. ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadMaterialSalesData();
  }

  Future<void> _loadMaterialSalesData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) {
        throw Exception('User not authenticated');
      }

      final apiService = ReportApiService();
      final startDate = _dateRange?.start.toIso8601String().split('T')[0];
      final endDate = _dateRange?.end.toIso8601String().split('T')[0];

      final response = await apiService.getMaterialSalesReport(
        token: authState.token,
        status: _selectedStatus,
        startDate: startDate,
        endDate: endDate,
      );

      final data = response['data'] as List;
      final materialSales = data.map((item) => MaterialSaleData(
        invoiceNo: item['invoiceNo'] as String,
        date: DateTime.parse(item['date'] as String),
        customerName: item['customerName'] as String,
        customerPhone: item['customerPhone'] as String,
        totalAmount: (item['totalAmount'] as num).toDouble(),
        paidAmount: (item['paidAmount'] as num).toDouble(),
        status: item['status'] as String,
        totalSqft: (item['totalSqft'] as num?)?.toDouble() ?? 0,
        totalPlanks: (item['totalPlanks'] as num?)?.toDouble() ?? 0,
        profitPercentage: (item['profitPercentage'] as num?)?.toDouble() ?? 0,
      )).toList();

      setState(() {
        _materialSales = materialSales;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load material sales data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Mock Data fallback - only used if API fails
  List<MaterialSaleData> get _mockData => [];

  List<MaterialSaleData> get _filteredData {
    if (_isLoading || _errorMessage != null) return [];

    var data = _materialSales;

    if (_dateRange != null) {
      data = data.where((item) =>
          item.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
          item.date.isBefore(_dateRange!.end.add(const Duration(days: 1)))).toList();
    }

    if (_selectedStatus != null && _selectedStatus != 'All') {
      data = data.where((item) => item.status == _selectedStatus).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      data = data.where((item) =>
          item.customerName.toLowerCase().contains(query) ||
          item.customerPhone.contains(query) ||
          item.invoiceNo.toLowerCase().contains(query)).toList();
    }

    return data;
  }

  double get _totalSales => _filteredData.fold(0, (sum, item) => sum + item.totalAmount);
  double get _totalPaid => _filteredData.fold(0, (sum, item) => sum + item.paidAmount);
  double get _totalDue => _totalSales - _totalPaid;

  void _clearFilters() {
    setState(() {
      _dateRange = null;
      _selectedStatus = null;
      _searchController.clear();
    });
  }

  void _viewInvoiceDetails(MaterialSaleData materialSale) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Material Sale ${materialSale.invoiceNo}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadMaterialSalesData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: ReportTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to Load Material Sales Data',
                style: ReportTheme.headingMedium.copyWith(
                  color: ReportTheme.errorColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: ReportTheme.caption,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadMaterialSalesData,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ReportTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
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
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 3 : 1;
        final aspectRatio = constraints.maxWidth > 700 ? 1.8 : 2.8;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: aspectRatio,
          children: [
            ReportSummaryCard(
              title: 'Total Sales Amount',
              value: _currencyFormat.format(_totalSales),
              icon: Icons.point_of_sale,
              type: CardType.primary,
            ),
            ReportSummaryCard(
              title: 'Total Paid Amount',
              value: _currencyFormat.format(_totalPaid),
              icon: Icons.check_circle,
              type: CardType.success,
            ),
            ReportSummaryCard(
              title: 'Total Due Amount',
              value: _currencyFormat.format(_totalDue),
              icon: Icons.pending_actions,
              type: _totalDue > 0 ? CardType.error : CardType.success,
              subtitle: '${_filteredData.where((i) => i.dueAmount > 0).length} invoices pending',
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    return ReportFilterBar(
      onClearFilters: _clearFilters,
      filters: [
        ReportDateRangePicker(
          dateRange: _dateRange,
          onDateRangeChanged: (range) => setState(() => _dateRange = range),
          label: 'Invoice Date',
        ),
        ReportDropdownFilter<String>(
          label: 'Payment Status',
          value: _selectedStatus,
          hint: 'All Status',
          items: ['All', 'Paid', 'Partial', 'Pending']
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (value) => setState(() => _selectedStatus = value),
        ),
        ReportSearchField(
          controller: _searchController,
          hintText: 'Search customer name or phone...',
          onChanged: (value) => setState(() {}),
          onClear: () => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return ReportDataTable<MaterialSaleData>(
      data: _filteredData,
      rowsPerPage: 10,
      emptyMessage: 'No material sales found',
      header: Text(
        'Material Sales List (${_filteredData.length} records)',
        style: ReportTheme.headingSmall,
      ),
      onRowTap: _viewInvoiceDetails,
      columns: [
        ReportDataColumn<MaterialSaleData>(
          label: 'Invoice No.',
          sortable: true,
          compareFunction: (a, b) => a.invoiceNo.compareTo(b.invoiceNo),
          cellBuilder: (item) => Text(
            item.invoiceNo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ReportTheme.primaryColor,
            ),
          ),
        ),
        ReportDataColumn<MaterialSaleData>(
          label: 'Date',
          sortable: true,
          compareFunction: (a, b) => a.date.compareTo(b.date),
          cellBuilder: (item) => Text(
            DateFormat('dd/MM/yyyy').format(item.date),
          ),
        ),
        ReportDataColumn<MaterialSaleData>(
          label: 'Customer',
          cellBuilder: (item) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.customerName, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(item.customerPhone, style: ReportTheme.caption),
            ],
          ),
        ),
        ReportDataColumn<MaterialSaleData>(
          label: 'Total (Rs.)',
          numeric: true,
          sortable: true,
          compareFunction: (a, b) => a.totalAmount.compareTo(b.totalAmount),
          cellBuilder: (item) => Text(
            _currencyFormat.format(item.totalAmount),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ReportDataColumn<MaterialSaleData>(
          label: 'Paid (Rs.)',
          numeric: true,
          sortable: true,
          compareFunction: (a, b) => a.paidAmount.compareTo(b.paidAmount),
          cellBuilder: (item) => Text(
            _currencyFormat.format(item.paidAmount),
            style: TextStyle(color: ReportTheme.successColor),
          ),
        ),
        ReportDataColumn<MaterialSaleData>(
          label: 'Due (Rs.)',
          numeric: true,
          sortable: true,
          compareFunction: (a, b) => a.dueAmount.compareTo(b.dueAmount),
          cellBuilder: (item) => Text(
            _currencyFormat.format(item.dueAmount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: item.dueAmount > 0 ? ReportTheme.errorColor : ReportTheme.successColor,
            ),
          ),
        ),
        ReportDataColumn<MaterialSaleData>(
          label: 'Status',
          sortable: true,
          compareFunction: (a, b) => a.status.compareTo(b.status),
          cellBuilder: (item) => _buildStatusBadge(item.status),
        ),
        ReportDataColumn<MaterialSaleData>(
          label: 'Actions',
          cellBuilder: (item) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReportTableActionButton(
                icon: Icons.visibility,
                tooltip: 'View Details',
                onPressed: () => _viewInvoiceDetails(item),
              ),
              const SizedBox(width: 8),
              ReportTableActionButton(
                icon: Icons.print,
                tooltip: 'Print Invoice',
                onPressed: () {},
                color: ReportTheme.infoColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'Paid':
        return ReportStatusBadge.paid();
      case 'Partial':
        return ReportStatusBadge.partial();
      case 'Pending':
        return ReportStatusBadge.pending();
      default:
        return ReportStatusBadge(label: status, color: Colors.grey);
    }
  }
}
