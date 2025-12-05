import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';

class EditModeButtonsSection extends StatelessWidget {
  final QuotationDocument document;
  final bool hasUnsavedChanges;
  final VoidCallback onSave;
  final VoidCallback onConvert;
  final VoidCallback onAddAdvance;
  final VoidCallback onRecordPayment;
  final VoidCallback onPreview;
  final VoidCallback onPrint;
  final VoidCallback onDelete;

  const EditModeButtonsSection({
    Key? key,
    required this.document,
    required this.hasUnsavedChanges,
    required this.onSave,
    required this.onConvert,
    required this.onAddAdvance,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Summary Row
          _buildSummaryRow(),

          // Unsaved Changes Warning
          if (hasUnsavedChanges) ...[
            const SizedBox(height: 12),
            _buildUnsavedChangesWarning(),
          ],

          const SizedBox(height: 20),

          // Primary Actions
          _buildPrimaryActionsRow(),
          const SizedBox(height: 16),

          // Secondary Actions
          _buildSecondaryActionsRow(),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subtotal', style: TextStyle(color: Colors.grey.shade600)),
                Text(
                  'Rs ${document.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (document.isInvoice) ...[
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            Expanded(
              child: Column(
                children: [
                  Text('Paid', style: TextStyle(color: Colors.grey.shade600)),
                  Text(
                    'Rs ${document.totalPayments.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Due', style: TextStyle(color: Colors.grey.shade600)),
                  Text(
                    'Rs ${document.amountDue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: document.amountDue > 0
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnsavedChangesWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          const Text(
            'You have unsaved changes',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
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
              onPressed: hasUnsavedChanges ? onSave : null,
              icon: const Icon(Icons.save),
              label: Text('Save ${document.type.name}'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
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
        // Payment Buttons
        else if (_isPaymentVisible)
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAddAdvance,
                    icon: const Icon(Icons.add_card),
                    label: const Text('Add Advance'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRecordPayment,
                    icon: const Icon(Icons.attach_money),
                    label: Text(
                      'Record Payment\n(Due: Rs ${document.amountDue.toStringAsFixed(0)})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
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
