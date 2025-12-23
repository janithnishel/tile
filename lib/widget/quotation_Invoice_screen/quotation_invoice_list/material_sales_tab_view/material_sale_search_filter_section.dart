import 'package:flutter/material.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/project_tab_view/stat_item.dart';

class MaterialSaleSearchFilterSection extends StatelessWidget {
  final String searchQuery;
  final String statusFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final Function(String) onStatusFilterChanged;
  final Function(DateTime?) onStartDateChanged;
  final Function(DateTime?) onEndDateChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onClearDateFilter;
  final int customerCount;
  final int invoiceCount;

  const MaterialSaleSearchFilterSection({
    Key? key,
    required this.searchQuery,
    required this.statusFilter,
    required this.startDate,
    required this.endDate,
    required this.searchController,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onClearSearch,
    required this.onClearDateFilter,
    required this.customerCount,
    required this.invoiceCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          const SizedBox(height: 12),

          // Date Filter Row
          _buildDateFilterRow(),
          const SizedBox(height: 12),

          // Status Filter Row
          _buildStatusFilterRow(),

          // Stats Summary Row
          const SizedBox(height: 12),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search by Customer Name or Invoice ID...',
        prefixIcon: const Icon(Icons.search, color: Colors.orange),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClearSearch,
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
        ),
      ),
    );
  }

  Widget _buildStatusFilterRow() {
    return Row(
      children: [
        // Status Filter
        Expanded(child: _buildStatusFilterDropdown()),
      ],
    );
  }

  Widget _buildStatusFilterDropdown() {
    final statuses = [
      'All',
      'Pending',
      'Paid',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: statusFilter,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: statuses
              .map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Paid':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDateFilterRow() {
    return Builder(
      builder: (context) => Row(
        children: [
          // Start Date
          Expanded(
            child: _buildDatePicker(
              context,
              label: 'From Date',
              selectedDate: startDate,
              onDateChanged: onStartDateChanged,
            ),
          ),
          const SizedBox(width: 12),
          // End Date
          Expanded(
            child: _buildDatePicker(
              context,
              label: 'To Date',
              selectedDate: endDate,
              onDateChanged: onEndDateChanged,
            ),
          ),
          const SizedBox(width: 12),
          // Clear Date Filter Button
          if (startDate != null || endDate != null)
            IconButton(
              onPressed: onClearDateFilter,
              icon: const Icon(Icons.clear),
              tooltip: 'Clear date filter',
              color: Colors.grey.shade600,
            ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context, {
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateChanged,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          onDateChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedDate != null
                    ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    : label,
                style: TextStyle(
                  color: selectedDate != null ? Colors.black : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatItemWidget(
            icon: Icons.people,
            value: customerCount.toString(),
            label: 'Customers',
            color: Colors.orange,
          ),
          StatItemWidget(
            icon: Icons.receipt_long,
            value: invoiceCount.toString(),
            label: 'Invoices',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
