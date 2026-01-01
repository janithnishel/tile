import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';

class EditModeButtonsSection extends StatelessWidget {
  final QuotationDocument document;
  final bool hasUnsavedChanges;
  final bool isValid;
  final bool isSaving;
  final bool isNewDocument;
  final VoidCallback onSave;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
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
    this.isValid = false,
    this.isSaving = false,
    this.isNewDocument = false,
    required this.onSave,
    this.onApprove,
    this.onReject,
    required this.onConvert,
    required this.onAddAdvance,
    required this.onRecordPayment,
    required this.onPreview,
    required this.onPrint,
    required this.onDelete,
  }) : super(key: key);

  bool get _isSaveVisible => document.isQuotation && !document.isLocked;

  bool get _isConvertVisible =>
      document.isQuotation && document.status == DocumentStatus.approved && !hasUnsavedChanges;

  bool get _isPaymentVisible =>
      document.isInvoice && !document.isLocked && document.amountDue > 0;

  bool get _isDeleteVisible =>
      document.isQuotation && document.status == DocumentStatus.pending;

  bool get _isApproveVisible =>
      document.isQuotation && document.status == DocumentStatus.pending;

  bool get _isRejectVisible =>
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
            // Additional warning for approved quotations with unsaved changes
            if (document.isQuotation && document.status == DocumentStatus.approved) ...[
              const SizedBox(height: 8),
              _buildSaveBeforeConvertWarning(),
            ],
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

  Widget _buildSaveBeforeConvertWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Save your changes before converting to invoice',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionsRow() {
    // Implement the specific button state logic requested
    final isSaveEnabled = hasUnsavedChanges && !isSaving;
    final isApproveEnabled = !hasUnsavedChanges && document.status == DocumentStatus.pending;
    final isRejectEnabled = !hasUnsavedChanges && document.status == DocumentStatus.pending;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Save Quotation Button
        if (_isSaveVisible)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isSaveEnabled ? onSave : null,
              icon: isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(isSaving ? 'Saving...' : 'Save Quotation'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: isSaveEnabled ? Colors.indigo : Colors.grey.shade300,
                foregroundColor: isSaveEnabled ? Colors.white : Colors.grey.shade600,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
            ),
          ),

        if (_isSaveVisible && (_isApproveVisible || _isRejectVisible)) const SizedBox(width: 16),

        // Approve and Reject Buttons (for pending quotations)
        if (_isApproveVisible || _isRejectVisible)
          Expanded(
            child: Row(
              children: [
                // Approve Button
                if (_isApproveVisible && onApprove != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isApproveEnabled ? onApprove : null,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: isApproveEnabled ? Colors.green.shade600 : Colors.grey.shade300,
                        foregroundColor: isApproveEnabled ? Colors.white : Colors.grey.shade600,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ),

                if (_isApproveVisible && _isRejectVisible && onApprove != null && onReject != null) const SizedBox(width: 12),

                // Reject Button
                if (_isRejectVisible && onReject != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isRejectEnabled ? onReject : null,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: isRejectEnabled ? Colors.red.shade600 : Colors.grey.shade300,
                        foregroundColor: isRejectEnabled ? Colors.white : Colors.grey.shade600,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        if ((_isSaveVisible || _isApproveVisible || _isRejectVisible) && (_isConvertVisible || _isPaymentVisible)) const SizedBox(width: 16),

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

  Widget _buildApproveButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onApprove,
        icon: const Icon(Icons.check_circle),
        label: const Text('Approve Quotation'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
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
