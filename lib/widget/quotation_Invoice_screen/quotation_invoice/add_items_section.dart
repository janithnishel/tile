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

  // Get unique categories (ALL categories for items section)
  List<String> get _availableCategories {
    final Set<String> categoryNames = {};

    // Add ALL categories from API-loaded categories
    for (final category in categories) {
      categoryNames.add(category.name);
    }

    // Convert to sorted list
    final sortedCategories = categoryNames.toList()..sort();

    // Add default option for new quotations
    if (sortedCategories.isEmpty) {
      return ['Select Category'];
    }

    return ['Select Category', ...sortedCategories];
  }

  // Get products for a specific category (materials only for items section)
  List<String> _getProductsForCategory(String categoryName) {
    if (categoryName == 'Select Category' || categoryName.isEmpty) {
      return ['Select Product Name'];
    }

    final category = categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => CategoryModel(id: '', name: '', companyId: '', items: []),
    );

    if (category.id.isEmpty) {
      return ['Select Product Name'];
    }

    // For items section, show both materials and services
    final products = category.items
        .map((ItemModel item) => item.itemName)
        .toSet()
        .toList()
      ..sort();

    if (products.isEmpty) {
      return ['No Products Available'];
    }

    return ['Select Product Name', ...products];
  }

  // Get ItemDescription for a category and product combination
  ItemDescription? _getItemDescription(String categoryName, String productName) {
    if (categoryName == 'Select Category' || productName == 'Select Product Name' || productName == 'No Products Available') {
      return null;
    }

    final category = categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => CategoryModel(id: '', name: '', companyId: '', items: []),
    );

    if (category.id.isEmpty) return null;

    final item = category.items.firstWhere(
      (ItemModel item) => item.itemName == productName,
      orElse: () => ItemModel(
        id: '',
        itemName: '',
        baseUnit: '',
        sqftPerUnit: 0.0,
        categoryId: '',
        isService: false,
      ),
    );

    if (item.id.isEmpty) return null;

    return ItemDescription(
      productName,
      sellingPrice: 0.0,
      unit: item.baseUnit,
      category: category.name,
      categoryId: category.id,
      productName: item.itemName,
      type: item.isService ? ItemType.service : ItemType.material,
    );
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

            return _buildLineItemRow(index, item);
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
                'Product Name/Service Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: Text(
                'Unit Type',
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



  // Build a custom LineItemRow with separate Category and Product dropdowns
  Widget _buildLineItemRow(int index, InvoiceLineItem item) {
    return _CustomLineItemRow(
      key: ValueKey(item),
      index: index,
      item: item,
      categories: _availableCategories,
      getProductsForCategory: _getProductsForCategory,
      getItemDescription: _getItemDescription,
      isDropdownEditable: isEditable,
      isValueEditable: isPendingQuotation,
      isDeleteEnabled: isEditable,
      onItemChanged: (newItem) => onItemChanged(index, newItem),
      onQuantityChanged: (qty) => onQuantityChanged(index, qty),
      onPriceChanged: (price) => onPriceChanged(index, price),
      onDelete: () => onDeleteItem(index),
      onCustomItemTap: () => onCustomItemTap?.call(item),
    );
  }
}

// Custom Line Item Row with separate Category and Product dropdowns
class _CustomLineItemRow extends StatefulWidget {
  final int index;
  final InvoiceLineItem item;
  final List<String> categories;
  final List<String> Function(String) getProductsForCategory;
  final ItemDescription? Function(String, String) getItemDescription;
  final bool isDropdownEditable;
  final bool isValueEditable;
  final bool isDeleteEnabled;
  final Function(ItemDescription) onItemChanged;
  final Function(double) onQuantityChanged;
  final Function(double) onPriceChanged;
  final VoidCallback onDelete;
  final VoidCallback? onCustomItemTap;

  const _CustomLineItemRow({
    Key? key,
    required this.index,
    required this.item,
    required this.categories,
    required this.getProductsForCategory,
    required this.getItemDescription,
    required this.isDropdownEditable,
    required this.isValueEditable,
    required this.isDeleteEnabled,
    required this.onItemChanged,
    required this.onQuantityChanged,
    required this.onPriceChanged,
    required this.onDelete,
    this.onCustomItemTap,
  }) : super(key: key);

  @override
  State<_CustomLineItemRow> createState() => _CustomLineItemRowState();
}

