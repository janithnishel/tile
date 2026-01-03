// lib/widget/material_sale/sections/ms_payment_section.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/payment_record.dart';

class MSPaymentSection extends StatelessWidget {
  final double totalAmount;
  final double amountDue;
  final List<PaymentRecord> paymentHistory;
  final bool isEditable;
  final VoidCallback? onAddPayment;
  final VoidCallback? onRecordFinalPayment;

  const MSPaymentSection({
    Key? key,
    required this.totalAmount,
    required this.amountDue,
    required this.paymentHistory,
    this.isEditable = true,
    this.onAddPayment,
    this.onRecordFinalPayment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalPaid = totalAmount - amountDue;
    final hasOutstandingBalance = amountDue > 0; // Amount Due > 0 means payment needed

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
          _buildSectionHeader(!hasOutstandingBalance), // isPaid = !hasOutstandingBalance
          const SizedBox(height: 16),

          // Payment Summary Cards
          _buildPaymentSummary(totalPaid, !hasOutstandingBalance),
          const SizedBox(height: 16),

          // Payment History
          if (paymentHistory.isNotEmpty) ...[
            _buildPaymentHistory(),
            const SizedBox(height: 16),
          ],

          // Action Buttons - Show payment buttons when there's outstanding balance
          // Item editing may be disabled, but payment collection should always be available
          if (hasOutstandingBalance) _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isPaid) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPaid ? Colors.green.shade50 : Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isPaid ? Icons.check_circle_outline : Icons.payment_outlined,
            color: isPaid ? Colors.green.shade600 : Colors.purple.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Payment Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (isPaid)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 14, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text(
                  'PAID',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentSummary(double totalPaid, bool isPaid) {
    return Row(
      children: [
        // Total Amount
        Expanded(
          child: _SummaryCard(
            label: 'Total Amount',
            value: totalAmount,
            color: Colors.blue,
            icon: Icons.receipt_outlined,
          ),
        ),
        const SizedBox(width: 12),
        // Paid Amount
        Expanded(
          child: _SummaryCard(
            label: 'Paid',
            value: totalPaid,
            color: Colors.green,
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 12),
        // Due Amount
        Expanded(
          child: _SummaryCard(
            label: 'Due',
            value: amountDue,
            color: isPaid ? Colors.grey : Colors.red,
            icon: Icons.pending_outlined,
            highlight: !isPaid,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment History',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...paymentHistory.asMap().entries.map((entry) {
          final payment = entry.value;
          return _PaymentHistoryItem(
            index: entry.key + 1,
            payment: payment,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final hasPayments = paymentHistory.isNotEmpty;
    final buttonText = hasPayments ? 'Add Further Payment' : 'Record Payment';
    // Show Record Final Payment button if amountDue > 0 (regardless of status)
    final showDuePayment = amountDue > 0;

    return Column(
      children: [
        // Primary payment button (for new documents)
        if (onAddPayment != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddPayment,
              icon: const Icon(Icons.payment, size: 18),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

        // Due payment button - CRITICAL: Show whenever Amount Due > 0
        // This button must be visible regardless of PENDING/PARTIAL status
        // as long as there's money to be collected (හිඟ මුදල තියෙනවා නම් බට්න් එක පේන්න ඕනේ)
        if (showDuePayment && onRecordFinalPayment != null) ...[
          if (onAddPayment != null) const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRecordFinalPayment,
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('Record Final Payment'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 8),
        // Helper text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  showDuePayment
                      ? 'Add final payment for outstanding balance'
                      : 'Record full payment or advance amount',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================
// SUMMARY CARD
// ============================================

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final MaterialColor color;
  final IconData icon;
  final bool highlight;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? color.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: highlight ? Border.all(color: color.shade200) : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: color.shade400, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs. ${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// PAYMENT HISTORY ITEM
// ============================================

class _PaymentHistoryItem extends StatelessWidget {
  final int index;
  final PaymentRecord payment;

  const _PaymentHistoryItem({
    required this.index,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        children: [
          // Index
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                Text(
                  dateFormat.format(payment.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Text(
            'Rs. ${payment.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
