import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/payment_record.dart';

class PaymentHistorySection extends StatelessWidget {
  final List<PaymentRecord> payments;
  final double amountDue;
  final bool canAddAdvance;
  final VoidCallback? onAddAdvance;

  const PaymentHistorySection({
    Key? key,
    required this.payments,
    required this.amountDue,
    this.canAddAdvance = false,
    this.onAddAdvance,
  }) : super(key: key);

  double get _totalPaid =>
      payments.fold<double>(0, (sum, p) => sum + p.amount);

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Payment History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              if (canAddAdvance && amountDue > 0)
                TextButton.icon(
                  onPressed: onAddAdvance,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Advance'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                  ),
                ),
            ],
          ),
          const Divider(),

          // Payments List
          ...payments.asMap().entries.map((entry) {
            final index = entry.key;
            final payment = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.green.shade100,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.description ?? 'Payment',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            DateFormat('d MMM yyyy, h:mm a').format(payment.date),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    'Rs ${payment.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(),

          // Total Paid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Paid:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Rs ${_totalPaid.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),

          // Remaining Due
          if (amountDue > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining Due:',
                  style: TextStyle(color: Colors.red.shade700),
                ),
                Text(
                  'Rs ${amountDue.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}