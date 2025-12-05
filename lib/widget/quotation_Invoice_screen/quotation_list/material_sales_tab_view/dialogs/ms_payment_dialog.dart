// lib/widget/material_sale/dialogs/ms_payment_dialog.dart

import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/payment_record.dart';

class MSPaymentDialog extends StatefulWidget {
  final double amountDue;
  final bool isAdvance;
  final Function(PaymentRecord) onPaymentRecorded;

  const MSPaymentDialog({
    Key? key,
    required this.amountDue,
    this.isAdvance = false,
    required this.onPaymentRecorded,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required double amountDue,
    bool isAdvance = false,
    required Function(PaymentRecord) onPaymentRecorded,
  }) {
    return showDialog(
      context: context,
      builder: (context) => MSPaymentDialog(
        amountDue: amountDue,
        isAdvance: isAdvance,
        onPaymentRecorded: onPaymentRecorded,
      ),
    );
  }

  @override
  State<MSPaymentDialog> createState() => _MSPaymentDialogState();
}

class _MSPaymentDialogState extends State<MSPaymentDialog> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _paymentMethod = 'Cash';
  bool _payFullAmount = true;

  final List<String> _paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Card',
    'Cheque',
    'Online',
  ];

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.amountDue.toStringAsFixed(0);
    _descriptionController.text = widget.isAdvance
        ? 'Advance Payment'
        : 'Full Payment';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _recordPayment() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    
    if (amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (amount > widget.amountDue) {
      _showError('Amount cannot exceed due amount');
      return;
    }

    final description = '${_descriptionController.text} - $_paymentMethod';
    
    final payment = PaymentRecord(
      amount,
      DateTime.now(),
      description: description,
    );

    widget.onPaymentRecorded(payment);
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Due Amount Display
            _buildDueAmountCard(),
            const SizedBox(height: 20),

            // Full/Partial Toggle
            if (!widget.isAdvance) _buildPaymentTypeToggle(),
            const SizedBox(height: 16),

            // Amount Input
            _buildAmountInput(),
            const SizedBox(height: 16),

            // Payment Method
            _buildPaymentMethodDropdown(),
            const SizedBox(height: 16),

            // Description
            _buildDescriptionInput(),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isAdvance
                ? Colors.purple.shade50
                : Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.isAdvance ? Icons.payments_outlined : Icons.check_circle_outline,
            color: widget.isAdvance
                ? Colors.purple.shade600
                : Colors.green.shade600,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isAdvance ? 'Add Advance Payment' : 'Record Payment',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.isAdvance
                    ? 'Record partial advance'
                    : 'Record full or partial payment',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildDueAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Amount Due',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs. ${widget.amountDue.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: _ToggleButton(
            label: 'Full Payment',
            isSelected: _payFullAmount,
            onTap: () {
              setState(() {
                _payFullAmount = true;
                _amountController.text = widget.amountDue.toStringAsFixed(0);
                _descriptionController.text = 'Full Payment';
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ToggleButton(
            label: 'Partial Payment',
            isSelected: !_payFullAmount,
            onTap: () {
              setState(() {
                _payFullAmount = false;
                _amountController.text = '';
                _descriptionController.text = 'Partial Payment';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: _amountController,
      enabled: !_payFullAmount || widget.isAdvance,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: 'Payment Amount',
        prefixText: 'Rs. ',
        prefixIcon: const Icon(Icons.attach_money),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField<String>(
      value: _paymentMethod,
      decoration: InputDecoration(
        labelText: 'Payment Method',
        prefixIcon: const Icon(Icons.payment),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: _paymentMethods.map((method) {
        return DropdownMenuItem(
          value: method,
          child: Text(method),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _paymentMethod = value!;
        });
      },
    );
  }

  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        prefixIcon: const Icon(Icons.note_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _recordPayment,
            icon: const Icon(Icons.check),
            label: Text(widget.isAdvance ? 'Add Advance' : 'Record Payment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isAdvance
                  ? Colors.purple.shade600
                  : Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// TOGGLE BUTTON
// ============================================

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.green.shade400 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}