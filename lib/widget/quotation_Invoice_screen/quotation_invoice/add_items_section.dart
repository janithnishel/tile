import 'package:flutter/material.dart';
import 'package:tilework/data/mock_data.dart';
import 'package:tilework/models/category_model.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/project_tab_view/line_item_row.dart';

class AddItemsSection extends StatelessWidget {
  final List<InvoiceLineItem> lineItems;
  final List<CategoryModel> categories;
  final bool isAddEnabled;
  final bool isPendingQuotation;
  final bool isEditable;
  final VoidCallback onAddItem;
  final VoidCallback onAddService;
  final Function(int, ItemDescription) onItemChanged;
  final Function(int, double) onQuantityChanged;
  final Function(int, double) onPriceChanged;
  final Function(int) onDeleteItem;
  final Function(InvoiceLineItem)? onCustomItemTap;

  const AddItemsSection({
    Key? key,
    required this.lineItems,
    required this.categories,
    required this.isAddEnabled,
    required this.isPendingQuotation,
    required this.isEditable,
    required this.onAddItem,
    required this.onAddService,
    required this.onItemChanged,
    required this.onQuantityChanged,
    required this.onPriceChanged,
    required this.onDeleteItem,
    this.onCustomItemTap,
  }) : super(key: key);

  // Convert categories and their items to ItemDescription list
  List<ItemDescription> get _availableItems {
    final List<ItemDescription> items = [];
    final Set<String> seenNames = {}; // Track unique item names

    // First, add all items from existing line items to ensure compatibility
    for (final lineItem in lineItems) {
      final existingItem = lineItem.item;
      if (!seenNames.contains(existingItem.name)) {
        items.add(existingItem);
        seenNames.add(existingItem.name);
      }
    }

    // Then add items from API-loaded categories
    for (final category in categories) {
      // Add all items from this category
      for (final item in category.items) {
        // Ensure unique item names to avoid dropdown conflicts
        final uniqueName = seenNames.contains(item.itemName)
            ? '${item.itemName} (${category.name})' // Add category suffix for duplicates
            : item.itemName;

        if (!seenNames.contains(uniqueName)) {
          items.add(
            ItemDescription(
              uniqueName, // name - ensure uniqueness
              sellingPrice: 0.0, // Default price, can be customized later
              unit: item.baseUnit,
              category: category.name,
              categoryId: category.id,
              productName: item.itemName,
            ),
          );

          seenNames.add(uniqueName);
        }
      }

      // If category has no items, add a placeholder item so the category appears in dropdown
      if (category.items.isEmpty &&
          !seenNames.contains('${category.name} - No Items')) {
        items.add(
          ItemDescription(
            '${category.name} - No Items',
            sellingPrice: 0.0,
            unit: 'units',
            category: category.name,
            categoryId: category.id,
            productName: 'No Items Available',
          ),
        );
        seenNames.add('${category.name} - No Items');
      }
    }

    // Add items from mock data if no categories are loaded from API
    if (categories.isEmpty) {
      for (final mockItem in masterItemList) {
        if (!seenNames.contains(mockItem.name)) {
          items.add(mockItem);
          seenNames.add(mockItem.name);
        }
      }
    }

    // Add a custom item option if still no items are available
    if (items.isEmpty) {
      items.add(
        ItemDescription(
          'Custom Item',
          sellingPrice: 0.0,
          unit: 'units',
          category: 'Custom',
          productName: 'Custom Item',
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Add Items',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (lineItems.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Text(
                      '${lineItems.length} item${lineItems.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            ElevatedButton.icon(
              onPressed: isAddEnabled ? onAddItem : null,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAddEnabled
                    ? Colors.blue.shade700
                    : Colors.grey.shade300,
                foregroundColor: isAddEnabled
                    ? Colors.white
                    : Colors.grey.shade600,
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
              availableItems: _availableItems,
              isDropdownEditable:
                  isPendingQuotation ||
                  (!item.isOriginalQuotationItem && isEditable),
              isValueEditable:
                  isPendingQuotation ||
                  (!item.isOriginalQuotationItem && isEditable),
              isDeleteEnabled:
                  isPendingQuotation ||
                  (!item.isOriginalQuotationItem && isEditable),
              onItemChanged: (newItem) => onItemChanged(index, newItem),
              onQuantityChanged: (qty) => onQuantityChanged(index, qty),
              onPriceChanged: (price) => onPriceChanged(index, price),
              onDelete: () => onDeleteItem(index),
              onCustomItemTap: () => onCustomItemTap?.call(item),
            );
          }),

          // Items Total
          _buildItemsTotal(),
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
            Icon(
              Icons.add_shopping_cart,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No items added yet',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the buttons above to add services or items',
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
              flex: 2,
              child: Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Text(
                'Product Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: Text(
                'Unit',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 8),
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

  Widget _buildItemsTotal() {
    // Calculate total for all line items
    final total = lineItems.fold<double>(
      0.0,
      (sum, item) => sum + item.amount,
    );

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Items Total',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Text(
            'Rs ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
