import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/quotation/quotation_cubit.dart';
import 'package:tilework/data/mock_data.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/payment_record.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice/activity_breakdown_section.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice/create_mode_button.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice/customer_details_section.dart';
// import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice/document_details_section.dart'; // 💡 DocumentDetailsSection වෙත වෙනස්කම් නොකරන නිසා import එක එලෙසම තබන්න
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice/document_details_section.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice/edit_mode_buttons_section.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice/payment_history_section.dart';

// Dialogs
import 'package:tilework/widget/quotation_Invoice_screen/dialogs/document_preview_dialog.dart';
import 'package:tilework/widget/quotation_Invoice_screen/dialogs/convert_to_invoice_dialog.dart';
import 'package:tilework/widget/quotation_Invoice_screen/dialogs/add_advance_payment_dialog.dart';
import 'package:tilework/widget/quotation_Invoice_screen/dialogs/record_payment_dialog.dart';
import 'package:tilework/widget/quotation_Invoice_screen/dialogs/custom_item_dialog.dart';
import 'package:tilework/widget/quotation_Invoice_screen/dialogs/delete_confirmation_dialog.dart';
import 'package:tilework/widget/quotation_Invoice_screen/dialogs/discard_changes_dialog.dart';

class QuotationInvoiceScreen extends StatefulWidget {
  final QuotationDocument document;
  final bool isNewDocument;

  const QuotationInvoiceScreen({
    super.key,
    required this.document,
    this.isNewDocument = false,
  });

  @override
  State<QuotationInvoiceScreen> createState() => _QuotationInvoiceScreenState();
}

class _QuotationInvoiceScreenState extends State<QuotationInvoiceScreen> {
  late final TextEditingController _customerNameController;
  late final TextEditingController _customerPhoneController;
  late final TextEditingController _customerAddressController;
  late final TextEditingController _projectTitleController;

  // Working copy of the document (for edit protection)
  late QuotationDocument _workingDocument;
  late bool _isNewDocument;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _isNewDocument = widget.isNewDocument;

    // Create a DEEP COPY of the document for editing
    _workingDocument = _deepCopyDocument(widget.document);

    _customerNameController = TextEditingController(
      text: _workingDocument.customerName,
    );
    _customerPhoneController = TextEditingController(
      text: _workingDocument.customerPhone,
    );
    _customerAddressController = TextEditingController(
      text: _workingDocument.customerAddress,
    );
    _projectTitleController = TextEditingController(
      text: _workingDocument.projectTitle,
    );

