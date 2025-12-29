import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final bool isQuotationCreation; // New parameter to indicate quotation creation mode
  final VoidCallback onAddItem;
  final VoidCallback onAddService;
  final Function(int, ItemDescription) onItemChanged;
  final Function(int, double) onQuantityChanged;
  final Function(int, double) onPriceChanged;
  final Function(int) onDeleteItem;
  final Function(InvoiceLineItem)? onCustomItemTap;
  final Function(int, bool)? onSiteVisitPaymentChanged; // Callback for site visit payment status changes

  const AddItemsSection({
    Key? key,
    required this.lineItems,
    required this.categories,
    required this.isAddEnabled,
    required this.isPendingQuotation,
    required this.isEditable,
    this.isQuotationCreation = false,
    required this.onAddItem,
    required this.onAddService,
    required this.onItemChanged,
    required this.onQuantityChanged,
    required this.onPriceChanged,
    required this.onDeleteItem,
    this.onCustomItemTap,
    this.onSiteVisitPaymentChanged,
  }) : super(key: key);

  // Get unique categories (ALL categories for items section)
  List<String> get _availableCategories {
    final Set<String> categoryNames = {};

    // Add ALL categories from API-loaded categories
    for (final category in categories) {
      categoryNames.add(category.name);
    }

    // Also add categories from existing line items to prevent dropdown errors
    for (final item in lineItems) {
      if (item.item.category.isNotEmpty) {
        categoryNames.add(item.item.category);
      }
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
    debugPrint('🔍 Getting products for category: "$categoryName"');

    if (categoryName == 'Select Category' || categoryName.isEmpty) {
      debugPrint('❌ Category not selected or empty');
      return ['Select Product Name'];
    }

    debugPrint('📊 Available categories: ${categories.map((c) => c.name).toList()}');

    final category = categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => CategoryModel(id: '', name: '', companyId: '', items: []),
    );

    debugPrint('🎯 Found category: ${category.name}, ID: ${category.id}, Items: ${category.items.length}');

    final Set<String> productNames = {};

    if (category.id.isNotEmpty) {
      // Category found in API, add its products
      final products = category.items
          .map((ItemModel item) => item.itemName)
          .toSet();
      productNames.addAll(products);
    } else {
      // Category not found in API, check existing line items for products in this category
      debugPrint('⚠️ Category not found in API, checking existing line items');
      for (final item in lineItems) {
        if (item.item.category == categoryName && item.item.productName.isNotEmpty) {
          productNames.add(item.item.productName);
        }
      }
    }

    if (productNames.isEmpty) {
      debugPrint('⚠️ No products available in this category');
      return ['No Products Available'];
    }

    final products = productNames.toList()..sort();
    final result = ['Select Product Name', ...products];
    debugPrint('✅ Returning products: $result');
    return result;
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
    // Show full header for all cases to ensure consistency
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
            Expanded(
              flex: 1,
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
      key: ValueKey(item.hashCode),
      index: index,
      item: item,
      categories: _availableCategories,
      getProductsForCategory: _getProductsForCategory,
      getItemDescription: _getItemDescription,
      isDropdownEditable: isEditable,
      isValueEditable: isPendingQuotation,
      isDeleteEnabled: isEditable,
      isQuotationCreation: isQuotationCreation,
      onItemChanged: (newItem) => onItemChanged(index, newItem),
      onQuantityChanged: (qty) => onQuantityChanged(index, qty),
      onPriceChanged: (price) => onPriceChanged(index, price),
      onDelete: () => onDeleteItem(index),
      onCustomItemTap: () => onCustomItemTap?.call(item),
      onSiteVisitPaymentChanged: onSiteVisitPaymentChanged != null
          ? (isPaid) => onSiteVisitPaymentChanged!(index, isPaid)
          : null,
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
  final bool isQuotationCreation; // New parameter to indicate quotation creation mode
  final Function(ItemDescription) onItemChanged;
  final Function(double) onQuantityChanged;
  final Function(double) onPriceChanged;
  final VoidCallback onDelete;
  final VoidCallback? onCustomItemTap;
  final Function(bool)? onSiteVisitPaymentChanged;

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
    required this.isQuotationCreation,
    required this.onItemChanged,
    required this.onQuantityChanged,
    required this.onPriceChanged,
    required this.onDelete,
    this.onCustomItemTap,
    this.onSiteVisitPaymentChanged,
  }) : super(key: key);

  @override
  State<_CustomLineItemRow> createState() => _CustomLineItemRowState();
}

