// lib/widget/material_sale/sections/ms_product_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/super_admin/category/category_cubit.dart';
import 'package:tilework/cubits/super_admin/category/category_state.dart';
import 'package:tilework/models/category_model.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sales_item.dart';

class MSProductSection extends StatelessWidget {
  final List<MaterialSaleItem> items;
  final bool isEditable;
  final VoidCallback onAddItem;
  final Function(int) onRemoveItem;
  final Function(int, MaterialSaleItem) onItemChanged;

  const MSProductSection({
    Key? key,
    required this.items,
    required this.isEditable,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onItemChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          _buildSectionHeader(),
          const SizedBox(height: 16),

          // Items List
          if (items.isEmpty)
            _buildEmptyState()
          else
            ...items.asMap().entries.map((entry) {
              return _ProductItemCard(
                index: entry.key,
                item: entry.value,
                isEditable: isEditable,
                onRemove: () => onRemoveItem(entry.key),
                onChanged: (item) => onItemChanged(entry.key, item),
              );
            }).toList(),

          // Add Item Button
          if (isEditable) ...[
            const SizedBox(height: 12),
            _buildAddButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            color: Colors.blue.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${items.length} item(s)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.add_shopping_cart,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No products added',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap the button below to add products',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onAddItem,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue.shade600,
          side: BorderSide(color: Colors.blue.shade300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

// ============================================
// PRODUCT ITEM CARD
// ============================================

class _ProductItemCard extends StatefulWidget {
  final int index;
  final MaterialSaleItem item;
  final bool isEditable;
  final VoidCallback onRemove;
  final Function(MaterialSaleItem) onChanged;

  const _ProductItemCard({
    required this.index,
    required this.item,
    required this.isEditable,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_ProductItemCard> createState() => _ProductItemCardState();
}

class _ProductItemCardState extends State<_ProductItemCard> {
  late TextEditingController _plankController;
  late TextEditingController _sqftController;
  late TextEditingController _priceController;
  late TextEditingController _costController;
  late TextEditingController _colorCodeController;

  CategoryModel? _selectedCategory;
  ItemModel? _selectedItem;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _plankController = TextEditingController(
      text: widget.item.plank > 0 ? widget.item.plank.toString() : '',
    );
    _sqftController = TextEditingController(
      text: widget.item.totalSqft > 0 ? widget.item.totalSqft.toString() : '',
    );
    _priceController = TextEditingController(
      text: widget.item.unitPrice > 0 ? widget.item.unitPrice.toString() : '',
    );
    _costController = TextEditingController(
      text: widget.item.costPerSqft > 0 ? widget.item.costPerSqft.toString() : '',
    );
    _colorCodeController = TextEditingController(
      text: widget.item.colorCode,
    );
  }

  void _initSelections(List<CategoryModel> categories) {
    if (_selectedCategory != null || _selectedItem != null) return; // Already initialized

    debugPrint('🔍 _initSelections called for item with categoryId="${widget.item.categoryId}", itemId="${widget.item.itemId}", productName="${widget.item.productName}"');

    // Find category by categoryId
    if (widget.item.categoryId.isNotEmpty) {
      final matchingCategories = categories.where((category) => category.id == widget.item.categoryId);
      _selectedCategory = matchingCategories.isNotEmpty ? matchingCategories.first : null;

      debugPrint('📂 Found category: ${_selectedCategory?.name ?? "NOT FOUND"}');

      // Find item by itemId within the selected category
      if (_selectedCategory != null && widget.item.itemId.isNotEmpty) {
        final matchingItems = _selectedCategory!.items.where((item) => item.id == widget.item.itemId);
        _selectedItem = matchingItems.isNotEmpty ? matchingItems.first : null;

        debugPrint('🛍️ Found item: ${_selectedItem?.itemName ?? "NOT FOUND"}');
      } else {
        debugPrint('⚠️ No itemId or category not found');
      }
    } else {
      debugPrint('⚠️ No categoryId found');
    }

    // If we couldn't find by IDs, try fallback: find by productName within categories
    if (_selectedItem == null && widget.item.productName.isNotEmpty) {
      debugPrint('🔄 Trying fallback search by productName: "${widget.item.productName}"');

      for (final category in categories) {
        final matchingItems = category.items.where((item) => item.itemName == widget.item.productName);
        if (matchingItems.isNotEmpty) {
          _selectedItem = matchingItems.first;
          _selectedCategory = category;
          debugPrint('✅ Found by productName fallback: category="${category.name}", item="${_selectedItem!.itemName}"');
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _plankController.dispose();
    _sqftController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _colorCodeController.dispose();
    super.dispose();
  }

  void _updateItem() {
    final plank = double.tryParse(_plankController.text) ?? 0;
    final sqft = double.tryParse(_sqftController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final cost = double.tryParse(_costController.text) ?? 0;

    final updatedItem = widget.item.copyWith(
      categoryId: _selectedCategory?.id ?? '',
      categoryName: _selectedCategory?.name ?? '',
      itemId: _selectedItem?.id ?? '',
      colorCode: _colorCodeController.text,
      productName: _selectedItem?.itemName ?? widget.item.productName,
      plank: plank,
      sqftPerPlank: _selectedItem?.sqftPerUnit ?? widget.item.sqftPerPlank,
      totalSqft: sqft,
      unitPrice: price,
      amount: sqft * price,
      costPerSqft: cost,
      totalCost: sqft * cost,
    );

    widget.onChanged(updatedItem);
  }

  void _onItemSelected(ItemModel? item) {
    if (item == null) return;

    setState(() {
      _selectedItem = item;
      _priceController.text = '0'; // Default, can be edited
      _costController.text = '0'; // Default, can be edited

      // Auto-calculate sqft if plank is entered
      final plank = double.tryParse(_plankController.text) ?? 0;
      if (plank > 0) {
        _sqftController.text = (plank * item.sqftPerUnit).toString();
      }
    });
    _updateItem();
  }

  void _onPlankChanged(String value) {
    final plank = double.tryParse(value) ?? 0;
    if (_selectedItem != null && plank > 0) {
      setState(() {
        _sqftController.text = (plank * _selectedItem!.sqftPerUnit).toString();
      });
    }
    _updateItem();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with delete button
            _buildCardHeader(),
            const SizedBox(height: 16),

            // Category Dropdown
            _buildCategoryDropdown(),
            const SizedBox(height: 12),

            // Product Dropdown
            _buildProductDropdown(),
            const SizedBox(height: 12),

            // Color Code
            _buildColorCodeField(),
            const SizedBox(height: 12),

            // Quantity Row (Plank & Sqft)
            _buildQuantityRow(),
            const SizedBox(height: 12),

            // Price Row (Unit Price & Cost)
            _buildPriceRow(),
            const SizedBox(height: 16),

            // Calculated Values
            _buildCalculatedValues(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    final categoryText = widget.item.categoryName.isNotEmpty
        ? widget.item.categoryName
        : 'Category';
    final productText = widget.item.productName.isNotEmpty
        ? widget.item.productName
        : 'Product ${widget.index + 1}';
    final displayText = '$categoryText: $productText';

    // Debug logging for data visibility
    debugPrint('🛍️ Item ${widget.index + 1} display: categoryName="${widget.item.categoryName}", productName="${widget.item.productName}", categoryId="${widget.item.categoryId}", itemId="${widget.item.itemId}"');

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${widget.index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayText,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (widget.item.colorCode.isNotEmpty)
                Text(
                  'Color: ${widget.item.colorCode}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
        if (widget.isEditable)
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: widget.onRemove,
            tooltip: 'Remove item',
          ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, categoryState) {
        final categories = categoryState.categories;

        // Initialize selections when categories are loaded
        if (categories.isNotEmpty) {
          _initSelections(categories);
        }

        // In view mode (not editable), show a read-only text field instead of disabled dropdown
        if (!widget.isEditable) {
          return TextFormField(
            initialValue: _selectedCategory?.name ?? widget.item.categoryName,
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Category',
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }

        // In edit mode, show the dropdown
        return DropdownButtonFormField<CategoryModel>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Category',
            prefixIcon: const Icon(Icons.category_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(
                category.name,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
              _selectedItem = null;
            });
            _updateItem();
          },
          hint: const Text('Select category'),
        );
      },
    );
  }

  Widget _buildProductDropdown() {
    final items = _selectedCategory?.items ?? [];

    // In view mode (not editable), show a read-only text field instead of disabled dropdown
    if (!widget.isEditable) {
      return TextFormField(
        initialValue: _selectedItem?.itemName ?? widget.item.productName,
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Product',
          prefixIcon: const Icon(Icons.shopping_bag_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }

    // In edit mode, show the dropdown
    return DropdownButtonFormField<ItemModel>(
      value: _selectedItem,
      decoration: InputDecoration(
        labelText: 'Select Product',
        prefixIcon: const Icon(Icons.shopping_bag_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item.itemName,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _onItemSelected,
      hint: Text(
        items.isEmpty ? 'Select category first' : 'Choose product',
      ),
    );
  }

  Widget _buildColorCodeField() {
    return TextFormField(
      controller: _colorCodeController,
      enabled: widget.isEditable,
      decoration: InputDecoration(
        labelText: 'Color Code',
        prefixIcon: const Icon(Icons.palette_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (_) => _updateItem(),
    );
  }

  Widget _buildQuantityRow() {
    return Row(
      children: [
        // Plank
        Expanded(
          child: TextFormField(
            controller: _plankController,
            enabled: widget.isEditable,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Plank/Boxes',
              prefixIcon: const Icon(Icons.view_module_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: _onPlankChanged,
          ),
        ),
        const SizedBox(width: 12),
        // Sqft
        Expanded(
          child: TextFormField(
            controller: _sqftController,
            enabled: widget.isEditable,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Total Sqft',
              prefixIcon: const Icon(Icons.square_foot),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (_) => _updateItem(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        // Unit Price
        Expanded(
          child: TextFormField(
            controller: _priceController,
            enabled: widget.isEditable,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Price/Sqft (Rs.)',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (_) => _updateItem(),
          ),
        ),
        const SizedBox(width: 12),
        // Cost
        Expanded(
          child: TextFormField(
            controller: _costController,
            enabled: widget.isEditable,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Cost/Sqft (Rs.)',
              prefixIcon: const Icon(Icons.money_off),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.orange.shade50,
            ),
            onChanged: (_) => _updateItem(),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculatedValues() {
    final amount = widget.item.amount;
    final cost = widget.item.totalCost;
    final profit = widget.item.profit;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildValueItem('Amount', amount, Colors.blue),
          _buildValueItem('Cost', cost, Colors.orange),
          _buildValueItem(
            'Profit',
            profit,
            profit >= 0 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rs. ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: (color as MaterialColor).shade700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
