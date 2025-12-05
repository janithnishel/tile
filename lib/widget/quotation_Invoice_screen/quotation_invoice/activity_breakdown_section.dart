import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_list/project_tab_view/line_item_row.dart';

class ActivityBreakdownSection extends StatelessWidget {
  final List<InvoiceLineItem> lineItems;
  final bool isAddEnabled;
  final bool isPendingQuotation;
  final bool isEditable;
  final VoidCallback onAddItem;
  final Function(int, ItemDescription) onItemChanged;
  final Function(int, double) onQuantityChanged;
  final Function(int, double) onPriceChanged;
  final Function(int) onDeleteItem;
  final Function(InvoiceLineItem)? onCustomItemTap;

  const ActivityBreakdownSection({
    Key? key,
    required this.lineItems,
    required this.isAddEnabled,
    required this.isPendingQuotation,
    required this.isEditable,
    required this.onAddItem,
    required this.onItemChanged,
    required this.onQuantityChanged,
    required this.onPriceChanged,
    required this.onDeleteItem,
    this.onCustomItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Activity Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: isAddEnabled ? onAddItem : null,
              icon: const Icon(Icons.add),
              label: const Text('Add Activity / Adjustment'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isAddEnabled ? Colors.blue.shade700 : Colors.grey.shade300,
                foregroundColor:
                    isAddEnabled ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Empty State
        if (lineItems.isEmpty)
          _buildEmptyState()
        else ...[
          // Table Header
          _buildTableHeader(),

          // Line Items
          ...lineItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

              return LineItemRow(
                index: index,
                item: item,
                isDropdownEditable: isPendingQuotation || (!item.isOriginalQuotationItem && isEditable),
                isValueEditable: isPendingQuotation || (!item.isOriginalQuotationItem && isEditable),
                isDeleteEnabled: isPendingQuotation || (!item.isOriginalQuotationItem && isEditable),
              onItemChanged: (newItem) => onItemChanged(index, newItem),
              onQuantityChanged: (qty) => onQuantityChanged(index, qty),
              onPriceChanged: (price) => onPriceChanged(index, price),
              onDelete: () => onDeleteItem(index),
              onCustomItemTap: () => onCustomItemTap?.call(item),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.add_shopping_cart, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No items added yet',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Click "Add Activity / Adjustment" to start adding items',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 40),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue.shade50),
        child: const Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Activity/Item',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 78),
            Expanded(
              flex: 1,
              child: Text(
                'Quantity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Text(
                'Price (LKR)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Text(
                'Amount (LKR)',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
