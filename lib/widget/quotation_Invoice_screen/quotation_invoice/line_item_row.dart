import 'package:flutter/material.dart';
import 'package:tilework/data/mock_data.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';

class LineItemRow extends StatelessWidget {
  final int index;
  final InvoiceLineItem item;
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Item Dropdown
          Expanded(
            flex: 3,
            child: _buildItemDropdown(),
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

  Widget _buildItemDropdown() {
    return DropdownButtonFormField<ItemDescription>(
      value: item.item,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !isDropdownEditable,
        fillColor: isDropdownEditable ? null : Colors.grey.shade100,
      ),
      items: masterItemList
          .map(
            (desc) => DropdownMenuItem(
              value: desc,
              child: Text(desc.name),
            ),
          )
          .toList(),
      onChanged: isDropdownEditable
          ? (value) {
              if (value != null) {
                onItemChanged(value);
                if (value.name.startsWith('Other')) {
                  onCustomItemTap?.call();
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
        child: Text(item.item.unit),
      ),
    );
  }

  Widget _buildQuantityField() {
    return TextField(
      controller: TextEditingController(text: item.quantity.toStringAsFixed(1)),
      keyboardType: TextInputType.number,
      readOnly: !isValueEditable,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !isValueEditable,
        fillColor: isValueEditable ? null : Colors.grey.shade100,
      ),
      onChanged: (value) {
        if (isValueEditable) {
          onQuantityChanged(double.tryParse(value) ?? 0.0);
        }
      },
    );
  }

  Widget _buildPriceField() {
    return TextField(
      controller: TextEditingController(
        text: item.item.sellingPrice.toStringAsFixed(2),
      ),
      keyboardType: TextInputType.number,
      readOnly: !isValueEditable,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !isValueEditable,
        fillColor: isValueEditable ? null : Colors.grey.shade100,
      ),
      onChanged: (value) {
        if (isValueEditable) {
          onPriceChanged(double.tryParse(value) ?? 0.0);
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
      child: Text(item.amount.toStringAsFixed(2)),
    );
  }

  Widget _buildDeleteButton() {
    if (isDeleteEnabled) {
      return SizedBox(
        width: 40,
        child: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      );
    }
    return const SizedBox(width: 40);
  }
}