    // Listen for changes
    _customerNameController.addListener(_markAsChanged);
    _customerPhoneController.addListener(_markAsChanged);
    _customerAddressController.addListener(_markAsChanged);
    _projectTitleController.addListener(_markAsChanged);
  }

  // Deep copy document to prevent direct modifications
  QuotationDocument _deepCopyDocument(QuotationDocument original) {
    return QuotationDocument(
      documentNumber: original.documentNumber,
      customerName: original.customerName,
      customerPhone: original.customerPhone,
      customerAddress: original.customerAddress,
      projectTitle: original.projectTitle,
      invoiceDate: original.invoiceDate,
      dueDate: original.dueDate,
      lineItems: original.lineItems
          .map(
            (item) => InvoiceLineItem(
              item: ItemDescription(
                item.item.name,
                // 💡 Fix: Deep copy ItemDescription fields, especially CostPrice, if required by backend
                sellingPrice: item.item.sellingPrice,
                unit: item.item.unit,
                // costPrice: item.item.costPrice, // Assuming you added costPrice to ItemDescription
              ),
              quantity: item.quantity,
              customDescription: item.customDescription,
              isOriginalQuotationItem: item.isOriginalQuotationItem,
            ),
          )
          .toList(),
      paymentHistory: original.paymentHistory
          .map(
            (p) => PaymentRecord(p.amount, p.date, description: p.description),
          )
          .toList(),
      type: original.type,
      status: original.status,
    );
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _customerNameController.removeListener(_markAsChanged);
    _customerPhoneController.removeListener(_markAsChanged);
    _customerAddressController.removeListener(_markAsChanged);
    _projectTitleController.removeListener(_markAsChanged);

    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _projectTitleController.dispose();
    super.dispose();
  }

  // Computed Properties
  bool get _isCustomerDetailsEditable =>
      _isNewDocument ||
      (!_workingDocument.isLocked &&
          (_workingDocument.status == DocumentStatus.pending ||
              _workingDocument.isInvoice));

  bool get _isPendingQuotation =>
      _workingDocument.isQuotation &&
      _workingDocument.status == DocumentStatus.pending;

  bool get _isValidForCreation {
    return _customerNameController.text.trim().isNotEmpty &&
        _customerPhoneController.text.trim().isNotEmpty &&
        _workingDocument.lineItems.any((item) => item.quantity > 0.0);
  }

  // Handle back button with unsaved changes warning
  Future<bool> _onWillPop() async {
    if (_isNewDocument) {
      return await DiscardChangesDialog.show(
        context,
        title: 'Discard New Quotation?',
        message:
            'You have not created this quotation yet. Discard all entered data?',
      );
    }

    if (_hasUnsavedChanges) {
      return await DiscardChangesDialog.show(
        context,
        title: 'Unsaved Changes',
        message:
            'You have unsaved changes. Are you sure you want to go back without saving?',
      );
    }

    return true;
  }

  // ============================================
  // ACTIONS
  // ============================================

  void _searchCustomerByPhone() {
    final phone = _customerPhoneController.text.trim();
    if (phone.isEmpty) {
      _showSnackBar('Please enter a phone number to search.');
      return;
    }

    // ⚠️ Mock Data Logic - Ensure mock data logic handles empty documentNumber correctly if used for new docs
    final existingDoc = mockDocuments.firstWhere(
      (doc) =>
          doc.customerPhone == phone &&
          doc.documentNumber != _workingDocument.documentNumber,
      orElse: () => QuotationDocument(
        documentNumber: '',
        customerName: '',
        invoiceDate: DateTime.now(),
        dueDate: DateTime.now(),
      ),
    );

    if (existingDoc.customerPhone.isNotEmpty) {
      setState(() {
        _customerNameController.text = existingDoc.customerName;
        _customerAddressController.text = existingDoc.customerAddress;
        _projectTitleController.text = existingDoc.projectTitle;
      });
      _showSnackBar('Customer found: ${existingDoc.customerName}');
    } else {
      _showSnackBar('Customer not found. Please enter new details.');
    }
  }

  void _addNewLineItem() {
    // Create a new item with all required fields including category
    final defaultItem = ItemDescription(
      'New Item',
      sellingPrice: 0.0,
      unit: 'units',
      category: 'Custom', // Required category field
      productName: 'Custom Item',
    );

    setState(() {
      _workingDocument.lineItems.add(
        InvoiceLineItem(
          item: defaultItem,
          quantity: 0.0,
          isOriginalQuotationItem:
              _workingDocument.isQuotation &&
              _workingDocument.status == DocumentStatus.pending,
        ),
      );
      _hasUnsavedChanges = true;
    });
  }

  void _showCustomItemDialog(InvoiceLineItem item) {
    showDialog(
      context: context,
      builder: (context) => CustomItemDialog(
        item: item,
        onSave: (description, newItem) {
          setState(() {
            item.customDescription = description;
            item.item = newItem;
            _hasUnsavedChanges = true;
          });
        },
      ),
    );
  }

  // Create Quotation (for new documents)
  Future<void> _createQuotation() async {
    if (_customerNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter customer name.');
      return;
    }

    if (_customerPhoneController.text.trim().isEmpty) {
      _showSnackBar('Please enter customer phone number.');
      return;
    }

    final hasValidItems = _workingDocument.lineItems.any(
      (item) => item.quantity > 0.0,
    );
    if (!hasValidItems) {
      _showSnackBar('Please add at least one item with quantity.');
      return;
    }

    // Update working document with form data
    _workingDocument.customerName = _customerNameController.text.trim();
    _workingDocument.customerPhone = _customerPhoneController.text.trim();
    _workingDocument.customerAddress = _customerAddressController.text.trim();
    _workingDocument.projectTitle = _projectTitleController.text.trim();

    try {
      // Create quotation using the cubit (calls backend API)
      await context.read<QuotationCubit>().createQuotation(_workingDocument);

      // 💡 Note: The created document in the cubit state will now have the ID
      _showSnackBar('Quotation created successfully!');

      // Pop the screen and pass 'true' to indicate a successful creation that requires a list refresh
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Failed to create quotation: ${e.toString()}');
    }
  }

  // Save Document (for existing documents)
  void _saveDocument() {
    // Copy all changes from working document to original
    widget.document.customerName = _customerNameController.text.trim();
    widget.document.customerPhone = _customerPhoneController.text.trim();
    widget.document.customerAddress = _customerAddressController.text.trim();
    widget.document.projectTitle = _projectTitleController.text.trim();
    widget.document.invoiceDate = _workingDocument.invoiceDate;
    widget.document.dueDate = _workingDocument.dueDate;
    widget.document.lineItems = _workingDocument.lineItems;
    widget.document.paymentHistory = _workingDocument.paymentHistory;
    widget.document.type = _workingDocument.type;
    widget.document.status = _workingDocument.status;

    setState(() {
      _hasUnsavedChanges = false;
    });

    _showSnackBar(
      '${_workingDocument.type.name.toUpperCase()} ${_workingDocument.displayDocumentNumber} Saved.',
    );
  }

  // Show Convert to Invoice Dialog
  void _showConversionDialog() {
    if (_workingDocument.status != DocumentStatus.approved) {
      _showSnackBar('Quotation must be Approved before conversion.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ConvertToInvoiceDialog(
        quotationTotal: _workingDocument.subtotal,
        onConvert: (List<PaymentRecord> advancePayments) {
          setState(() {
            _workingDocument.type = DocumentType.invoice;
            _workingDocument.status = DocumentStatus.converted;

            if (advancePayments.isNotEmpty) {
              _workingDocument.paymentHistory = List.from(
                _workingDocument.paymentHistory,
              )..addAll(advancePayments);

              if (_workingDocument.amountDue > 0) {
                _workingDocument.status = DocumentStatus.partial;
              } else {
                _workingDocument.status = DocumentStatus.paid;
              }
            }
            _hasUnsavedChanges = true;
          });

          _showSnackBar(
            'Quotation converted to Invoice: ${_workingDocument.displayDocumentNumber}',
          );
        },
      ),
    );
  }

  // Show Add Advance Payment Dialog (for Invoices)
  void _showAddAdvancePaymentDialog() {
    if (!_workingDocument.isInvoice) {
      _showSnackBar('Advance payments can only be added to Invoices.');
      return;
    }

    if (_workingDocument.status == DocumentStatus.paid) {
      _showSnackBar('This invoice is already fully paid.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddAdvancePaymentDialog(
        currentDue: _workingDocument.amountDue,
        onAddPayments: (List<PaymentRecord> newPayments) {
          setState(() {
            _workingDocument.paymentHistory = List.from(
              _workingDocument.paymentHistory,
            )..addAll(newPayments);

            // Update status based on payment
            if (_workingDocument.amountDue <= 0) {
              _workingDocument.status = DocumentStatus.paid;
            } else if (_workingDocument.paymentHistory.isNotEmpty) {
              _workingDocument.status = DocumentStatus.partial;
            }

            _hasUnsavedChanges = true;
          });

          _showSnackBar('Advance payment(s) added successfully!');
        },
      ),
    );
  }

  // Record Final Payment Dialog
  void _recordPaymentDialog() {
    if (!_workingDocument.hasOutstandingAmount) {
      _showSnackBar('Payment can only be recorded for outstanding Invoices.');
      return;
    }

    final dueAmount = _workingDocument.amountDue;

    showDialog(
      context: context,
      builder: (context) => RecordPaymentDialog(
        dueAmount: dueAmount,
        onRecordPayment: (paymentAmount) {
          if (paymentAmount < dueAmount) {
            // Partial payment
            setState(() {
              _workingDocument.paymentHistory =
                  List.from(_workingDocument.paymentHistory)..add(
                    PaymentRecord(
                      paymentAmount,
                      DateTime.now(),
                      description: 'Partial Payment',
                    ),
                  );

              if (_workingDocument.amountDue <= 0) {
                _workingDocument.status = DocumentStatus.paid;
              }
              _hasUnsavedChanges = true;
            });
            _showSnackBar('Payment recorded successfully!');
          } else {
            // Full payment
            setState(() {
              _workingDocument.paymentHistory =
                  List.from(_workingDocument.paymentHistory)..add(
                    PaymentRecord(
                      paymentAmount,
                      DateTime.now(),
                      description: 'Final Payment (Fully Paid)',
                    ),
                  );
              _workingDocument.status = DocumentStatus.paid;
              _hasUnsavedChanges = true;
            });

            _showSnackBar('Invoice marked as PAID successfully!');
            _saveDocument();
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder: (context) => DocumentPreviewDialog(
        document: _workingDocument,
        customerName: _customerNameController.text,
        customerPhone: _customerPhoneController.text,
        customerAddress: _customerAddressController.text,
        projectTitle: _projectTitleController.text,
      ),
    );
  }

  void _mockPrint() {
    _showSnackBar(
      'Simulating print of ${_workingDocument.type.name.toUpperCase()} #${_workingDocument.displayDocumentNumber}...',
    );
  }

  void _deleteDocument() {
    if (_workingDocument.isQuotation && _workingDocument.isPending) {
      DeleteConfirmationDialog.show(
        context,
        onConfirm: () {
          // ⚠️ Backend Call needed here instead of mockDocuments.removeWhere
          mockDocuments.removeWhere(
            (doc) => doc.documentNumber == _workingDocument.documentNumber,
          );
          _showSnackBar('Quotation Deleted successfully.');
          Navigator.pop(context, true);
        },
      );
    }
  }

  void _cancelCreation() async {
    final shouldDiscard = await DiscardChangesDialog.show(
      context,
      title: 'Cancel Quotation',
      message:
          'Are you sure you want to cancel? All entered data will be lost.',
    );

    if (mounted && shouldDiscard) {
      Navigator.pop(context);
    }
  }

  void _approveQuotation() {
    setState(() {
      _workingDocument.status = DocumentStatus.approved;
      _hasUnsavedChanges = true;
    });
    _showSnackBar('Quotation approved successfully!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const Divider(height: 32),

              // Customer Details Section
              CustomerDetailsSection(
                nameController: _customerNameController,
                phoneController: _customerPhoneController,
                addressController: _customerAddressController,
                projectTitleController: _projectTitleController,
                isEditable: _isCustomerDetailsEditable,
                onSearchByPhone: _searchCustomerByPhone,
                onNameChanged: () => setState(() {}),
              ),
              const Divider(height: 32),

              // Document Details Section
              // 🚨 Document Number Field එක මෙම Section එක තුළින් ඉවත් කිරීමට අවශ්‍ය නම්,
              // ඔබ DocumentDetailsSection widget එක තුළම වෙනස සිදු කළ යුතුය.
              // කෙසේ වෙතත්, UI Logic එක මෙම file එක තුළින් පාලනය කර ඇති බැවින්,
              // අපි DocumentDetailsSection හි වෙනසක් නැතිව තබමු.
              DocumentDetailsSection(
                document: _workingDocument,
                isEditable: _isNewDocument || !_workingDocument.isLocked,
                onInvoiceDateChanged: (date) {
                  setState(() {
                    _workingDocument.invoiceDate = date;
                    _hasUnsavedChanges = true;
                  });
                },
                onDueDateChanged: (date) {
                  setState(() {
                    _workingDocument.dueDate = date;
                    _hasUnsavedChanges = true;
                  });
                },
              ),
              const Divider(height: 32),

              // Payment History Section (for Invoices)
              if (_workingDocument.isInvoice &&
                  _workingDocument.paymentHistory.isNotEmpty)
                PaymentHistorySection(
                  payments: _workingDocument.paymentHistory,
                  amountDue: _workingDocument.amountDue,
                  canAddAdvance: _workingDocument.status != DocumentStatus.paid,
                  onAddAdvance: _showAddAdvancePaymentDialog,
                ),

              // Activity Breakdown Section
              ActivityBreakdownSection(
                lineItems: _workingDocument.lineItems,
                isAddEnabled: _isNewDocument || _workingDocument.isQuotation,
                isPendingQuotation: _isNewDocument || _isPendingQuotation,
                isEditable: _workingDocument.isQuotation,
                onItemChanged: (index, item) {
                  setState(() {
                    _workingDocument.lineItems[index].item = item;
                    _hasUnsavedChanges = true;
                  });
                },
                onQuantityChanged: (index, qty) {
                  setState(() {
                    _workingDocument.lineItems[index].quantity = qty;
                    _hasUnsavedChanges = true;
                  });
                },
                onPriceChanged: (index, price) {
                  setState(() {
                    // 💡 Note: Ensure ItemDescription constructor handles costPrice if it was required to fix validation
                    _workingDocument.lineItems[index].item = ItemDescription(
                      _workingDocument.lineItems[index].item.name,
                      sellingPrice: price,
                      unit: _workingDocument.lineItems[index].item.unit,
                      // Add costPrice here if your ItemDescription model requires it:
                      // costPrice: _workingDocument.lineItems[index].item.costPrice,
                    );
                    _hasUnsavedChanges = true;
                  });
                },
                onAddItem: _addNewLineItem,
                onDeleteItem: (index) {
                  setState(() {
                    _workingDocument.lineItems.removeAt(index);
                    _hasUnsavedChanges = true;
                  });
                },
                onCustomItemTap: _showCustomItemDialog,
              ),
              const Divider(height: 32),

              // Action Buttons Section - Conditional based on mode
              if (_isNewDocument)
                CreateModeButtonsSection(
                  document: _workingDocument,
                  isValid: _isValidForCreation,
                  customerName: _customerNameController.text,
                  customerPhone: _customerPhoneController.text,
                  onCancel: _cancelCreation,
                  onCreateQuotation: _createQuotation,
                )
              else
                EditModeButtonsSection(
                  document: _workingDocument,
                  hasUnsavedChanges: _hasUnsavedChanges,
                  onSave: _saveDocument,
                  onConvert: _showConversionDialog,
                  onAddAdvance: _showAddAdvancePaymentDialog,
                  onRecordPayment: _recordPaymentDialog,
                  onPreview: _showPreviewDialog,
                  onPrint: _mockPrint,
                  onDelete: _deleteDocument,
                ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Text(
            _isNewDocument
                ? 'Create New Quotation'
                : (_workingDocument.isQuotation
                      ? 'Quotation'
                      : 'Invoice Details'),
          ),
          if (_hasUnsavedChanges && !_isNewDocument) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Unsaved',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: _isNewDocument
          ? Colors.purple.shade600
          : (_workingDocument.isLocked
                ? Colors.green.shade700
                : Colors.purple.shade700),
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          if (await _onWillPop()) {
            Navigator.pop(context);
          }
        },
      ),
      actions: [
        // Approve button for existing pending quotations
        if (!_isNewDocument &&
            _workingDocument.isQuotation &&
            _workingDocument.isPending)
          TextButton.icon(
            onPressed: _approveQuotation,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isNewDocument
                    ? Colors.purple.shade100
                    : (_workingDocument.isQuotation
                          ? Colors.orange.shade100
                          : Colors.blue.shade100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isNewDocument
                    ? Icons.add_circle_outline
                    : (_workingDocument.isQuotation
                          ? Icons.description_outlined
                          : Icons.receipt_long),
                color: _isNewDocument
                    ? Colors.purple.shade700
                    : (_workingDocument.isQuotation
                          ? Colors.orange.shade700
                          : Colors.blue.shade700),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isNewDocument
                      ? 'New Quotation'
                      : (_workingDocument.isQuotation
                            ? 'Quotation'
                            : 'Invoice'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 4),
                // ✅ CHANGE: Show document number as read-only text ONLY for existing documents (view/edit mode)
                if (!_isNewDocument)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      // Display Document Number here (e.g., Number: QUO-1005)
                      'Number: ${_workingDocument.displayDocumentNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusBadgeColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusBadgeColor().withOpacity(0.5),
                ),
              ),
              child: Text(
                _isNewDocument
                    ? 'NEW'
                    : _workingDocument.status.name.toUpperCase(),
                style: TextStyle(
                  color: _getStatusBadgeColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusBadgeColor() {
    if (_isNewDocument) return Colors.purple;

    switch (_workingDocument.status) {
      case DocumentStatus.pending:
        return Colors.orange;
      case DocumentStatus.approved:
        return Colors.blue;
      case DocumentStatus.partial:
        return Colors.red;
      case DocumentStatus.paid:
        return Colors.green;
      case DocumentStatus.closed:
        return Colors.grey;
      case DocumentStatus.converted:
        return Colors.purple;
    }
  }
}
