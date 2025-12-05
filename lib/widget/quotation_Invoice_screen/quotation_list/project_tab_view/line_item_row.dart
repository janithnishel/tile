import 'package:flutter/material.dart';
import 'package:tilework/data/mock_data.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';

class LineItemRow extends StatefulWidget {
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
  State<LineItemRow> createState() => _LineItemRowState();
}

class _LineItemRowState extends State<LineItemRow> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _initControllers();
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

  @override
  void didUpdateWidget(LineItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _updateControllers();
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
      value: masterItemList.contains(widget.item.item) ? widget.item.item : null,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: !widget.isDropdownEditable,
        fillColor: widget.isDropdownEditable ? null : Colors.grey.shade100,
        hintText: 'Select item...',
      ),
      isExpanded: true,
      items: masterItemList
          .map(
            (desc) => DropdownMenuItem(
              value: desc,
              child: Text(
                desc.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: widget.isDropdownEditable
          ? (value) {
              if (value != null) {
                widget.onItemChanged(value);
                setState(() {
                  _priceController.text = value.sellingPrice > 0
                      ? value.sellingPrice.toStringAsFixed(2)
                      : '';
                });
                if (value.name.startsWith('Other')) {
                  widget.onCustomItemTap?.call();
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