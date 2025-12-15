import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';

class CreateModeButtonsSection extends StatelessWidget {
  final QuotationDocument document;
  final bool isValid;
  final String? customerName;
  final String? customerPhone;
  final VoidCallback onCancel;
  final VoidCallback onCreateQuotation;
  final String? Function(String?)? phoneValidator;

  const CreateModeButtonsSection({
    Key? key,
    required this.document,
    required this.isValid,
    this.customerName,
    this.customerPhone,
    this.phoneValidator,
    required this.onCancel,
    required this.onCreateQuotation,
  }) : super(key: key);

  bool get _hasCustomerName =>
      customerName != null && customerName!.trim().isNotEmpty;

  bool get _hasValidPhone {
    if (customerPhone == null || customerPhone!.trim().isEmpty) return false;
    if (phoneValidator != null) {
      return phoneValidator!(customerPhone) == null;
    }
    return true;
  }

  bool get _hasValidItems =>
      document.lineItems.any((item) => item.quantity > 0);

  String? get _phoneValidationError {
    if (customerPhone != null && customerPhone!.trim().isNotEmpty && phoneValidator != null) {
      return phoneValidator!(customerPhone);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.shade100),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quotation Total:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Rs ${document.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Items:', style: TextStyle(color: Colors.grey.shade600)),
                    Text(
                      '${document.lineItems.where((i) => i.quantity > 0).length} item(s)',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Validation Messages
          if (!isValid)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Please complete the following:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        if (!_hasCustomerName) const Text('• Enter customer name'),
                        if (!_hasValidPhone) ...[
                          if (_phoneValidationError != null)
                            Text('• ${_phoneValidationError}')
                          else
                            const Text('• Enter valid customer phone'),
                        ],
                        if (!_hasValidItems)
                          const Text('• Add at least one item with quantity'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: isValid ? onCreateQuotation : null,
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    'Create Quotation',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
