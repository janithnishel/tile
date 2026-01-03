 import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/quotation/quotation_cubit.dart';
import 'package:tilework/cubits/super_admin/category/category_cubit.dart';
import 'package:tilework/cubits/super_admin/category/category_state.dart';
import 'package:tilework/models/category_model.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/payment_record.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';

import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice/add_items_section.dart';
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
  late QuotationDocument _originalDocument; // Store original values for comparison
  bool _hasUnsavedChanges = false;
  bool _isSaving = false; // Track save operation status
  bool _isEditingRejectedQuotation = false; // Track if user clicked "Edit & Re-submit" for rejected quotations

  @override
  void initState() {
    super.initState();
    _isNewDocument = widget.isNewDocument;

    // Create a DEEP COPY of the document for editing
    _workingDocument = _deepCopyDocument(widget.document);
    // Store original values for change detection
    _originalDocument = _deepCopyDocument(widget.document);

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
    _customerNameController.addListener(_checkForChanges);
    _customerPhoneController.addListener(_checkForChanges);
    _customerAddressController.addListener(_checkForChanges);
    _projectTitleController.addListener(_checkForChanges);

    // Load categories from API
    _loadCategories();
  }

  // Deep copy document to prevent direct modifications
  QuotationDocument _deepCopyDocument(QuotationDocument original) {
    return QuotationDocument(
      id: original.id, // 🔧 FIX: Preserve the document ID!
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
                category: item.item.category,
                categoryId: item.item.categoryId,
                productName: item.item.productName,
                type: item.item.type,
                servicePaymentStatus: item.item.servicePaymentStatus,
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

  // Check for actual changes by comparing with original values
  void _checkForChanges() {
    if (!mounted) return;

    // Check if any field has changed from original values
    final hasNameChanged = _customerNameController.text.trim() != _originalDocument.customerName;
    final hasPhoneChanged = _customerPhoneController.text.trim() != _originalDocument.customerPhone;
    final hasAddressChanged = _customerAddressController.text.trim() != _originalDocument.customerAddress;
    final hasTitleChanged = _projectTitleController.text.trim() != _originalDocument.projectTitle;

    // Check if document dates have changed
    final hasDateChanges = _workingDocument.invoiceDate != _originalDocument.invoiceDate ||
                          _workingDocument.dueDate != _originalDocument.dueDate;

    // Check if line items have changed (quantity, price, or items added/removed)
    final hasItemChanges = _workingDocument.lineItems.length != _originalDocument.lineItems.length ||
                          _workingDocument.lineItems.any((item) =>
                            !_originalDocument.lineItems.any((origItem) =>
                              origItem.quantity == item.quantity &&
                              origItem.item.sellingPrice == item.item.sellingPrice &&
                              origItem.item.name == item.item.name
                            )
                          );

    // Check if status has changed
    final hasStatusChanged = _workingDocument.status != _originalDocument.status;

    final hasAnyChanges = hasNameChanged || hasPhoneChanged || hasAddressChanged ||
                         hasTitleChanged || hasDateChanges || hasItemChanges || hasStatusChanged;

    // Debug logging
    if (hasAnyChanges != _hasUnsavedChanges) {
      debugPrint('🔄 Change detected: hasUnsavedChanges $_hasUnsavedChanges -> $hasAnyChanges');
      debugPrint('   Name changed: $hasNameChanged (${_customerNameController.text.trim()} vs ${_originalDocument.customerName})');
      debugPrint('   Phone changed: $hasPhoneChanged (${_customerPhoneController.text.trim()} vs ${_originalDocument.customerPhone})');
      debugPrint('   Address changed: $hasAddressChanged (${_customerAddressController.text.trim()} vs ${_originalDocument.customerAddress})');
      debugPrint('   Title changed: $hasTitleChanged (${_projectTitleController.text.trim()} vs ${_originalDocument.projectTitle})');
    }

    if (hasAnyChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasAnyChanges;
      });
    }
  }

  void _markAsChanged() {
    if (mounted && !_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _customerNameController.removeListener(_checkForChanges);
    _customerPhoneController.removeListener(_checkForChanges);
    _customerAddressController.removeListener(_checkForChanges);
    _projectTitleController.removeListener(_checkForChanges);

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
              _workingDocument.isInvoice)) ||
      (_workingDocument.status == DocumentStatus.rejected && _isEditingRejectedQuotation);

  bool get _isPendingQuotation =>
      _workingDocument.isQuotation &&
      _workingDocument.status == DocumentStatus.pending;

  bool get _isValidForCreation {
    final hasName = _customerNameController.text.trim().isNotEmpty;
    final phoneValid = _validatePhoneNumber(_customerPhoneController.text.trim()) == null;
    final hasValidItems = _workingDocument.lineItems.any((item) =>
      item.quantity > 0.0 && item.item.sellingPrice > 0.0
    );

    debugPrint('🔍 Validation check - Name: $hasName, Phone: $phoneValid, Items: $hasValidItems (${_workingDocument.lineItems.length} total items)');
    if (_workingDocument.lineItems.isNotEmpty) {
      debugPrint('   Item details:');
      for (var i = 0; i < _workingDocument.lineItems.length; i++) {
        final item = _workingDocument.lineItems[i];
        debugPrint('     $i. "${item.item.name}" - Qty: ${item.quantity}, Price: ${item.item.sellingPrice}');
      }
    }

    return hasName && phoneValid && hasValidItems;
  }

  // For existing documents, only check if there are unsaved changes (don't enforce validation)
  bool get _canSaveExistingDocument => _hasUnsavedChanges && !_isSaving;




  bool get _showSearchButton => _isNewDocument; // Search button only for new quotations

  // Phone Validation - International phone number validation
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phone = value.trim();

    // Check for international format: optional +, followed by 7-15 digits
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(phone)) {
      return 'Please enter a valid phone number (e.g., +9477... or local format).';
    }

    // Valid phone number
    return null;
  }

  // Handle back button with unsaved changes warning
  Future<bool> _onWillPop() async {
    // Prevent navigation during save operation
    if (_isSaving) {
      _showSnackBar('Please wait for save operation to complete.');
      return false;
    }

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

    // Debug: Log search attempt
    debugPrint('🔍 Searching for phone: $phone');

    // Normalize phone number for comparison (remove spaces and standardize format)
    final normalizedPhone = phone.replaceAll(' ', '').replaceAll('+94', '0');
    debugPrint('🔄 Normalized phone: $normalizedPhone');

    // First check if it matches the current logged-in user's phone (from seed data)
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      // Current user info (from seed script)
      final currentUserPhone = '+94 11 234 5678'.replaceAll(' ', '').replaceAll('+94', '0');
      debugPrint('👤 Current user phone: $currentUserPhone');
      if (normalizedPhone == currentUserPhone) {
        debugPrint('✅ Found current user match');
        if (mounted) {
          setState(() {
            _customerNameController.text = 'Admin User'; // From seed script
            _customerAddressController.text = '123 Main Street, Colombo 07, Sri Lanka'; // From seed script
            _projectTitleController.text = 'Personal Project';
          });
        }
        _showSnackBar('Customer found: Admin User (Current User)');
        return;
      }
    }

    // Search in actual quotations from the system (not mock data)
    final quotationState = context.read<QuotationCubit>().state;
    final allQuotations = quotationState.quotations;

    debugPrint('📊 Searching ${allQuotations.length} saved quotations/invoices...');
    for (final doc in allQuotations) {
      final docPhone = doc.customerPhone.replaceAll(' ', '').replaceAll('+94', '0');
      debugPrint('   Checking: ${doc.customerName} - ${docPhone} (${doc.type.name})');
    }

    final existingDoc = allQuotations.firstWhere(
      (doc) {
        final docPhone = doc.customerPhone.replaceAll(' ', '').replaceAll('+94', '0');
        final matches = docPhone == normalizedPhone &&
                       doc.documentNumber != _workingDocument.documentNumber;
        if (matches) {
          debugPrint('✅ Found match: ${doc.customerName} (${docPhone}) from ${doc.type.name} ${doc.documentNumber}');
        }
        return matches;
      },
      orElse: () => QuotationDocument(
        documentNumber: '',
        customerName: '',
        invoiceDate: DateTime.now(),
        dueDate: DateTime.now(),
      ),
    );

    // If found in saved quotations, use that customer data (but keep project title empty)
    if (existingDoc.customerPhone.isNotEmpty) {
      debugPrint('🎯 Using customer data from ${existingDoc.type.name}: ${existingDoc.customerName}');
      if (mounted) {
        setState(() {
          _customerNameController.text = existingDoc.customerName;
          _customerAddressController.text = existingDoc.customerAddress;
          // Keep project title empty for new project
          _projectTitleController.text = '';
        });
      }
      _showSnackBar('Customer found: ${existingDoc.customerName}');
      return;
    }

    // If no match found, show not found message
    debugPrint('❌ No customer found for phone: $normalizedPhone');
    _showSnackBar('Customer not found. Please enter new details.');
  }

  void _addNewLineItem() {
    // Create a new material item with all required fields including category
    final defaultItem = ItemDescription(
      'New Item',
      sellingPrice: 0.0,
      unit: 'units',
      category: '', // Start with empty category to show placeholder
      productName: '',
      type: ItemType.material,
    );

    if (mounted) {
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
  }

  void _addNewServiceItem() {
    // Create a new service item with all required fields
    final defaultService = ItemDescription(
      'New Service',
      sellingPrice: 0.0,
      unit: 'units',
      category: '',
      productName: '',
      type: ItemType.service,
    );

    if (mounted) {
      setState(() {
        _workingDocument.lineItems.add(
          InvoiceLineItem(
            item: defaultService,
            quantity: 0.0,
            isOriginalQuotationItem:
                _workingDocument.isQuotation &&
                _workingDocument.status == DocumentStatus.pending,
          ),
        );
        _hasUnsavedChanges = true;
      });
    }
  }

  void _showCustomItemDialog(InvoiceLineItem item) {
    showDialog(
      context: context,
      builder: (context) => CustomItemDialog(
        item: item,
        onSave: (description, newItem) {
          if (mounted) {
            setState(() {
              item.customDescription = description;
              item.item = newItem;
              _hasUnsavedChanges = true;
            });
          }
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
      if (mounted) {
        _showSnackBar('Quotation created successfully!');

        // Pop the screen and pass 'true' to indicate a successful creation that requires a list refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to create quotation: ${e.toString()}');
      }
    }
  }

  // Save Document (for existing documents)
  Future<void> _saveDocument() async {
    if (_isSaving) return; // Prevent multiple save operations

    debugPrint('💾 Save Document - Starting save process...');
    debugPrint('💾 Save Document - Document ID: ${widget.document.id}');
    debugPrint('💾 Save Document - Document Number: ${widget.document.documentNumber}');
    debugPrint('💾 Save Document - Has unsaved changes: $_hasUnsavedChanges');
    debugPrint('💾 Save Document - Is editing rejected quotation: $_isEditingRejectedQuotation');

    if (widget.document.id == null || widget.document.id!.isEmpty) {
      debugPrint('❌ Save Document - Document ID is null or empty!');
      _showSnackBar('Cannot save document: Document ID is missing. Please refresh and try again.');
      return;
    }

    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    // If editing a rejected quotation, change status to pending
    if (_isEditingRejectedQuotation && _workingDocument.status == DocumentStatus.rejected) {
      _workingDocument.status = DocumentStatus.pending;
      _isEditingRejectedQuotation = false; // Reset the editing flag
      debugPrint('💾 Save Document - Changed status from rejected to pending for re-submission');
    }

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

    debugPrint('💾 Save Document - Updated document data:');
    debugPrint('   - Customer: ${widget.document.customerName}');
    debugPrint('   - Phone: ${widget.document.customerPhone}');
    debugPrint('   - Line items: ${widget.document.lineItems.length}');

    // Log the JSON payload being sent
    final jsonPayload = widget.document.toJson();
    debugPrint('💾 Save Document - JSON Payload keys: ${jsonPayload.keys.toList()}');
    debugPrint('💾 Save Document - Full JSON Payload: $jsonPayload');

    try {
      // Update quotation using the cubit (calls backend API)
      debugPrint('💾 Save Document - Calling cubit.updateQuotation...');
      final updatedQuotation = await context.read<QuotationCubit>().updateQuotation(widget.document);
      debugPrint('💾 Save Document - Cubit update successful');

      if (mounted) {
        // Update working document with saved data
        _workingDocument = _deepCopyDocument(updatedQuotation);

        setState(() {
          _hasUnsavedChanges = false;
          _isSaving = false;
          _originalDocument = _deepCopyDocument(_workingDocument);
        });

        // Show appropriate success message
        final wasRejected = _originalDocument.status == DocumentStatus.rejected && updatedQuotation.status == DocumentStatus.pending;
        _showSnackBar(
          wasRejected
              ? '${_workingDocument.displayDocumentNumber} Re-submitted successfully!'
              : '${_workingDocument.type.name.toUpperCase()} ${_workingDocument.displayDocumentNumber} Saved.',
        );

        // Stay on screen to allow user to verify changes
        // Navigation removed - user can manually go back when ready
      }
    } catch (e) {
      debugPrint('❌ Save Document - Failed with error: $e');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        _showSnackBar('Failed to save document: ${e.toString()}');
      }
    }
  }

  // Show Convert to Invoice Dialog
  void _showConversionDialog() {
    debugPrint('════════════════════════════════════════════════════════');
    debugPrint('🚀 _showConversionDialog() STARTED');
    debugPrint('════════════════════════════════════════════════════════');

    // Step 1: Validate BEFORE opening dialog
    debugPrint('📋 Current Status: ${_workingDocument.status}');
    debugPrint('📋 Document ID: ${_workingDocument.id}');

    if (_workingDocument.status != DocumentStatus.approved) {
      _showSnackBar('Quotation must be Approved before conversion.');
      return;
    }

    if (_workingDocument.id == null || _workingDocument.id!.trim().isEmpty) {
      _showSnackBar('Cannot convert quotation: Document ID is missing.');
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      _showSnackBar('Authentication error. Please log in again.');
      return;
    }

    // Store references
    final quotationCubit = context.read<QuotationCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final documentId = _workingDocument.id!;
    final subtotal = _workingDocument.subtotal;

    debugPrint('💰 Subtotal: $subtotal');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ConvertToInvoiceDialog(
        quotationTotal: subtotal,
        onConvert: (List<PaymentRecord> advancePayments, {DateTime? customDueDate}) async {
          debugPrint('════════════════════════════════════════════════════════');
          debugPrint('🔄 onConvert CALLBACK TRIGGERED');
          debugPrint('════════════════════════════════════════════════════════');

          // Close dialog FIRST
          Navigator.of(dialogContext).pop();
          debugPrint('✅ Dialog closed');

          if (!mounted) {
            debugPrint('❌ Widget not mounted, returning');
            return;
          }

          // 🔍 DEBUG: Check advance payments
          debugPrint('════════════════════════════════════════════════════════');
          debugPrint('💵 ADVANCE PAYMENTS CHECK:');
          debugPrint('   advancePayments.isEmpty: ${advancePayments.isEmpty}');
          debugPrint('   advancePayments.length: ${advancePayments.length}');
          if (advancePayments.isNotEmpty) {
            for (int i = 0; i < advancePayments.length; i++) {
              debugPrint('   Payment $i: ${advancePayments[i].amount}');
            }
          }
          debugPrint('════════════════════════════════════════════════════════');

          try {
            debugPrint('🔄 Calling quotationCubit.convertToInvoice($documentId)...');

            final convertedInvoice = await quotationCubit.convertToInvoice(
              documentId,
              advancePayments: advancePayments.map((p) => p.toJson()).toList(),
            );

            debugPrint('════════════════════════════════════════════════════════');
            debugPrint('📦 BACKEND RESPONSE:');
            debugPrint('   Document Number: ${convertedInvoice.documentNumber}');
            debugPrint('   Type: ${convertedInvoice.type}');
            debugPrint('   Status from Backend: ${convertedInvoice.status}');
            debugPrint('════════════════════════════════════════════════════════');

            if (!mounted) {
              debugPrint('❌ Widget not mounted after API call, returning');
              return;
            }

            // Create deep copy
            final updatedInvoice = _deepCopyDocument(convertedInvoice);
            debugPrint('📋 After deep copy - Status: ${updatedInvoice.status}');

            // Set type to invoice
            updatedInvoice.type = DocumentType.invoice;
            debugPrint('📋 Set type to invoice');

            // Backend now handles status correctly - use the status from backend
            debugPrint('════════════════════════════════════════════════════════');
            debugPrint('🎯 USING BACKEND STATUS...');

            if (advancePayments.isNotEmpty) {
              // Add advance payments to local copy for UI display
              updatedInvoice.paymentHistory = [
                ...updatedInvoice.paymentHistory,
                ...advancePayments,
              ];
              debugPrint('   ➡️ Added ${advancePayments.length} payments to history for UI display');
            }

            debugPrint('   ✅ Using backend status: ${updatedInvoice.status}');
            debugPrint('════════════════════════════════════════════════════════');

            // Final status check before setState
            debugPrint('🔍 BEFORE setState:');
            debugPrint('   updatedInvoice.status = ${updatedInvoice.status}');
            debugPrint('   updatedInvoice.type = ${updatedInvoice.type}');

            if (!mounted) {
              debugPrint('❌ Widget not mounted before setState, returning');
              return;
            }

            setState(() {
              _workingDocument = updatedInvoice;
              _originalDocument = _deepCopyDocument(updatedInvoice);
              _hasUnsavedChanges = false; // Invoice is now saved

              widget.document.type = DocumentType.invoice;
              widget.document.status = updatedInvoice.status;
              widget.document.paymentHistory = updatedInvoice.paymentHistory;
              widget.document.id = updatedInvoice.id;
              widget.document.documentNumber = updatedInvoice.documentNumber;
            });

            // After setState check
            debugPrint('════════════════════════════════════════════════════════');
            debugPrint('🔍 AFTER setState:');
            debugPrint('   _workingDocument.status = ${_workingDocument.status}');
            debugPrint('   _workingDocument.type = ${_workingDocument.type}');
            debugPrint('   widget.document.status = ${widget.document.status}');
            debugPrint('════════════════════════════════════════════════════════');

            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Converted: ${updatedInvoice.displayDocumentNumber} (Status: ${updatedInvoice.status.name.toUpperCase()})',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            debugPrint('✅ CONVERSION COMPLETE!');
            debugPrint('════════════════════════════════════════════════════════');

          } catch (e) {
            debugPrint('════════════════════════════════════════════════════════');
            debugPrint('❌ CONVERSION ERROR: $e');
            debugPrint('════════════════════════════════════════════════════════');

            if (!mounted) return;

            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Failed: ${e.toString()}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
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

    // ✅ Store reference BEFORE dialog
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AddAdvancePaymentDialog(
        currentDue: _workingDocument.amountDue,
        onAddPayments: (List<PaymentRecord> newPayments) {
          // ✅ Close dialog FIRST
          Navigator.of(dialogContext).pop();

          if (!mounted) return;

          setState(() {
            _workingDocument.paymentHistory = List.from(
              _workingDocument.paymentHistory,
            )..addAll(newPayments);

            if (_workingDocument.amountDue <= 0) {
              _workingDocument.status = DocumentStatus.paid;
            } else if (_workingDocument.paymentHistory.isNotEmpty) {
              _workingDocument.status = DocumentStatus.partial;
            }

            _hasUnsavedChanges = true;
          });

          // Save the document after adding payments
          _saveDocument();

          // ✅ Use stored reference
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Advance payment(s) added successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
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

    // ✅ Store references BEFORE dialog
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => RecordPaymentDialog(
        dueAmount: dueAmount,
        onRecordPayment: (paymentAmount) {
          // ✅ Close dialog FIRST
          Navigator.of(dialogContext).pop();

          if (!mounted) return;

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

            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Payment recorded successfully!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
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

            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Invoice marked as PAID!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Save document (consistent with other save operations - stay on screen)
            _saveDocument();
          }
        },
      ),
    );
  }

  void _showPreviewDialog() {
    DocumentPdfService.previewPDF(
      context: context,
      document: _workingDocument,
      customerName: _customerNameController.text,
      customerPhone: _customerPhoneController.text,
      customerAddress: _customerAddressController.text,
      projectTitle: _projectTitleController.text,
    );
  }

  void _mockPrint() {
    _showSnackBar(
      'Simulating print of ${_workingDocument.type.name.toUpperCase()} #${_workingDocument.displayDocumentNumber}...',
    );
  }

  void _deleteDocument() async {
    if (!(_workingDocument.isQuotation && _workingDocument.isPending)) {
      return;
    }

    if (_workingDocument.id == null || _workingDocument.id!.trim().isEmpty) {
      _showSnackBar('Cannot delete: Document ID is missing.');
      return;
    }

    // ✅ Store references BEFORE dialog
    final quotationCubit = context.read<QuotationCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final documentId = _workingDocument.id!;

    final confirmed = await DeleteConfirmationDialog.show(
      context,
      onConfirm: () async {
        // Dialog already closed by DeleteConfirmationDialog

        if (!mounted) return;

        try {
          // ✅ Use stored cubit reference
          await quotationCubit.deleteQuotation(documentId);

          if (!mounted) return;

          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Quotation deleted successfully.'),
              behavior: SnackBarBehavior.floating,
            ),
          );

          navigator.pop(true);
        } catch (e) {
          if (!mounted) return;

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
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
    if (mounted) {
      setState(() {
        _workingDocument.status = DocumentStatus.approved;
        _hasUnsavedChanges = true;
      });
      _showSnackBar('Quotation approved successfully!');
    }
  }

  void _rejectQuotation() {
    if (mounted) {
      setState(() {
        _workingDocument.status = DocumentStatus.rejected; // Use rejected status for rejected
        _hasUnsavedChanges = true;
      });
      // Automatically save the document after rejecting
      _saveDocument();
    }
  }

  // Load categories from API
  Future<void> _loadCategories() async {
    try {
      final authState = context.read<AuthCubit>().state;
      final token = authState is AuthAuthenticated ? authState.token : null;

      debugPrint('📂 Loading categories from backend API...');
      await context.read<CategoryCubit>().loadCategories(token: token);
      debugPrint('✅ Categories loaded successfully from backend');

      // Force rebuild to show loaded categories
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Categories failed to load, will use fallback
      debugPrint('❌ Failed to load categories from backend: $e');
      _showSnackBar('Failed to load categories from server. Using fallback options.');
    }
  }



  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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

              // Rejection Alert Banner (for rejected quotations)
              if (_workingDocument.status == DocumentStatus.rejected && !_isNewDocument)
                _buildRejectionAlert(),

              // Customer Details Section
              CustomerDetailsSection(
                nameController: _customerNameController,
                phoneController: _customerPhoneController,
                addressController: _customerAddressController,
                projectTitleController: _projectTitleController,
                isEditable: _isCustomerDetailsEditable,
                showSearchButton: _showSearchButton,
                onSearchByPhone: _searchCustomerByPhone,
                onNameChanged: () {
                  if (mounted) {
                    setState(() {});
                  }
                },
                phoneValidator: _validatePhoneNumber,
              ),
              const Divider(height: 32),

              // Document Details Section
              // 🚨 Document Number Field එක මෙම Section එක තුළින් ඉවත් කිරීමට අවශ්‍ය නම්,
              // ඔබ DocumentDetailsSection widget එක තුළම වෙනස සිදු කළ යුතුය.
              // කෙසේ වෙතත්, UI Logic එක මෙම file එක තුළින් පාලනය කර ඇති බැවින්,
              // අපි DocumentDetailsSection හි වෙනසක් නැතිව තබමු.
              DocumentDetailsSection(
                document: _workingDocument,
                isEditable: _isNewDocument || !_workingDocument.isLocked || (_workingDocument.status == DocumentStatus.rejected && _isEditingRejectedQuotation),
                onInvoiceDateChanged: (date) {
                  if (mounted) {
                    setState(() {
                      _workingDocument.invoiceDate = date;
                      _hasUnsavedChanges = true;
                    });
                  }
                },
                onDueDateChanged: (date) {
                  if (mounted) {
                    setState(() {
                      _workingDocument.dueDate = date;
                      _hasUnsavedChanges = true;
                    });
                  }
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
              BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, categoryState) {
                  debugPrint('🏗️ ActivityBreakdownSection - Categories loaded: ${categoryState.categories.length}');
                  debugPrint('🏗️ ActivityBreakdownSection - Is loading: ${categoryState.isLoading}');
                  debugPrint('🏗️ ActivityBreakdownSection - Error: ${categoryState.errorMessage}');

                  if (categoryState.categories.isNotEmpty) {
                    debugPrint('🏗️ Available categories:');
                    int totalItems = 0;
                    for (var category in categoryState.categories) {
                      final allItemsCount = category.items.length;
                      final serviceItemsCount = category.items.where((item) => item.isService).length;
                      final materialItemsCount = allItemsCount - serviceItemsCount;
                      totalItems += allItemsCount;
                      debugPrint('   - ${category.name} (${allItemsCount} total: ${materialItemsCount} materials, ${serviceItemsCount} services)');
                    }
                    debugPrint('🏗️ Total categories: ${categoryState.categories.length}, Total items: $totalItems');
                  }

                  return AddItemsSection(
                    lineItems: _workingDocument.lineItems,
                    categories: categoryState.categories, // Pass loaded categories
                    isAddEnabled: _isNewDocument || (_workingDocument.isQuotation && (_workingDocument.status != DocumentStatus.rejected || _isEditingRejectedQuotation)),
                    isPendingQuotation: _isNewDocument || _isPendingQuotation || (_workingDocument.status == DocumentStatus.rejected && _isEditingRejectedQuotation),
                    isEditable: _workingDocument.isQuotation && _workingDocument.status != DocumentStatus.approved && (_workingDocument.status != DocumentStatus.rejected || _isEditingRejectedQuotation),
                    isQuotationCreation: _isNewDocument && _workingDocument.isQuotation, // New parameter for quotation creation mode
                    onItemChanged: (index, item) {
                      if (mounted) {
                        setState(() {
                          _workingDocument.lineItems[index].item = item;
                          // Reset payment status when item changes
                          _workingDocument.lineItems[index].isSiteVisitPaid = false;
                          _hasUnsavedChanges = true;
                        });
                      }
                    },
                    onQuantityChanged: (index, qty) {
                      if (mounted) {
                        setState(() {
                          _workingDocument.lineItems[index].quantity = qty;
                          _hasUnsavedChanges = true;
                        });
                      }
                    },
                    onPriceChanged: (index, price) {
                      if (mounted) {
                        setState(() {
                          // 💡 Note: Ensure ItemDescription constructor handles costPrice if it was required to fix validation
                          _workingDocument.lineItems[index].item = ItemDescription(
                            _workingDocument.lineItems[index].item.name,
                            sellingPrice: price,
                            unit: _workingDocument.lineItems[index].item.unit,
                            category: _workingDocument.lineItems[index].item.category,
                            categoryId: _workingDocument.lineItems[index].item.categoryId,
                            productName: _workingDocument.lineItems[index].item.productName,
                            type: _workingDocument.lineItems[index].item.type,
                            servicePaymentStatus: _workingDocument.lineItems[index].item.servicePaymentStatus,
                            // Add costPrice here if your ItemDescription model requires it:
                            // costPrice: _workingDocument.lineItems[index].item.costPrice,
                          );
                          _hasUnsavedChanges = true;
                        });
                      }
                    },
                    onAddItem: _addNewLineItem,
                    onAddService: _addNewServiceItem,
                    onDeleteItem: (index) {
                      if (mounted) {
                        setState(() {
                          _workingDocument.lineItems.removeAt(index);
                          _hasUnsavedChanges = true;
                        });
                      }
                    },
                    onCustomItemTap: _showCustomItemDialog,
                    onSiteVisitPaymentChanged: (index, isPaid) {
                      if (mounted) {
                        setState(() {
                          _workingDocument.lineItems[index].isSiteVisitPaid = isPaid;
                          _hasUnsavedChanges = true;
                        });
                      }
                    },
                  );
                },
              ),

              // Action Buttons Section - Conditional based on mode
              if (_isNewDocument)
                CreateModeButtonsSection(
                  document: _workingDocument,
                  isValid: _isValidForCreation,
                  customerName: _customerNameController.text,
                  customerPhone: _customerPhoneController.text,
                  phoneValidator: _validatePhoneNumber,
                  onCancel: _cancelCreation,
                  onCreateQuotation: _createQuotation,
                )
              else if (_workingDocument.status == DocumentStatus.rejected && !_isEditingRejectedQuotation)
                // Special buttons for rejected quotations when not editing
                _buildRejectedQuotationButtons()
              else
                EditModeButtonsSection(
                  document: _workingDocument,
                  hasUnsavedChanges: _hasUnsavedChanges,
                  isValid: _isValidForCreation, // Use same validation logic for save button
                  isSaving: _isSaving,
                  isNewDocument: _isNewDocument,
                  onSave: _saveDocument,
                  onApprove: _approveQuotation,
                  onReject: _rejectQuotation,
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
        // Approve button moved to bottom section
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
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
      case DocumentStatus.rejected:
        return Colors.red.shade800;
      case DocumentStatus.converted:
        return Colors.purple;
      case DocumentStatus.invoiced:
        return Colors.teal;
    }
  }

  Widget _buildRejectionAlert() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This quotation was rejected. All input fields are currently disabled.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedQuotationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Edit & Re-submit Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isEditingRejectedQuotation = true;
                });
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit & Re-submit'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Preview Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showPreviewDialog,
              icon: const Icon(Icons.preview),
              label: const Text('Preview'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Print Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _mockPrint,
              icon: const Icon(Icons.print),
              label: const Text('Print'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Delete Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _deleteDocument,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
