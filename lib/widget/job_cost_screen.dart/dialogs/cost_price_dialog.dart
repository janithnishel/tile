import 'package:flutter/material.dart';
import 'package:tilework/models/job_cost_screen/invoice_item.dart';

class CostPriceDialog extends StatefulWidget {
  final InvoiceItem item;
  final Function(double) onSave;

  const CostPriceDialog({
    Key? key,
    required this.item,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CostPriceDialog> createState() => _CostPriceDialogState();
}

class _CostPriceDialogState extends State<CostPriceDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.edit, color: Colors.teal.shade600),
          const SizedBox(width: 12),
          const Text('Enter Cost Price'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Selling Price: Rs ${widget.item.sellingPrice.toStringAsFixed(2)}'),
              const SizedBox(width: 16),
              Text('Qty: ${widget.item.quantity.toStringAsFixed(0)} ${widget.item.unit}'),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Cost Price per ${widget.item.unit}',
              prefixText: 'Rs ',
              border: const OutlineInputBorder(),
              helperText: 'Company ගත් මිල ඇතුළත් කරන්න',
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
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    final price = double.tryParse(_controller.text);
    if (price != null) {
      widget.onSave(price);
      Navigator.pop(context);
    }
  }
}