// lib/widget/quotation_Invoice_screen/quotation_list/material_sale_tab_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/material_sale/material_sale_cubit.dart';
import 'package:tilework/cubits/material_sale/material_sale_state.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_enums.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/material_sales_tab_view/material_sale_list_tile.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/material_sales_tab_view/material_sale_search_filter_section.dart';

class MaterialSaleTabView extends StatefulWidget {
  final Function(MaterialSaleCubit) onCreateNew;
  final Function(MaterialSaleDocument, MaterialSaleCubit) onDocumentTap;

  const MaterialSaleTabView({
    Key? key,
    required this.onCreateNew,
    required this.onDocumentTap,
  }) : super(key: key);

  @override
  State<MaterialSaleTabView> createState() => _MaterialSaleTabViewState();
}

class _MaterialSaleTabViewState extends State<MaterialSaleTabView> {
  // Search & Filter State
  String _searchQuery = '';
  String _statusFilter = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();

  // Infinite Scroll
  final ScrollController _scrollController = ScrollController();
  bool _isNearBottom = false;

  @override
  void initState() {
    super.initState();
    // Load material sales when the tab is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialSaleCubit>().loadMaterialSales();
    });

    // Set up scroll listener for infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Calculate 80% threshold of the scrollable area
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * 0.8; // 80% threshold

    final isNearBottom = currentScroll >= threshold;

    // Only trigger if we just crossed the threshold
    if (isNearBottom && !_isNearBottom) {
      setState(() => _isNearBottom = true);
      _loadMoreIfAvailable();
    } else if (!isNearBottom && _isNearBottom) {
      setState(() => _isNearBottom = false);
    }
  }

  void _loadMoreIfAvailable() {
    final cubit = context.read<MaterialSaleCubit>();
    final state = cubit.state;

    if (state.hasMoreData && !state.isLoadingMore) {
      debugPrint('📄 Loading more material sales...');
      cubit.loadMoreMaterialSales(
        status: _statusFilter != 'All' ? _statusFilter.toLowerCase() : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        startDate: _startDate?.toIso8601String(),
        endDate: _endDate?.toIso8601String(),
      );
    }
  }

  // ============================================
  // FILTER METHODS
  // ============================================

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _reloadDataWithFilters();
  }

  void _onStatusFilterChanged(String value) {
    setState(() => _statusFilter = value);
    _reloadDataWithFilters();
  }

  void _onStartDateChanged(DateTime? value) {
    setState(() => _startDate = value);
    _reloadDataWithFilters();
  }

  void _onEndDateChanged(DateTime? value) {
    setState(() => _endDate = value);
    _reloadDataWithFilters();
  }

  void _reloadDataWithFilters() {
    final cubit = context.read<MaterialSaleCubit>();
    cubit.loadMaterialSales(
      resetPagination: true, // Reset pagination when filters change
      status: _statusFilter != 'All' ? _statusFilter.toLowerCase() : null,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      startDate: _startDate?.toIso8601String(),
      endDate: _endDate?.toIso8601String(),
    );
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

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
        _statusFilter != 'All' ||
        _startDate != null ||
        _endDate != null;
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _statusFilter = 'All';
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MaterialSaleCubit, MaterialSaleState>(
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
        final filteredDocs = _getFilteredDocuments(state.materialSales);
        final groupedDocs = _groupByCustomer(filteredDocs);
        final customerNames = groupedDocs.keys.toList()..sort();

        return Column(
          children: [
            // Search & Filter Section
            MaterialSaleSearchFilterSection(
              searchQuery: _searchQuery,
              statusFilter: _statusFilter,
              startDate: _startDate,
              endDate: _endDate,
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              onStatusFilterChanged: _onStatusFilterChanged,
              onStartDateChanged: _onStartDateChanged,
              onEndDateChanged: _onEndDateChanged,
              onClearSearch: _clearSearch,
              onClearDateFilter: _clearDateFilter,
              customerCount: customerNames.length,
              invoiceCount: filteredDocs.length,
            ),

            // Document List
            Expanded(
              child: Container(
                color: Colors.grey.shade50,
                child: state.isLoading
                    ? _buildShimmerLoading()
                    : state.errorMessage != null
                        ? _buildErrorState(state.errorMessage!)
                        : customerNames.isEmpty
                            ? _buildEmptyState(context.read<MaterialSaleCubit>(), state)
                            : _buildDocumentList(customerNames, groupedDocs, context.read<MaterialSaleCubit>()),
              ),
            ),
          ],
        );
      },
    );
  }

  List<MaterialSaleDocument> _getFilteredDocuments(List<MaterialSaleDocument> documents) {
    return documents.where((doc) {
      final query = _searchQuery.toLowerCase();

      final matchesSearch = query.isEmpty ||
          doc.customerName.toLowerCase().contains(query) ||
          doc.invoiceNumber.toLowerCase().contains(query) ||
          doc.customerPhone.toLowerCase().contains(query);

      final matchesStatus = _statusFilter == 'All' ||
          doc.status.name.toUpperCase() == _statusFilter.toUpperCase();

      final matchesDate = (_startDate == null ||
              doc.saleDate.isAfter(_startDate!.subtract(const Duration(days: 1)))) &&
          (_endDate == null ||
              doc.saleDate.isBefore(_endDate!.add(const Duration(days: 1))));

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();
  }

  Map<String, List<MaterialSaleDocument>> _groupByCustomer(List<MaterialSaleDocument> documents) {
    final Map<String, List<MaterialSaleDocument>> grouped = {};

    for (var doc in documents) {
      final customerKey = doc.customerName.isNotEmpty ? doc.customerName : 'Unassigned Customer';
      grouped.putIfAbsent(customerKey, () => []).add(doc);
    }

    grouped.forEach((customer, docs) {
      docs.sort((a, b) => b.saleDate.compareTo(a.saleDate));
    });

    return grouped;
  }

  Map<String, dynamic> _getCustomerSummary(List<MaterialSaleDocument> docs) {
    int sales = 0;
    double totalAmount = 0;
    double totalDue = 0;

    for (var doc in docs) {
      sales++;
      totalAmount += doc.totalAmount;
      totalDue += doc.amountDue;
    }

    return {
      'sales': sales,
      'totalAmount': totalAmount,
      'totalDue': totalDue,
    };
  }

  Widget _buildDocumentList(
    List<String> customerNames,
    Map<String, List<MaterialSaleDocument>> groupedDocs,
    MaterialSaleCubit cubit,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: customerNames.length + (cubit.state.isLoadingMore ? 1 : 0), // Add 1 for loading indicator
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom
        if (cubit.state.isLoadingMore && index == customerNames.length) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
          );
        }

        final customerName = customerNames[index];
        final customerDocs = groupedDocs[customerName]!;
        final summary = _getCustomerSummary(customerDocs);

        return _buildCustomerExpansionTile(customerName, customerDocs, summary, cubit);
      },
    );
  }

  Widget _buildCustomerExpansionTile(
    String customerName,
    List<MaterialSaleDocument> documents,
    Map<String, dynamic> summary,
    MaterialSaleCubit cubit,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Text(
            customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customerName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: _buildCustomerSubtitle(summary),
        children: documents
            .map((doc) => MaterialSaleListTile(
                  sale: doc,
                  onTap: () => widget.onDocumentTap(doc, cubit),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCustomerSubtitle(Map<String, dynamic> summary) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${summary['sales']} Sale${summary['sales'] > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          if (summary['totalDue'] > 0)
            Text(
              'Due: Rs ${summary['totalDue'].toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          Text(
            'Failed to load material sales',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.read<MaterialSaleCubit>().loadMaterialSales(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Show 5 shimmer items
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header shimmer
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Subtitle shimmer
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 16),
                // Content shimmer (simulate expansion tile items)
                ...List.generate(2, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(MaterialSaleCubit cubit, MaterialSaleState state) {
    final hasFilters = _hasActiveFilters();
    final isInitialLoadWithNoResults = !hasFilters && !state.isLoading && state.materialSales.isEmpty && state.totalRecords == 0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isInitialLoadWithNoResults ? Icons.inventory_2_outlined : Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isInitialLoadWithNoResults
                ? 'No records found'
                : hasFilters
                    ? 'No sales match your filters'
                    : 'No material sales yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isInitialLoadWithNoResults
                ? 'There are no material sales in the system yet'
                : hasFilters
                    ? 'Try adjusting your search or filters'
                    : 'Create your first material sale',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          if (!hasFilters && !isInitialLoadWithNoResults)
            ElevatedButton.icon(
              onPressed: () => widget.onCreateNew(cubit),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Create New Sale'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
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
          if (hasFilters) ...[
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
}
