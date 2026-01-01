// lib/widgets/reports/project_report/project_report_tab.dart

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

// Mock data model for demonstration
class ProjectReportData {
  final String projectId;
  final String projectName;
  final String clientName;
  final String status;
  final double income;
  final double directCost;
  final DateTime completionDate;

  ProjectReportData({
    required this.projectId,
    required this.projectName,
    required this.clientName,
    required this.status,
    required this.income,
    required this.directCost,
    required this.completionDate,
  });

  double get netProfit => income - directCost;
  double get margin => income > 0 ? (netProfit / income) * 100 : 0;
}

class ProjectReportTab extends StatefulWidget {
  const ProjectReportTab({Key? key}) : super(key: key);

  @override
  State<ProjectReportTab> createState() => _ProjectReportTabState();
}

class _ProjectReportTabState extends State<ProjectReportTab> {
  // Filter States
  DateTimeRange? _dateRange;
  String? _selectedStatus;
  final TextEditingController _searchController = TextEditingController();

  // API Data
  List<ProjectReportData> _projects = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
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

      final response = await apiService.getProjectReport(
        token: authState.token,
        status: _selectedStatus,
        startDate: startDate,
        endDate: endDate,
      );

      final data = response['data'] as List;
      final projects = data.map((item) => ProjectReportData(
        projectId: item['projectId'] as String,
        projectName: item['projectName'] as String,
        clientName: item['clientName'] as String,
        status: item['status'] as String,
        income: (item['income'] as num).toDouble(),
        directCost: (item['directCost'] as num).toDouble(),
        completionDate: DateTime.parse(item['completionDate'] as String),
      )).toList();

      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load project data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Mock Data fallback - only used if API fails
  List<ProjectReportData> get _mockData => [];

  List<ProjectReportData> get _filteredData {
    if (_isLoading || _errorMessage != null) return [];

    var data = _projects;

    // Apply date filter
    if (_dateRange != null) {
      data = data.where((item) =>
        item.completionDate.isAfter(_dateRange!.start) &&
        item.completionDate.isBefore(_dateRange!.end.add(const Duration(days: 1)))
      ).toList();
    }

    // Apply status filter
    if (_selectedStatus != null && _selectedStatus != 'All') {
      data = data.where((item) => item.status == _selectedStatus).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      data = data.where((item) =>
        item.projectId.toLowerCase().contains(query) ||
        item.projectName.toLowerCase().contains(query) ||
        item.clientName.toLowerCase().contains(query)
      ).toList();
    }

    return data;
  }

  // Summary Calculations
  double get _totalIncome => _filteredData.fold(0, (sum, item) => sum + item.income);
  double get _totalCost => _filteredData.fold(0, (sum, item) => sum + item.directCost);
  double get _netProfit => _totalIncome - _totalCost;
  double get _avgMargin => _totalIncome > 0 ? (_netProfit / _totalIncome) * 100 : 0;

