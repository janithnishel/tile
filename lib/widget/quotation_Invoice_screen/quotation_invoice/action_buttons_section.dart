import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';

class ActionButtonsSection extends StatelessWidget {
  final QuotationDocument document;
  final VoidCallback onSave;
  final VoidCallback onConvert;
  final VoidCallback onRecordPayment;
  final VoidCallback onPreview;
  final VoidCallback onPrint;
  final VoidCallback onDelete;

  const ActionButtonsSection({
    Key? key,
    required this.document,
    required this.onSave,
    required this.onConvert,
    required this.onRecordPayment,
    required this.onPreview,
    required this.onPrint,
    required this.onDelete,
  }) : super(key: key);

  bool get _isSaveVisible => !document.isLocked;

  bool get _isConvertVisible =>
      document.isQuotation && document.status == DocumentStatus.approved;

  bool get _isPaymentVisible =>
      document.isInvoice && !document.isLocked && document.amountDue > 0;

  bool get _isDeleteVisible =>
      document.isQuotation && document.status == DocumentStatus.pending;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Save, Convert/Payment
        _buildPrimaryActionsRow(),
        const SizedBox(height: 16),

        // Row 2: Preview, Print, Delete
        _buildSecondaryActionsRow(),
      ],
    );
  }

  Widget _buildPrimaryActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Save Button
        if (_isSaveVisible)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save),
              label: Text('Save ${document.type.name}'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ),

        if (_isSaveVisible) const SizedBox(width: 16),

        // Convert Button
        if (_isConvertVisible)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onConvert,
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Convert to Invoice'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          )
        // Payment Button
        else if (_isPaymentVisible)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onRecordPayment,
              icon: const Icon(Icons.attach_money),
              label: Text(
                'Record Payment (Due: Rs ${document.amountDue.toStringAsFixed(2)})',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          )
        else
          const Expanded(child: SizedBox.shrink()),
      ],
    );
  }

  Widget _buildSecondaryActionsRow() {
    return Row(
      children: [
        // Preview Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPreview,
            icon: const Icon(Icons.preview),
            label: const Text('Preview'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Print Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPrint,
            icon: const Icon(Icons.print),
            label: const Text('Print'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Delete Button
        if (_isDeleteVisible)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          )
        else
          const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}