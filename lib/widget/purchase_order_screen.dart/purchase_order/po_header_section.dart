import 'package:flutter/material.dart';
import 'package:tilework/models/purchase_order_screen/approved_quotation.dart';
import 'package:tilework/utils/po_status_helpers.dart';

class POHeaderSection extends StatelessWidget {
  final String? selectedQuotationId;
  final String searchQuery;
  final String statusFilter;
  final List<ApprovedQuotation> quotations;
  final Function(String?) onQuotationChanged;
  final Function(String) onSearchChanged;
  final Function(String) onStatusFilterChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onManageSuppliers;

  const POHeaderSection({
    Key? key,
    required this.selectedQuotationId,
    required this.searchQuery,
    required this.statusFilter,
    required this.quotations,
    required this.onQuotationChanged,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onClearSearch,
    required this.onManageSuppliers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(),
            const SizedBox(height: 20),
            _buildFilterRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Purchase Orders',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Manage vendor orders for approved quotations',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: onManageSuppliers,
          icon: const Icon(Icons.business, color: Colors.white, size: 18),
          label: const Text(
            'Suppliers',
            style: TextStyle(color: Colors.white),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white54),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        // Quotation Dropdown
        Expanded(flex: 2, child: _buildQuotationDropdown()),
        const SizedBox(width: 12),
        // Search Bar
        Expanded(flex: 2, child: _buildSearchBar()),
        const SizedBox(width: 12),
        // Status Filter
        _buildStatusDropdown(),
      ],
    );
  }

  Widget _buildQuotationDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedQuotationId,
          isExpanded: true,
          hint: const Row(
            children: [
              Icon(Icons.description, color: Colors.grey, size: 20),
              SizedBox(width: 8),
              Text('Select Quotation (All)'),
            ],
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.all_inclusive, color: Colors.indigo, size: 20),
                  SizedBox(width: 8),
                  Text('All Quotations'),
                ],
              ),
            ),
            ...quotations.map((q) => _buildQuotationDropdownItem(q)),
          ],
          onChanged: onQuotationChanged,
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildQuotationDropdownItem(ApprovedQuotation q) {
    return DropdownMenuItem<String>(
      value: q.quotationId,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              q.displayId,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  q.customerName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  q.projectTitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search PO, Supplier, Item...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: statusFilter,
          items: POStatusHelpers.allStatuses
              .map((status) => DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: POStatusHelpers.getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(status),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (value) => onStatusFilterChanged(value!),
        ),
      ),
    );
  }
}