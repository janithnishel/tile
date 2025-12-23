// lib/widget/material_sale/dialogs/ms_payment_dialog.dart

import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/payment_record.dart';

class MSPaymentDialog extends StatefulWidget {
  final double totalAmount;
  final double amountDue;
  final Function(PaymentRecord, bool) onPaymentRecorded; // bool indicates if full payment

  const MSPaymentDialog({
    Key? key,
    required this.totalAmount,
    required this.amountDue,
    required this.onPaymentRecorded,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required double totalAmount,
    required double amountDue,
    required Function(PaymentRecord, bool) onPaymentRecorded,
  }) {
    return showDialog(
      context: context,
      builder: (context) => MSPaymentDialog(
        totalAmount: totalAmount,
        amountDue: amountDue,
        onPaymentRecorded: onPaymentRecorded,
      ),
    );
  }

  @override
  State<MSPaymentDialog> createState() => _MSPaymentDialogState();
}

class _MSPaymentDialogState extends State<MSPaymentDialog> with TickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _paymentMethod = 'Cash';

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
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _updateForTab(0); // Full Payment tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _updateForTab(_tabController.index);
    }
  }

  void _updateForTab(int index) {
    setState(() {
      if (index == 0) {
        // Full Payment
        _amountController.text = widget.amountDue.toStringAsFixed(0);
        _descriptionController.text = 'Full Payment';
      } else {
        // Advance Payment
        _amountController.text = '';
        _descriptionController.text = 'Advance Payment';
      }
    });
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

    final isFullPayment = _tabController.index == 0;

    if (isFullPayment && amount != widget.amountDue) {
      _showError('Full payment must equal the total due amount');
      return;
    }

    if (!isFullPayment && amount >= widget.amountDue) {
      _showError('Advance payment must be less than the total due amount');
      return;
    }

    final description = '${_descriptionController.text} - $_paymentMethod';

    final payment = PaymentRecord(
      amount,
      DateTime.now(),
      description: description,
    );

    widget.onPaymentRecorded(payment, isFullPayment);
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

            // Tab Bar
            _buildTabBar(),
            const SizedBox(height: 20),

            // Due Amount Display
            _buildDueAmountCard(),
            const SizedBox(height: 20),

            // Tab Bar View
            SizedBox(
              height: 300, // Fixed height for tab content
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFullPaymentTab(),
                  _buildAdvancePaymentTab(),
                ],
              ),
            ),

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
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.payment,
            color: Colors.blue,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record Payment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Choose payment type and amount',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
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

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(
            text: 'Full Payment',
            icon: Icon(Icons.check_circle_outline, size: 18),
          ),
          Tab(
            text: 'Advance Payment',
            icon: Icon(Icons.payments_outlined, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildFullPaymentTab() {
    final remainingBalance = 0.0; // Full payment, no remaining

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Amount (auto-filled)
          _buildAmountInput(enabled: false),
          const SizedBox(height: 16),

          // Payment Method
          _buildPaymentMethodDropdown(),
          const SizedBox(height: 16),

          // Description
          _buildDescriptionInput(),
          const SizedBox(height: 16),

          // Status Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Invoice will be marked as PAID',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancePaymentTab() {
    final currentAmount = double.tryParse(_amountController.text) ?? 0;
    final remainingBalance = widget.amountDue - currentAmount;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Amount
          _buildAmountInput(enabled: true),
          const SizedBox(height: 16),

          // Payment Method
          _buildPaymentMethodDropdown(),
          const SizedBox(height: 16),

          // Description
          _buildDescriptionInput(),
          const SizedBox(height: 16),

          // Remaining Balance
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.pending, color: Colors.orange.shade600, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Remaining Balance',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs. ${remainingBalance.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Status Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Invoice will remain PENDING',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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



  Widget _buildAmountInput({bool enabled = true}) {
    return TextFormField(
      controller: _amountController,
      enabled: enabled,
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
      onChanged: (value) {
        if (_tabController.index == 1) { // Advance Payment tab
          setState(() {}); // Trigger rebuild to update remaining balance
        }
      },
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
            label: const Text('Record Payment'),
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
      ],
    );
  }
}
