import 'package:flutter/material.dart';
import 'package:tilework/data/mock_data.dart';
import 'package:tilework/models/category_model.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';

class LineItemRow extends StatefulWidget {
  final int index;
  final InvoiceLineItem item;
  final List<CategoryModel> categories;
  final bool isDropdownEditable;
  final bool isValueEditable;
  final bool isDeleteEnabled;
  final Function(ItemDescription) onItemChanged;
  final Function(double) onQuantityChanged;
  final Function(double) onPriceChanged;
  final VoidCallback onDelete;
  final VoidCallback? onCustomItemTap;

  const LineItemRow({
    Key? key,
    required this.index,
    required this.item,
    required this.categories,
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
  State<LineItemRow> createState() => _LineItemRowState();
}

class _LineItemRowState extends State<LineItemRow> {
  CategoryModel? selectedCategory;

  @override
  void initState() {
    super.initState();
    // Find the selected category based on the item's categoryId
    if (widget.item.item.categoryId.isNotEmpty) {
      selectedCategory = widget.categories.firstWhere(
        (cat) => cat.id == widget.item.item.categoryId,
        orElse: () => widget.categories.first,
      );
    } else {
      selectedCategory = widget.categories.isNotEmpty ? widget.categories.first : null;
    }
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

          // Product Dropdown
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
    return DropdownButtonFormField<CategoryModel>(
      value: selectedCategory,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !widget.isDropdownEditable,
        fillColor: widget.isDropdownEditable ? null : Colors.grey.shade100,
      ),
      items: widget.categories
          .map(
            (cat) => DropdownMenuItem(
              value: cat,
              child: Text(cat.name),
            ),
          )
          .toList(),
      onChanged: widget.isDropdownEditable
          ? (value) {
              if (value != null) {
                setState(() {
                  selectedCategory = value;
                });
              }
            }
          : null,
    );
  }

  Widget _buildProductDropdown() {
    final products = selectedCategory?.items ?? [];
    return DropdownButtonFormField<ItemModel>(
      value: products.isNotEmpty
          ? products.firstWhere(
              (item) => item.itemName == widget.item.item.productName,
              orElse: () => products.first,
            )
          : null,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !widget.isDropdownEditable,
        fillColor: widget.isDropdownEditable ? null : Colors.grey.shade100,
      ),
      items: products
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item.itemName),
            ),
          )
          .toList(),
      onChanged: widget.isDropdownEditable
          ? (value) {
              if (value != null && selectedCategory != null) {
                final itemDesc = ItemDescription(
                  '${selectedCategory!.name} - ${value.itemName}',
                  sellingPrice: 0.0, // Default price
                  unit: value.baseUnit,
                  category: selectedCategory!.name,
                  categoryId: selectedCategory!.id,
                  productName: value.itemName,
                );
                widget.onItemChanged(itemDesc);
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
        child: Text(widget.item.item.unit),
      ),
    );
  }

  Widget _buildQuantityField() {
    return TextField(
      controller: TextEditingController(text: widget.item.quantity.toStringAsFixed(1)),
      keyboardType: TextInputType.number,
      readOnly: !widget.isValueEditable,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !widget.isValueEditable,
        fillColor: widget.isValueEditable ? null : Colors.grey.shade100,
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
      controller: TextEditingController(
        text: widget.item.item.sellingPrice.toStringAsFixed(2),
      ),
      keyboardType: TextInputType.number,
      readOnly: !widget.isValueEditable,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !widget.isValueEditable,
        fillColor: widget.isValueEditable ? null : Colors.grey.shade100,
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
      child: Text(widget.item.amount.toStringAsFixed(2)),
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
