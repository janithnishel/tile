import 'package:flutter/material.dart';
import 'package:tilework/models/job_cost_screen/invoice_item.dart';
import 'package:tilework/utils/job_cost_formatters.dart';

class InvoiceItemRow extends StatefulWidget {
  final InvoiceItem item;
  final int index;
  final Function(double) onCostPriceChanged;

  const InvoiceItemRow({
    Key? key,
    required this.item,
    required this.index,
    required this.onCostPriceChanged,
  }) : super(key: key);

  @override
  State<InvoiceItemRow> createState() => _InvoiceItemRowState();
}

class _InvoiceItemRowState extends State<InvoiceItemRow> {
  late TextEditingController _costPriceController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _costPriceController = TextEditingController(
      text: widget.item.costPrice?.toStringAsFixed(0) ?? '0',
    );
  }

  @override
  void dispose() {
    _costPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.item.hasCostPrice ? Colors.white : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.item.hasCostPrice
              ? Colors.grey.shade200
              : Colors.amber.shade300,
        ),
      ),
      child: Row(
        children: [
          // Item Name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  widget.item.unit,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          // Quantity
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                AppFormatters.formatQuantity(widget.item.quantity),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          // Selling Price
          Expanded(
            flex: 2,
            child: Text(
              AppFormatters.formatCurrency(widget.item.sellingPrice),
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.blue.shade700),
            ),
          ),
          // Cost Price
          Expanded(
            flex: 2,
            child: _isEditing
                ? _buildCostPriceEditor()
                : _buildCostPriceDisplay(),
          ),
          // Profit
          Expanded(
            flex: 2,
            child: Text(
              widget.item.hasCostPrice
                  ? AppFormatters.formatCurrency(widget.item.profit)
                  : '-',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: widget.item.profit >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostPriceDisplay() {
    if (widget.item.hasCostPrice) {
      return InkWell(
        onTap: () => setState(() => _isEditing = true),
        child: Text(
          AppFormatters.formatCurrency(widget.item.costPrice!),
          textAlign: TextAlign.right,
          style: TextStyle(color: Colors.orange.shade700),
        ),
      );
    } else {
      return InkWell(
        onTap: () => setState(() => _isEditing = true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, size: 14, color: Colors.orange),
              SizedBox(width: 4),
              Text(
                'Enter',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildCostPriceEditor() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _costPriceController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.orange.shade700, fontSize: 14),
            decoration: InputDecoration(
              hintText: '0',
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.orange.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.orange.shade500, width: 2),
              ),
            ),
            onSubmitted: _saveCostPrice,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.check, size: 16, color: Colors.green),
          onPressed: _saveCostPrice,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  void _saveCostPrice([String? value]) {
    final text = value ?? _costPriceController.text;
    if (text.isNotEmpty) {
      final price = double.tryParse(text);
      if (price != null && price >= 0) {
        widget.onCostPriceChanged(price);
        setState(() => _isEditing = false);
      }
    } else {
      setState(() => _isEditing = false);
    }
  }
}