class _CustomLineItemRowState extends State<_CustomLineItemRow> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  String? _selectedCategory;
  String? _selectedProduct;
  bool _isSiteVisitPaid = false; // Track if site visit is paid
  double _currentQuantity = 0.0;
  double _currentPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initSelections();
  }

  void _initControllers() {
    _quantityController = TextEditingController(
      text: widget.item.quantity > 0
          ? widget.item.quantity.toString()
          : '',
    );
    _priceController = TextEditingController(
      text: widget.item.item.sellingPrice > 0
          ? widget.item.item.sellingPrice.toString()
          : '',
    );

    // Initialize local state for display calculations
    _currentQuantity = widget.item.quantity;
    _currentPrice = widget.item.item.sellingPrice;
  }



  void _initSelections() {
    _selectedCategory = widget.item.item.category.isNotEmpty ? widget.item.item.category : null;
    // Initialize selected product from the saved item so existing documents
    // show the actual product/service instead of the placeholder.
    if (widget.item.item.productName.isNotEmpty) {
      _selectedProduct = widget.item.item.productName;
    } else if (widget.item.item.name.isNotEmpty) {
      // Fallback: if productName is empty but name is present (custom item), use name
      _selectedProduct = widget.item.item.name;
    } else {
      _selectedProduct = null; // Will show placeholder
    }

    // Initialize site visit payment status from saved item
    _isSiteVisitPaid = widget.item.isSiteVisitPaid;
  }

  @override
  void didUpdateWidget(_CustomLineItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item || oldWidget.categories != widget.categories) {
      _updateControllers();
      _initSelections();
    }
  }

  void _updateControllers() {
    final newQty = widget.item.quantity;
    final newPrice = widget.item.item.sellingPrice;

    // Update local state for display calculations
    _currentQuantity = widget.item.quantity;
    _currentPrice = widget.item.item.sellingPrice;

    // Only update controller if parsed value is different to prevent cursor reset
    if (double.tryParse(_quantityController.text) != newQty) {
      final newQtyText = newQty > 0 ? newQty.toString() : '';
      _quantityController.value = _quantityController.value.copyWith(
        text: newQtyText,
        selection: TextSelection.collapsed(offset: newQtyText.length),
      );
    }
    if (double.tryParse(_priceController.text) != newPrice) {
      final newPriceText = newPrice > 0 ? newPrice.toString() : '';
      _priceController.value = _priceController.value.copyWith(
        text: newPriceText,
        selection: TextSelection.collapsed(offset: newPriceText.length),
      );
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
    // Use consistent full layout for all cases
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

    // Deduplicate products to avoid DropdownMenuItem value collisions
    final List<String> uniqueProducts = [];
    final seen = <String>{};
    for (final p in products) {
      final key = p.trim().toLowerCase();
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueProducts.add(p);
      }
    }

    // Ensure selected product is valid, otherwise reset to null
    if (_selectedProduct != null && !uniqueProducts.contains(_selectedProduct)) {
      setState(() {
        _selectedProduct = null;
      });
    }

    // Check if selected product is "Site Visiting" to show payment toggle
    final isSiteVisiting = _selectedProduct?.toLowerCase().contains('site visit') ?? false;

    if (isSiteVisiting && widget.isDropdownEditable) {
      // For site visiting, show dropdown and buttons in same row
      return Row(
        children: [
          // Dropdown takes most of the space
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: _selectedProduct,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                filled: !widget.isDropdownEditable,
                fillColor: widget.isDropdownEditable ? null : Colors.grey.shade100,
                hintText: 'Select Product',
              ),
              isExpanded: true,
              items: uniqueProducts
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
                          // Only reset payment status if changing to a different product
                          // Keep saved payment status if selecting the same saved product
                          if (value != widget.item.item.productName) {
                            _isSiteVisitPaid = false;
                          }
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
            ),
          ),
          const SizedBox(width: 8),
          // Payment status buttons
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isSiteVisitPaid = false;
                      });
                      widget.onSiteVisitPaymentChanged?.call(false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isSiteVisitPaid ? Colors.blue.shade600 : Colors.grey.shade300,
                      foregroundColor: !_isSiteVisitPaid ? Colors.white : Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                      minimumSize: const Size(0, 36),
                    ),
                    child: const Text('To be Paid'),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isSiteVisitPaid = true;
                      });
                      widget.onSiteVisitPaymentChanged?.call(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSiteVisitPaid ? Colors.green.shade600 : Colors.grey.shade300,
                      foregroundColor: _isSiteVisitPaid ? Colors.white : Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                      minimumSize: const Size(0, 36),
                    ),
                    child: const Text('Paid'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Normal dropdown for non-site-visit items
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
        items: uniqueProducts
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
                    // Reset payment status when changing products
                    _isSiteVisitPaid = false;
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
  }

  Widget _buildUnitDisplay() {
    return Expanded(
      flex: 1,
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
      keyboardType: TextInputType.text,
      readOnly: !widget.isValueEditable,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !widget.isValueEditable,
        fillColor: widget.isValueEditable ? null : Colors.grey.shade100,
      ),
      onChanged: (value) {
        if (widget.isValueEditable) {
          final parsedValue = double.tryParse(value) ?? 0.0;
          widget.onQuantityChanged(parsedValue);
        }
      },
    );
  }

  Widget _buildPriceField() {
    return TextField(
      controller: _priceController,
      keyboardType: TextInputType.text,
      readOnly: !widget.isValueEditable,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !widget.isValueEditable,
        fillColor: widget.isValueEditable ? null : Colors.grey.shade100,
      ),
      onChanged: (value) {
        if (widget.isValueEditable) {
          final parsedValue = double.tryParse(value) ?? 0.0;
          widget.onPriceChanged(parsedValue);
        }
      },
    );
  }

  Widget _buildAmountDisplay() {
    // Use local state for immediate updates
    final isSiteVisitPaid = _selectedProduct?.toLowerCase().contains('site visit') ?? false;
    final baseAmount = _currentQuantity * _currentPrice;
    final displayAmount = isSiteVisitPaid && _isSiteVisitPaid ? -baseAmount : baseAmount;
    final amountColor = (isSiteVisitPaid && _isSiteVisitPaid) ? Colors.red : Colors.black;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        baseAmount != 0 ? displayAmount.toStringAsFixed(2) : '-',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: amountColor,
        ),
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
