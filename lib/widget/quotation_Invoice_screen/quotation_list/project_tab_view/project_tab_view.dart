// lib/widget/quotation_Invoice_screen/quotation_list/project_tab_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/quotation/quotation_cubit.dart';
import 'package:tilework/cubits/quotation/quotation_state.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_list/project_tab_view/customer_expansion_tile.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_list/project_tab_view/search_filter_section.dart';

class ProjectTabView extends StatefulWidget {
  final Function(QuotationCubit) onCreateNew;
  final Function(QuotationDocument, QuotationCubit) onDocumentTap;

  const ProjectTabView({
    Key? key,
    required this.onCreateNew,
    required this.onDocumentTap,
  }) : super(key: key);

  @override
  State<ProjectTabView> createState() => _ProjectTabViewState();
}

class _ProjectTabViewState extends State<ProjectTabView> {
  // Search & Filter State
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _typeFilter = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================
  // FILTER METHODS
  // ============================================

  List<QuotationDocument> _getFilteredDocuments(List<QuotationDocument> documents) {
    return documents.where((doc) {
      final query = _searchQuery.toLowerCase();

      final matchesSearch = query.isEmpty ||
          doc.customerName.toLowerCase().contains(query) ||
          doc.documentNumber.toLowerCase().contains(query) ||
          doc.projectTitle.toLowerCase().contains(query) ||
          doc.customerPhone.toLowerCase().contains(query);

      final matchesStatus = _statusFilter == 'All' ||
          doc.status.name.toUpperCase() == _statusFilter.toUpperCase();

      final matchesType = _typeFilter == 'All' ||
          doc.type.name.toUpperCase() == _typeFilter.toUpperCase();

      final matchesDate = (_startDate == null ||
              doc.invoiceDate.isAfter(_startDate!.subtract(const Duration(days: 1)))) &&
          (_endDate == null ||
              doc.invoiceDate.isBefore(_endDate!.add(const Duration(days: 1))));

      return matchesSearch && matchesStatus && matchesType && matchesDate;
    }).toList();
  }

  Map<String, List<QuotationDocument>> _groupByCustomer(
    List<QuotationDocument> documents,
  ) {
    final Map<String, List<QuotationDocument>> grouped = {};

    for (var doc in documents) {
      // Group by customer name, or use "Unassigned" for documents without customer names
      final customerKey = doc.customerName.isNotEmpty ? doc.customerName : 'Unassigned Customer';
      grouped.putIfAbsent(customerKey, () => []).add(doc);
    }

    // Sort documents in each group by date (newest first)
    grouped.forEach((customer, docs) {
      docs.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
    });

    return grouped;
  }

  Map<String, dynamic> _getCustomerSummary(List<QuotationDocument> docs) {
    int quotations = 0;
    int invoices = 0;
    double totalAmount = 0;
    double totalDue = 0;

    for (var doc in docs) {
      if (doc.type == DocumentType.quotation) {
        quotations++;
      } else {
        invoices++;
      }
      totalAmount += doc.subtotal;
      if (doc.type == DocumentType.invoice &&
          doc.status != DocumentStatus.paid) {
        totalDue += doc.amountDue;
      }
    }

    return {
      'quotations': quotations,
      'invoices': invoices,
      'totalAmount': totalAmount,
      'totalDue': totalDue,
    };
  }

  // ============================================
  // FILTER ACTIONS
  // ============================================

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _onTypeFilterChanged(String value) {
    setState(() => _typeFilter = value);
  }

  void _onStatusFilterChanged(String value) {
    setState(() => _statusFilter = value);
  }

  void _onStartDateChanged(DateTime? value) {
    setState(() => _startDate = value);
  }

  void _onEndDateChanged(DateTime? value) {
    setState(() => _endDate = value);
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuotationCubit, QuotationState>(
      listener: (context, state) {
        // Listen for errors and show snackbar
        if (state.errorMessage != null && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final filteredDocs = _getFilteredDocuments(state.quotations);
        final groupedDocs = _groupByCustomer(filteredDocs);
        final customerNames = groupedDocs.keys.toList()..sort();

        // Debug logging
        debugPrint('🧪 ProjectTabView: Total quotations: ${state.quotations.length}');
        debugPrint('🧪 ProjectTabView: Filtered docs: ${filteredDocs.length}');
        debugPrint('🧪 ProjectTabView: Customer groups: ${customerNames.length}');
        debugPrint('🧪 ProjectTabView: Customer names: $customerNames');

        return Column(
          children: [
            // Search & Filter Section
            SearchFilterSection(
              searchQuery: _searchQuery,
              typeFilter: _typeFilter,
              statusFilter: _statusFilter,
              startDate: _startDate,
              endDate: _endDate,
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              onTypeFilterChanged: _onTypeFilterChanged,
              onStatusFilterChanged: _onStatusFilterChanged,
              onStartDateChanged: _onStartDateChanged,
              onEndDateChanged: _onEndDateChanged,
              onClearSearch: _clearSearch,
              onClearDateFilter: _clearDateFilter,
              customerCount: customerNames.length,
              quotationCount: filteredDocs
                  .where((d) => d.type == DocumentType.quotation)
                  .length,
              invoiceCount: filteredDocs
                  .where((d) => d.type == DocumentType.invoice)
                  .length,
            ),

            // Document List
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.errorMessage != null
                      ? _buildErrorState(state.errorMessage!)
                      : customerNames.isEmpty
                          ? _buildEmptyState()
                          : _buildDocumentList(customerNames, groupedDocs),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentList(
    List<String> customerNames,
    Map<String, List<QuotationDocument>> groupedDocs,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customerNames.length,
      itemBuilder: (context, index) {
        final customerName = customerNames[index];
        final customerDocs = groupedDocs[customerName]!;
        final summary = _getCustomerSummary(customerDocs);

        return CustomerExpansionTile(
          customerName: customerName,
          documents: customerDocs,
          summary: summary,
          onDocumentTap: widget.onDocumentTap,
          cubit: context.read<QuotationCubit>(),
        );
      },
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Failed to load quotations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),

          // Error Message
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),

          // Additional Info
          Text(
            'Please check your backend server and internet connection',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),

          // Retry Button
          ElevatedButton.icon(
            onPressed: () => context.read<QuotationCubit>().loadQuotations(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'No documents found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),

          // Create Button
          ElevatedButton.icon(
            onPressed: () => widget.onCreateNew(context.read<QuotationCubit>()),
            icon: const Icon(Icons.add),
            label: const Text('Create New Quotation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Clear Filters Button (if filters active)
          if (_hasActiveFilters()) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Clear All Filters'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
        _statusFilter != 'All' ||
        _typeFilter != 'All' ||
        _startDate != null ||
        _endDate != null;
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _statusFilter = 'All';
      _typeFilter = 'All';
      _startDate = null;
      _endDate = null;
    });
  }
}
