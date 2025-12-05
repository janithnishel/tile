import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';

class CustomItemDialog extends StatefulWidget {
  final InvoiceLineItem item;
  final Function(String?, ItemDescription) onSave;

  const CustomItemDialog({
    Key? key,
    required this.item,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CustomItemDialog> createState() => _CustomItemDialogState();
}

class _CustomItemDialogState extends State<CustomItemDialog> {
  late TextEditingController _descController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(
      text: widget.item.customDescription ?? '',
    );
    _priceController = TextEditingController(
      text: widget.item.item.sellingPrice > 0
          ? widget.item.item.sellingPrice.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Add Custom Item Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Custom Item Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Selling Price (LKR)',
              border: OutlineInputBorder(),
              prefixText: 'Rs ',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newItem = ItemDescription(
              'Other (Custom Item)',
              sellingPrice: double.tryParse(_priceController.text) ?? 0.0,
              unit: widget.item.item.unit,
            );
            widget.onSave(_descController.text.trim(), newItem);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}