  final _currencyFormat = NumberFormat.currency(locale: 'en_LK', symbol: 'Rs. ', decimalDigits: 0);
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _dateRange = null;
      _selectedStatus = null;
      _searchController.clear();
    });
  }

  void _navigateToJobCostDetails(ProjectReportData project) {
    // Navigate to job cost detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Job Cost for ${project.projectName}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadProjectData,
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
                'Failed to Load Project Data',
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
                onPressed: _loadProjectData,
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
        // Title Section
        _buildSectionTitle(
          'Project Profitability Analysis',
          Icons.trending_up,
        ),
        const SizedBox(height: 16),

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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ReportTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ReportTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: ReportTheme.headingMedium),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
        final childAspectRatio = constraints.maxWidth > 900 ? 1.5 : 1.3;
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            ReportSummaryCard(
              title: 'Total Project Income',
              value: _currencyFormat.format(_totalIncome),
              icon: Icons.account_balance_wallet,
              type: CardType.primary,
              showTrend: true,
              trendValue: 12.5,
            ),
            ReportSummaryCard(
              title: 'Total Direct Cost',
              value: _currencyFormat.format(_totalCost),
              icon: Icons.payments,
              type: CardType.warning,
              showTrend: true,
              trendValue: -5.2,
            ),
            ReportSummaryCard(
              title: 'Net Profit',
              value: _currencyFormat.format(_netProfit),
              icon: Icons.trending_up,
              type: _netProfit >= 0 ? CardType.success : CardType.error,
              subtitle: _netProfit >= 0 ? 'Profitable' : 'Loss',
            ),
            ReportSummaryCard(
              title: 'Avg. Profit Margin',
              value: '${_avgMargin.toStringAsFixed(1)}%',
              icon: Icons.pie_chart,
              type: _avgMargin >= 20 ? CardType.success : 
                    _avgMargin >= 10 ? CardType.warning : CardType.error,
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
          label: 'Completion Date',
        ),
        ReportDropdownFilter<String>(
          label: 'Project Status',
          value: _selectedStatus,
          hint: 'All Status',
          items: ['All', 'Active', 'Completed', 'On Hold']
              .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedStatus = value),
        ),
        ReportSearchField(
          controller: _searchController,
          hintText: 'Search by Project ID or Name...',
          onChanged: (value) => setState(() {}),
          onClear: () => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return ReportDataTable<ProjectReportData>(
      data: _filteredData,
      rowsPerPage: 10,
      emptyMessage: 'No projects found matching your filters',
      header: Text(
        'Project Details (${_filteredData.length} projects)',
        style: ReportTheme.headingSmall,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {},
          tooltip: 'Export Table',
          color: ReportTheme.primaryColor,
        ),
      ],
      onRowTap: _navigateToJobCostDetails,
      columns: [
        ReportDataColumn<ProjectReportData>(
          label: 'Project ID/Name',
          sortable: true,
          compareFunction: (a, b) => a.projectId.compareTo(b.projectId),
          cellBuilder: (item) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.projectId,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ReportTheme.primaryColor,
                ),
              ),
              Text(
                item.projectName,
                style: ReportTheme.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        ReportDataColumn<ProjectReportData>(
          label: 'Client',
          cellBuilder: (item) => Text(item.clientName),
        ),
        ReportDataColumn<ProjectReportData>(
          label: 'Status',
          sortable: true,
          compareFunction: (a, b) => a.status.compareTo(b.status),
          cellBuilder: (item) => _buildStatusBadge(item.status),
        ),
        ReportDataColumn<ProjectReportData>(
          label: 'Income (Rs.)',
          numeric: true,
          sortable: true,
          compareFunction: (a, b) => a.income.compareTo(b.income),
          cellBuilder: (item) => Text(
            _currencyFormat.format(item.income),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ReportDataColumn<ProjectReportData>(
          label: 'Direct Cost (Rs.)',
          numeric: true,
          sortable: true,
          compareFunction: (a, b) => a.directCost.compareTo(b.directCost),
          cellBuilder: (item) => Text(
            _currencyFormat.format(item.directCost),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ReportDataColumn<ProjectReportData>(
          label: 'Net Profit (Rs.)',
          numeric: true,
          sortable: true,
          compareFunction: (a, b) => a.netProfit.compareTo(b.netProfit),
          cellBuilder: (item) => Text(
            _currencyFormat.format(item.netProfit),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: item.netProfit >= 0 
                  ? ReportTheme.successColor 
                  : ReportTheme.errorColor,
            ),
          ),
        ),
        ReportDataColumn<ProjectReportData>(
          label: 'Margin (%)',
          numeric: true,
          sortable: true,
          compareFunction: (a, b) => a.margin.compareTo(b.margin),
          cellBuilder: (item) => _buildMarginIndicator(item.margin),
        ),
        ReportDataColumn<ProjectReportData>(
          label: 'Actions',
          cellBuilder: (item) => ReportTableActionButton(
            icon: Icons.visibility,
            tooltip: 'View Job Cost Details',
            onPressed: () => _navigateToJobCostDetails(item),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'Active':
        return ReportStatusBadge.active();
      case 'Completed':
        return ReportStatusBadge.completed();
      case 'On Hold':
        return ReportStatusBadge.onHold();
      default:
        return ReportStatusBadge(label: status, color: Colors.grey);
    }
  }

  Widget _buildMarginIndicator(double margin) {
    final color = margin >= 20 
        ? ReportTheme.successColor 
        : margin >= 10 
            ? ReportTheme.warningColor 
            : ReportTheme.errorColor;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (margin.clamp(0, 100) / 100),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${margin.toStringAsFixed(1)}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