class _CustomLineItemRowState extends State<_CustomLineItemRow> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  String? _selectedCategory;
  String? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initSelections();
  }

  void _initControllers() {
    _quantityController = TextEditingController(
      text: widget.item.quantity > 0
          ? widget.item.quantity.toStringAsFixed(1)
          : '',
    );
    _priceController = TextEditingController(
      text: widget.item.item.sellingPrice > 0
          ? widget.item.item.sellingPrice.toStringAsFixed(2)
          : '',
    );
  }

  void _initSelections() {
    _selectedCategory = widget.item.item.category.isNotEmpty ? widget.item.item.category : null;
    _selectedProduct = null; // Reset to null initially, will be set properly when dropdown builds
  }

  @override
  void didUpdateWidget(_CustomLineItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _updateControllers();
      _initSelections();
    }
  }

  void _updateControllers() {
    final newQty = widget.item.quantity > 0
        ? widget.item.quantity.toStringAsFixed(1)
        : '';
    final newPrice = widget.item.item.sellingPrice > 0
        ? widget.item.item.sellingPrice.toStringAsFixed(2)
        : '';

    if (_quantityController.text != newQty) {
      _quantityController.text = newQty;
    }
    if (_priceController.text != newPrice) {
      _priceController.text = newPrice;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Category Dropdown
          Expanded(
            flex: 2,
            child: _buildCategoryDropdown(),
          ),
          const SizedBox(width: 8),

          // Product Name Dropdown
          Expanded(
            flex: 2,
            child: _buildProductDropdown(),
          ),
          const SizedBox(width: 8),

          // Unit Display
          _buildUnitDisplay(),
          const SizedBox(width: 8),

          // Quantity
          Expanded(
            flex: 1,
            child: _buildQuantityField(),
          ),
          const SizedBox(width: 8),

          // Price
          Expanded(
            flex: 1,
            child: _buildPriceField(),
          ),
          const SizedBox(width: 8),

          // Amount
          Expanded(
            flex: 1,
            child: _buildAmountDisplay(),
          ),

          // Delete Button
          _buildDeleteButton(),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !widget.isDropdownEditable,
        fillColor: widget.isDropdownEditable ? null : Colors.grey.shade100,
        hintText: 'Select Category',
      ),
      isExpanded: true,
      items: widget.categories
          .map(
            (category) => DropdownMenuItem(
              value: category,
              child: Text(category),
            ),
          )
          .toList(),
      onChanged: widget.isDropdownEditable
          ? (value) {
              setState(() {
                _selectedCategory = value;
                _selectedProduct = null; // Reset product when category changes
              });
            }
          : null,
    );
  }

  Widget _buildProductDropdown() {
    final products = _selectedCategory != null
        ? widget.getProductsForCategory(_selectedCategory!)
        : ['Select Category First'];

    return DropdownButtonFormField<String>(
      value: _selectedProduct,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !widget.isDropdownEditable,
        fillColor: widget.isDropdownEditable ? null : Colors.grey.shade100,
        hintText: 'Select Product',
      ),
      isExpanded: true,
      items: products
          .map(
            (product) => DropdownMenuItem(
              value: product,
              child: Text(product),
            ),
          )
          .toList(),
      onChanged: (widget.isDropdownEditable && _selectedCategory != null && _selectedCategory != 'Select Category')
          ? (value) {
              if (value != null && value != 'Select Product Name') {
                setState(() {
                  _selectedProduct = value;
                });

                final itemDesc = widget.getItemDescription(_selectedCategory!, value);
                if (itemDesc != null) {
                  widget.onItemChanged(itemDesc);
                  setState(() {
                    _priceController.text = itemDesc.sellingPrice > 0
                        ? itemDesc.sellingPrice.toStringAsFixed(2)
                        : '';
                  });
                }
              }
            }
          : null,
    );
  }

  Widget _buildUnitDisplay() {
    return SizedBox(
      width: 70,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(widget.item.item.unit.isNotEmpty ? widget.item.item.unit : '-'),
      ),
    );
  }

  Widget _buildQuantityField() {
    return TextField(
      controller: _quantityController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      readOnly: !widget.isValueEditable,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !widget.isValueEditable,
        fillColor: widget.isValueEditable ? null : Colors.grey.shade100,
        hintText: '0',
      ),
      onChanged: (value) {
        if (widget.isValueEditable) {
          widget.onQuantityChanged(double.tryParse(value) ?? 0.0);
        }
      },
    );
  }

  Widget _buildPriceField() {
    return TextField(
      controller: _priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      readOnly: !widget.isValueEditable,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !widget.isValueEditable,
        fillColor: widget.isValueEditable ? null : Colors.grey.shade100,
        hintText: '0.00',
      ),
      onChanged: (value) {
        if (widget.isValueEditable) {
          widget.onPriceChanged(double.tryParse(value) ?? 0.0);
        }
      },
    );
  }

  Widget _buildAmountDisplay() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.item.amount > 0 ? widget.item.amount.toStringAsFixed(2) : '-',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDeleteButton() {
    if (widget.isDeleteEnabled) {
      return SizedBox(
        width: 40,
        child: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: widget.onDelete,
        ),
      );
    }
    return const SizedBox(width: 40);
  }
}
