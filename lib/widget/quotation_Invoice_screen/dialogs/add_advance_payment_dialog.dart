import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/payment_record.dart';

class AddAdvancePaymentDialog extends StatefulWidget {
  final double currentDue;
  final Function(List<PaymentRecord>) onAddPayments;

  const AddAdvancePaymentDialog({
    Key? key,
    required this.currentDue,
    required this.onAddPayments,
  }) : super(key: key);

  @override
  State<AddAdvancePaymentDialog> createState() =>
      _AddAdvancePaymentDialogState();
}

class _AddAdvancePaymentDialogState extends State<AddAdvancePaymentDialog> {
  final List<_PaymentEntry> _payments = [];

  double get _totalPayments =>
      _payments.fold(0.0, (sum, p) => sum + (p.amount ?? 0));

  double get _remainingAfter => widget.currentDue - _totalPayments;

  @override
  void initState() {
    super.initState();
    _payments.add(_PaymentEntry());
  }

  @override
  void dispose() {
    for (var entry in _payments) {
      entry.dispose();
    }
    super.dispose();
  }

  void _addPayment() {
    setState(() {
      _payments.add(_PaymentEntry());
    });
  }

  void _removePayment(int index) {
    if (_payments.length > 1) {
      setState(() {
        _payments[index].dispose();
        _payments.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDueCard(),
                    if (_totalPayments > 0) _buildRemainingCard(),
                    const SizedBox(height: 20),
                    _buildPaymentsHeader(),
                    const SizedBox(height: 12),
                    ..._payments.asMap().entries.map(
                          (e) => _buildPaymentCard(e.key, e.value),
                        ),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade500, Colors.teal.shade700],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add_card, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Advance Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Record advance payments received',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.red.shade600),
              const SizedBox(width: 12),
              const Text(
                'Current Due Amount',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Text(
            'Rs ${widget.currentDue.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingCard() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            _remainingAfter > 0 ? Colors.orange.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _remainingAfter > 0
              ? Colors.orange.shade200
              : Colors.green.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('After this payment:'),
          Text(
            'Rs ${_remainingAfter.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _remainingAfter > 0
                  ? Colors.orange.shade700
                  : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Payment Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        TextButton.icon(
          onPressed: _addPayment,
          icon: const Icon(Icons.add_circle, size: 18),
          label: const Text('Add More'),
          style: TextButton.styleFrom(foregroundColor: Colors.teal.shade600),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(int index, _PaymentEntry payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.teal.shade100,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('Payment ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              if (_payments.length > 1)
                IconButton(
                  onPressed: () => _removePayment(index),
                  icon: Icon(Icons.remove_circle,
                      color: Colors.red.shade400, size: 20),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: payment.amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter amount',
                    prefixText: 'Rs ',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      payment.amount = double.tryParse(value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: payment.date ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2050),
                    );
                    if (picked != null) {
                      setState(() => payment.date = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      isDense: true,
                      suffixIcon: Icon(Icons.calendar_today,
                          size: 18, color: Colors.teal.shade600),
                    ),
                    child: Text(
                      payment.date != null
                          ? '${payment.date!.day}/${payment.date!.month}/${payment.date!.year}'
                          : 'Select',
                      style: TextStyle(
                        fontSize: 13,
                        color: payment.date != null
                            ? Colors.black87
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: payment.noteController,
            decoration: InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'e.g., Cash, Bank...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            onChanged: (value) => payment.note = value,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _totalPayments > 0
                  ? () {
                      final validPayments = _payments
                          .where((p) => p.amount != null && p.amount! > 0)
                          .map((p) => PaymentRecord(
                                p.amount!,
                                p.date ?? DateTime.now(),
                                description:
                                    'Advance Payment${p.note?.isNotEmpty == true ? ' - ${p.note}' : ''}',
                              ))
                          .toList();
                      widget.onAddPayments(validPayments);
                      Navigator.pop(context);
                    }
                  : null,
              icon: const Icon(Icons.check),
              label: Text(
                'Add Payment${_payments.length > 1 ? 's' : ''}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentEntry {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  double? amount;
  DateTime? date;
  String? note;

  void dispose() {
    amountController.dispose();
    noteController.dispose();
  }
}