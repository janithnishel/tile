import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/payment_record.dart';

class ConvertToInvoiceDialog extends StatefulWidget {
  final double quotationTotal;
  final Function(List<PaymentRecord>, {DateTime? customDueDate}) onConvert;

  const ConvertToInvoiceDialog({
    Key? key,
    required this.quotationTotal,
    required this.onConvert,
  }) : super(key: key);

  @override
  State<ConvertToInvoiceDialog> createState() => _ConvertToInvoiceDialogState();
}

class _ConvertToInvoiceDialogState extends State<ConvertToInvoiceDialog> {
  final List<_AdvancePaymentEntry> _advancePayments = [];

  double get _totalAdvance =>
      _advancePayments.fold(0.0, (sum, p) => sum + (p.amount ?? 0));

  double get _remainingDue => widget.quotationTotal - _totalAdvance;

  void _addNewPaymentEntry() {
    setState(() {
      _advancePayments.add(_AdvancePaymentEntry());
    });
  }

  void _removePaymentEntry(int index) {
    setState(() {
      _advancePayments[index].dispose();
      _advancePayments.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var entry in _advancePayments) {
      entry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card
                    _buildSummaryCard(),
                    const SizedBox(height: 24),

                    // Advance Payments Section
                    _buildAdvancePaymentsSection(),
                  ],
                ),
              ),
            ),

            // Footer
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
          colors: [Colors.purple.shade600, Colors.purple.shade800],
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
            child: const Icon(Icons.transform, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Convert to Invoice',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Add advance payments if received',
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

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quotation Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                'Rs ${widget.quotationTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          if (_advancePayments.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.payments, size: 18, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    const Text('Total Advance'),
                  ],
                ),
                Text(
                  'Rs ${_totalAdvance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 18,
                      color: _remainingDue > 0
                          ? Colors.orange.shade600
                          : Colors.green.shade600,
                    ),
                    const SizedBox(width: 8),
                    const Text('Remaining Due'),
                  ],
                ),
                Text(
                  'Rs ${_remainingDue.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _remainingDue > 0
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }



  Widget _buildAdvancePaymentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.add_card, color: Colors.teal.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Advance Payments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: _addNewPaymentEntry,
              icon: const Icon(Icons.add_circle, size: 20),
              label: const Text('Add Payment'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_advancePayments.isEmpty)
          _buildEmptyPaymentsState()
        else
          ..._advancePayments.asMap().entries.map((entry) {
            return _buildPaymentCard(entry.key, entry.value);
          }),
      ],
    );
  }

  Widget _buildEmptyPaymentsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.payments_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No advance payments added',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Click "Add Payment" to record advance payments',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(int index, _AdvancePaymentEntry payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Advance Payment ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _removePaymentEntry(index),
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                tooltip: 'Remove payment',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Amount & Date Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: payment.amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (LKR)',
                    hintText: 'Enter amount',
                    prefixText: 'Rs ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onChanged: (value) {
                    setState(() {
                      payment.amount = double.tryParse(value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: payment.date ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2050),
                    );
                    if (pickedDate != null) {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          payment.date ?? DateTime.now(),
                        ),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          payment.date = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date & Time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.teal.shade600,
                      ),
                    ),
                    child: Text(
                      payment.date != null
                          ? '${payment.date!.day}/${payment.date!.month}/${payment.date!.year} ${payment.date!.hour}:${payment.date!.minute.toString().padLeft(2, '0')}'
                          : 'Select date & time',
                      style: TextStyle(
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
          const SizedBox(height: 12),

          // Note Field
          TextField(
            controller: payment.noteController,
            decoration: InputDecoration(
              labelText: 'Note (Optional)',
              hintText: 'e.g., Bank Transfer, Cash, Check No...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: const Icon(Icons.note),
            ),
            onChanged: (value) {
              payment.note = value;
            },
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
              onPressed: () {
                final payments = _advancePayments
                    .where((p) => p.amount != null && p.amount! > 0)
                    .map((p) => PaymentRecord(
                          p.amount!,
                          p.date ?? DateTime.now(),
                          description:
                              'Advanced Payment on Conversion${p.note?.isNotEmpty == true ? ' - ${p.note}' : ''}',
                        ))
                    .toList();

                widget.onConvert(payments, customDueDate: null);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text(
                'Convert & Create Invoice',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancePaymentEntry {
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
