// lib/widgets/reports/material_sales_report/invoice_summary_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/widget/reports/report_data_table.dart';
import 'package:tilework/widget/reports/report_date_range_picker.dart';
import 'package:tilework/widget/reports/report_dropdown_filter.dart';
import 'package:tilework/widget/reports/report_filter_chip.dart';
import 'package:tilework/widget/reports/report_search_field.dart';
import 'package:tilework/widget/reports/report_summary_card.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class InvoiceData {
  final String invoiceNo;
  final DateTime date;
  final String customerName;
  final String customerPhone;
  final double totalAmount;
  final double paidAmount;
  final String status;

  InvoiceData({
    required this.invoiceNo,
    required this.date,
    required this.customerName,
    required this.customerPhone,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
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

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_LK',
    symbol: 'Rs. ',
    decimalDigits: 0,
  );

  // Mock Data
  List<InvoiceData> get _mockData => [
    InvoiceData(
      invoiceNo: 'INV-1001',
      date: DateTime.now().subtract(const Duration(days: 2)),
      customerName: 'Kamal Perera',
      customerPhone: '0771234567',
      totalAmount: 125000,
      paidAmount: 125000,
      status: 'Paid',
    ),
    InvoiceData(
      invoiceNo: 'INV-1002',
      date: DateTime.now().subtract(const Duration(days: 5)),
      customerName: 'Nimal Fernando',
      customerPhone: '0779876543',
      totalAmount: 85000,
      paidAmount: 50000,
      status: 'Partial',
    ),
    InvoiceData(
      invoiceNo: 'INV-1003',
      date: DateTime.now().subtract(const Duration(days: 10)),
      customerName: 'Sunil Silva',
      customerPhone: '0712345678',
      totalAmount: 210000,
      paidAmount: 0,
      status: 'Pending',
    ),
    InvoiceData(
      invoiceNo: 'INV-1004',
      date: DateTime.now().subtract(const Duration(days: 15)),
      customerName: 'Ranjith Kumar',
      customerPhone: '0765432198',
      totalAmount: 45000,
      paidAmount: 45000,
      status: 'Paid',
    ),
    InvoiceData(
      invoiceNo: 'INV-1005',
      date: DateTime.now().subtract(const Duration(days: 20)),
      customerName: 'Mahesh Jayasinghe',
      customerPhone: '0723456789',
      totalAmount: 180000,
      paidAmount: 80000,
      status: 'Partial',
    ),
  ];

  List<InvoiceData> get _filteredData {
    var data = _mockData;

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

  void _viewInvoiceDetails(InvoiceData invoice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Invoice ${invoice.invoiceNo}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
    return ReportDataTable<InvoiceData>(
      data: _filteredData,
      rowsPerPage: 10,
      emptyMessage: 'No invoices found',
      header: Text(
        'Invoice List (${_filteredData.length} records)',
        style: ReportTheme.headingSmall,
      ),
      onRowTap: _viewInvoiceDetails,
      columns: [
        ReportDataColumn<InvoiceData>(
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
        ReportDataColumn<InvoiceData>(
          label: 'Date',
          sortable: true,
          compareFunction: (a, b) => a.date.compareTo(b.date),
          cellBuilder: (item) => Text(
            DateFormat('dd/MM/yyyy').format(item.date),
          ),
        ),
        ReportDataColumn<InvoiceData>(
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
        ReportDataColumn<InvoiceData>(
          label: 'Total (Rs.)',
          numeric: true,
          sortable: true,
          compareFunction: (a, b) => a.totalAmount.compareTo(b.totalAmount),
          cellBuilder: (item) => Text(
            _currencyFormat.format(item.totalAmount),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ReportDataColumn<InvoiceData>(
          label: 'Paid (Rs.)',
          numeric: true,
          sortable: true,
          compareFunction: (a, b) => a.paidAmount.compareTo(b.paidAmount),
          cellBuilder: (item) => Text(
            _currencyFormat.format(item.paidAmount),
            style: TextStyle(color: ReportTheme.successColor),
          ),
        ),
        ReportDataColumn<InvoiceData>(
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
        ReportDataColumn<InvoiceData>(
          label: 'Status',
          sortable: true,
          compareFunction: (a, b) => a.status.compareTo(b.status),
          cellBuilder: (item) => _buildStatusBadge(item.status),
        ),
        ReportDataColumn<InvoiceData>(
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
