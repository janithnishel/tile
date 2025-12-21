import 'package:flutter/material.dart';
import 'package:tilework/models/purchase_order/approved_quotation.dart';
import 'package:tilework/models/purchase_order/supplier.dart';
import 'package:tilework/utils/po_status_helpers.dart';

class POHeaderSection extends StatelessWidget {
  final String? selectedSupplierId;
  final String? selectedQuotationId;
  final String searchQuery;
  final String statusFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<ApprovedQuotation> quotations;
  final List<Supplier> suppliers;
  final Function(String?) onSupplierChanged;
  final Function(String?) onQuotationChanged;
  final Function(String) onSearchChanged;
  final Function(String) onStatusFilterChanged;
  final Function(DateTime?, DateTime?) onDateRangeChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onManageSuppliers;
  final VoidCallback onCreatePO;

  bool get _hasDateRange => startDate != null || endDate != null;

  const POHeaderSection({
    Key? key,
    required this.selectedSupplierId,
    required this.selectedQuotationId,
    required this.searchQuery,
    required this.statusFilter,
    required this.startDate,
    required this.endDate,
    required this.quotations,
    required this.suppliers,
    required this.onSupplierChanged,
    required this.onQuotationChanged,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onDateRangeChanged,
    required this.onClearSearch,
    required this.onManageSuppliers,
    required this.onCreatePO,
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
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onCreatePO,
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 18),
              label: const Text('New PO', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onManageSuppliers,
              icon: const Icon(Icons.business, color: Colors.white, size: 18),
              label: const Text('Suppliers', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Column(
      children: [
        Row(
          children: [
            // Supplier Dropdown
            Expanded(flex: 2, child: _buildSupplierDropdown()),
            const SizedBox(width: 12),
            // Quotation Dropdown
            Expanded(flex: 2, child: _buildQuotationDropdown()),
            const SizedBox(width: 12),
            // Status Filter
            _buildStatusDropdown(),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Search Bar
            Expanded(flex: 2, child: _buildSearchBar()),
            const SizedBox(width: 12),
            // Start Date
            Expanded(child: _buildStartDatePicker()),
            const SizedBox(width: 12),
            // End Date
            Expanded(child: _buildEndDatePicker()),
            // Clear Button (only show when dates are selected)
            if (_hasDateRange) ...[
              const SizedBox(width: 12),
              _buildClearDateButton(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSupplierDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSupplierId,
          isExpanded: true,
          hint: const Row(
            children: [
              Icon(Icons.business, color: Colors.grey, size: 20),
              SizedBox(width: 8),
              Text('Select Supplier (All)'),
            ],
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.all_inclusive, color: Colors.indigo, size: 20),
                  SizedBox(width: 8),
                  Text('All Suppliers'),
                ],
              ),
            ),
            ...suppliers.map((s) => _buildSupplierDropdownItem(s)),
          ],
          onChanged: onSupplierChanged,
        ),
      ),
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

  DropdownMenuItem<String> _buildSupplierDropdownItem(Supplier s) {
    return DropdownMenuItem<String>(
      value: s.id,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              s.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
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
                  s.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  s.phone,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
              .map(
                (status) => DropdownMenuItem(
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
                ),
              )
              .toList(),
          onChanged: (value) => onStatusFilterChanged(value!),
        ),
      ),
    );
  }

  Widget _buildStartDatePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Builder(
        builder: (context) => TextButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: startDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              onDateRangeChanged(picked, endDate);
            }
          },
          icon: const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
          label: Text(
            startDate != null
                ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                : 'Start Date',
            style: TextStyle(
              color: startDate != null ? Colors.black : Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEndDatePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Builder(
        builder: (context) => TextButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: endDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              onDateRangeChanged(startDate, picked);
            }
          },
          icon: const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
          label: Text(
            endDate != null
                ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                : 'End Date',
            style: TextStyle(
              color: endDate != null ? Colors.black : Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearDateButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () => onDateRangeChanged(null, null),
        icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
        tooltip: 'Clear Date Range',
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context) {
    final hasDateRange = startDate != null || endDate != null;

    return Row(
      children: [
        // Start Date
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  onDateRangeChanged(picked, endDate);
                }
              },
              icon: const Icon(
                Icons.calendar_today,
                color: Colors.grey,
                size: 18,
              ),
              label: Text(
                startDate != null
                    ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                    : 'Start Date',
                style: TextStyle(
                  color: startDate != null ? Colors.black : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // End Date
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: endDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  onDateRangeChanged(startDate, picked);
                }
              },
              icon: const Icon(
                Icons.calendar_today,
                color: Colors.grey,
                size: 18,
              ),
              label: Text(
                endDate != null
                    ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                    : 'End Date',
                style: TextStyle(
                  color: endDate != null ? Colors.black : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        // Clear Dates Button - Only show when dates are selected
        if (hasDateRange) ...[
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => onDateRangeChanged(null, null),
              icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
              tooltip: 'Clear Date Range',
            ),
          ),
        ],
      ],
    );
  }
}
