import 'package:flutter/material.dart';

class RecordPaymentDialog extends StatefulWidget {
  final double dueAmount;
  final Function(double) onRecordPayment;

  const RecordPaymentDialog({
    Key? key,
    required this.dueAmount,
    required this.onRecordPayment,
  }) : super(key: key);

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  late TextEditingController _paymentController;

  @override
  void initState() {
    super.initState();
    _paymentController = TextEditingController();
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.payments, color: Colors.green.shade700),
          ),
          const SizedBox(width: 12),
          const Text('Record Final Payment'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount Due:', style: TextStyle(fontSize: 16)),
                  Text(
                    'Rs ${widget.dueAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _paymentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Payment Amount (LKR)',
                border: const OutlineInputBorder(),
                prefixText: 'Rs ',
                hintText: 'Enter amount',
                suffixIcon: TextButton(
                  onPressed: () {
                    _paymentController.text =
                        widget.dueAmount.toStringAsFixed(2);
                  },
                  child: const Text('Full Amount'),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final paymentAmount =
                double.tryParse(_paymentController.text) ?? 0.0;

            if (paymentAmount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid amount.')),
              );
              return;
            }

            widget.onRecordPayment(paymentAmount);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Record Payment'),
        ),
      ],
    );
  }
}