import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/material_sale/material_sale_cubit.dart';
import 'package:tilework/cubits/super_admin/category/category_cubit.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sales_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/payment_record.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/material_sales_tab_view/ms_customer_section.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/material_sales_tab_view/ms_product_section.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/material_sales_tab_view/ms_payment_section.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/material_sales_tab_view/dialogs/ms_payment_dialog.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/material_sales_tab_view/dialogs/ms_preview_dialog.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/material_sales_tab_view/dialogs/ms_summary_bottom_sheet.dart';

class MaterialSaleInvoiceScreen extends StatefulWidget {
  final MaterialSaleDocument document;
  final bool isNewDocument;

  const MaterialSaleInvoiceScreen({
    Key? key,
    required this.document,
    this.isNewDocument = false,
  }) : super(key: key);

  @override
  State<MaterialSaleInvoiceScreen> createState() => _MaterialSaleInvoiceScreenState();
}

class _MaterialSaleInvoiceScreenState extends State<MaterialSaleInvoiceScreen> {
  late final TextEditingController _customerNameController;
  late final TextEditingController _customerPhoneController;
  late final TextEditingController _customerAddressController;

  // Working copy of the document
  late MaterialSaleDocument _workingDocument;
  late bool _isNewDocument;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;
  bool _isSearchingCustomer = false;

  @override
  void initState() {
    super.initState();
    _isNewDocument = widget.isNewDocument;

    // Create a deep copy for editing
    _workingDocument = _deepCopyDocument(widget.document);



    _customerNameController = TextEditingController(text: _workingDocument.customerName);
    _customerPhoneController = TextEditingController(text: _workingDocument.customerPhone);
    _customerAddressController = TextEditingController(text: _workingDocument.customerAddress);

    // Listen for changes
    _customerNameController.addListener(_markAsChanged);
    _customerPhoneController.addListener(_markAsChanged);
    _customerAddressController.addListener(_markAsChanged);

    // Load categories for product selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get auth token for category loading
      final authState = context.read<AuthCubit>().state;
      final token = authState is AuthAuthenticated ? authState.token : null;

      if (token != null) {
        context.read<CategoryCubit>().loadCategories(token: token);
      } else {
        debugPrint('⚠️ No auth token available for loading categories');
      }
    });
  }

  MaterialSaleDocument _deepCopyDocument(MaterialSaleDocument original) {
    return MaterialSaleDocument(
      id: original.id, // Include the ID!
      invoiceNumber: original.invoiceNumber,
      saleDate: original.saleDate,
      customerName: original.customerName,
      customerPhone: original.customerPhone,
      customerAddress: original.customerAddress,
      items: original.items.map((item) => item.copyWith()).toList(),
      paymentHistory: original.paymentHistory
          .map((p) => p) // Assuming PaymentRecord has copy or is immutable
          .toList(),
      status: original.status,
      notes: original.notes,
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
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    super.dispose();
  }

  bool get _isEditable => _isNewDocument || _workingDocument.status == MaterialSaleStatus.pending;

  bool get _canDelete => !_isNewDocument &&
      _workingDocument.status == MaterialSaleStatus.pending &&
      _workingDocument.totalPaid == 0;

  bool get _isValidForCreation {
    return _customerNameController.text.trim().isNotEmpty &&
        _customerPhoneController.text.trim().isNotEmpty &&
        _workingDocument.items.isNotEmpty;
  }

  Future<bool> _onWillPop() async {
    if (_isNewDocument) {
      // Show discard dialog
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard New Sale?'),
          content: const Text('You have unsaved changes. Discard?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard'),
            ),
          ],
        ),
      ) ?? false;
    }

    if (_hasUnsavedChanges) {
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('You have unsaved changes. Go back without saving?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard'),
            ),
          ],
        ),
      ) ?? false;
    }

    return true;
  }

  void _createSale() async {
    if (!_isValidForCreation) {
      _showSnackBar('Please fill all required fields and add items.');
      return;
    }

    // Update document
    _workingDocument.customerName = _customerNameController.text.trim();
    _workingDocument.customerPhone = _customerPhoneController.text.trim();
    _workingDocument.customerAddress = _customerAddressController.text.trim();

    // Update status based on payment history before creation
    _updateDocumentStatus();

    try {
      debugPrint('📄 Creating material sale with status: ${_workingDocument.status}');
      debugPrint('💰 Payment history count: ${_workingDocument.paymentHistory.length}');
      debugPrint('💰 Total amount: ${_workingDocument.totalAmount}, Total paid: ${_workingDocument.totalPaid}');

      // Create material sale using the cubit (calls backend API)
      await context.read<MaterialSaleCubit>().createMaterialSale(_workingDocument);

      _showSnackBar('Material Sale created successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Failed to create material sale: ${e.toString()}');
    }
  }

  void _updateDocumentStatus() {
    final totalPaid = _workingDocument.totalPaid;
    final totalAmount = _workingDocument.totalAmount;

    if (totalPaid >= totalAmount) {
      _workingDocument.status = MaterialSaleStatus.paid;
    } else if (totalPaid > 0) {
      _workingDocument.status = MaterialSaleStatus.partial;
    } else {
      _workingDocument.status = MaterialSaleStatus.pending;
    }

    debugPrint('🔄 Status updated to: ${_workingDocument.status} (Paid: $totalPaid, Total: $totalAmount)');
  }

  Future<void> _saveDocument() async {
    if (_workingDocument.id == null) {
      _showSnackBar('Cannot save: Document ID is missing');
      return;
    }

    try {
      // Show loading state
      setState(() {
        _isSaving = true;
      });

      // Update customer details from controllers
      final updatedDocument = _workingDocument.copyWith(
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        customerAddress: _customerAddressController.text.trim(),
      );

      // Call API to update the material sale
      await context.read<MaterialSaleCubit>().updateMaterialSale(updatedDocument);

      // Update local document reference
      widget.document.customerName = updatedDocument.customerName;
      widget.document.customerPhone = updatedDocument.customerPhone;
      widget.document.customerAddress = updatedDocument.customerAddress;
      widget.document.items = updatedDocument.items;
      widget.document.paymentHistory = updatedDocument.paymentHistory;
      widget.document.status = updatedDocument.status;

      setState(() {
        _hasUnsavedChanges = false;
        _isSaving = false;
      });

      _showSnackBar('Sale saved successfully!');
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      _showSnackBar('Failed to save changes: ${e.toString()}');
    }
  }

  void _showSummary() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: MSSummaryBottomSheet(sale: _workingDocument),
        ),
      ),
    );
  }

  void _recordPayment() {
    MSPaymentDialog.show(
      context,
      totalAmount: _workingDocument.totalAmount,
      amountDue: _workingDocument.amountDue,
      onPaymentRecorded: _onPaymentRecorded,
    );
  }

  void _showDuePaymentDialog() {
    MSPaymentDialog.show(
      context,
      totalAmount: _workingDocument.totalAmount,
      amountDue: _workingDocument.amountDue,
      onPaymentRecorded: _onPaymentRecorded,
      initialTabIndex: 0, // Force Full Payment tab
    );
  }

  Future<void> _onPaymentRecorded(PaymentRecord payment, bool isFullPayment) async {
    if (!_isNewDocument && _workingDocument.id != null) {
      // For existing documents, call API to add payment
      try {
        final paymentData = {
          'amount': payment.amount,
          'date': payment.date.toIso8601String(),
          'description': payment.description,
        };

        debugPrint('💰 Recording payment: ${payment.amount} for sale ${_workingDocument.id}');
        debugPrint('📊 Before payment - Status: ${_workingDocument.status}, Total: ${_workingDocument.totalAmount}, Due: ${_workingDocument.amountDue}');

        // Call cubit to add payment via API
        await context.read<MaterialSaleCubit>().addPayment(_workingDocument.id!, paymentData);

        // Update local working document with the new payment (the cubit should handle the response)
        final updatedDocument = context.read<MaterialSaleCubit>().state.materialSales
            .firstWhere((sale) => sale.id == _workingDocument.id);

        debugPrint('📊 After payment - Status: ${updatedDocument.status}, Total: ${updatedDocument.totalAmount}, Due: ${updatedDocument.amountDue}');
        debugPrint('📝 Payment history count: ${updatedDocument.paymentHistory.length}');
        debugPrint('🔄 Status changed: ${_workingDocument.status} → ${updatedDocument.status}');

        setState(() {
          _workingDocument = _deepCopyDocument(updatedDocument);
          _hasUnsavedChanges = false; // API call succeeded, no unsaved changes
        });

        debugPrint('🔄 UI updated - Working document status: ${_workingDocument.status}, due: ${_workingDocument.amountDue}, isEditable: ${_isEditable}');

        // Force a rebuild to ensure UI updates immediately
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
          }
        });

        _showSnackBar('Payment recorded successfully!');
      } catch (e) {
        _showSnackBar('Failed to record payment: ${e.toString()}');
      }
    } else {
      // For new documents, just update local state
      setState(() {
        _workingDocument.paymentHistory = List.from(_workingDocument.paymentHistory)..add(payment);

        // Update status based on total payments
        _updateDocumentStatus();

        _hasUnsavedChanges = true;
      });

      _showSnackBar('Payment recorded successfully!');
    }
  }

  void _showPreview() {
    MSPreviewDialog.show(context, _workingDocument);
  }

  void _mockPrint() {
    _showSnackBar('Simulating print of Material Sale Invoice #${_workingDocument.displayInvoiceNumber}...');
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sale'),
        content: const Text('Are you sure you want to delete this pending sale? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteSale();
    }
  }

  Future<void> _deleteSale() async {
    if (_workingDocument.id == null) {
      _showSnackBar('Cannot delete: Sale ID is missing');
      return;
    }

    try {
      // Show loading indicator
      setState(() {
        _isSaving = true;
      });

      debugPrint('🗑️ Deleting material sale: ${_workingDocument.id}');

      // Call cubit to delete the sale
      await context.read<MaterialSaleCubit>().deleteMaterialSale(_workingDocument.id!);

      _showSnackBar('Sale deleted successfully');

      // Navigate back to the list
      Navigator.pop(context, true); // Return true to indicate the list should refresh

    } catch (e) {
      debugPrint('❌ Failed to delete sale: $e');
      _showSnackBar('Failed to delete sale: ${e.toString()}');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _clearCustomerFields() {
    setState(() {
      _customerNameController.clear();
      _customerAddressController.clear();
      // Keep phone number for potential re-search
    });
    _showSnackBar('Customer fields cleared');
    debugPrint('🧹 Customer fields cleared');
  }

  Future<void> _searchCustomerByPhone() async {
    final phoneNumber = _customerPhoneController.text.trim();

    if (phoneNumber.isEmpty) {
      _showSnackBar('Please enter a phone number to search');
      return;
    }

    // Validate phone number format - exactly 10 digits for Sri Lankan numbers
    final phoneRegex = RegExp(r'^(\+94|0)[0-9]{9}$');
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), ''); // Remove non-digits

    if (!phoneRegex.hasMatch(phoneNumber) || cleanPhone.length != 10) {
      _showSnackBar('Please enter a valid 10-digit Sri Lankan phone number');
      return;
    }

    setState(() {
      _isSearchingCustomer = true;
    });

    try {
      // Get auth token
      final authState = context.read<AuthCubit>().state;
      final token = authState is AuthAuthenticated ? authState.token : null;

      if (token == null) {
        throw Exception('Authentication required');
      }

      // Call API to search customer
      final materialSaleCubit = context.read<MaterialSaleCubit>();
      final response = await materialSaleCubit.searchCustomerByPhone(phoneNumber, token: token);

      // Check if customer was found
      final customerData = response['data'];

      if (customerData != null) {
        // Existing customer found - populate details
        setState(() {
          _customerNameController.text = customerData['name'] ?? '';
          _customerAddressController.text = customerData['address'] ?? '';
        });

        _showSnackBar('Customer details loaded successfully');
        debugPrint('👤 Customer found: ${customerData['name']} for phone: $phoneNumber');
      } else {
        // No customer found - show message for new customer entry
        _showSnackBar('Customer not found. Please enter details for a new customer.');
        debugPrint('❌ No customer found for phone: $phoneNumber');
      }
    } catch (e) {
      _showSnackBar('Failed to search customer: ${e.toString()}');
      debugPrint('❌ Customer search error: $e');
    } finally {
      setState(() {
        _isSearchingCustomer = false;
      });
    }
  }

  Map<String, String>? _getMockCustomerData(String phoneNumber) {
    // Mock customer database - replace with actual API call
    final mockCustomers = {
      '0771234567': {
        'name': 'John Smith',
        'address': '456 Oak Street, Colombo 05',
      },
      '0772345678': {
        'name': 'Sarah Johnson',
        'address': '789 Pine Avenue, Colombo 03',
      },
      '0773456789': {
        'name': 'Mike Wilson',
        'address': '321 Elm Road, Colombo 07',
      },
      '0711234567': {
        'name': 'Priya Fernando',
        'address': '123 Lotus Lane, Nugegoda',
      },
      '0769876543': {
        'name': 'Rajesh Kumar',
        'address': '456 Temple Road, Kandy',
      },
    };

    return mockCustomers[phoneNumber];
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Customer Section
              MSCustomerSection(
                nameController: _customerNameController,
                phoneController: _customerPhoneController,
                addressController: _customerAddressController,
                isEditable: _isEditable,
                isSearching: _isSearchingCustomer,
                onSearchByPhone: _searchCustomerByPhone,
                onClearFields: _clearCustomerFields,
              ),
              const SizedBox(height: 24),

              // Product Section
              MSProductSection(
                items: _workingDocument.items,
                isEditable: _isEditable,
                onAddItem: () {
                  setState(() {
                    _workingDocument.items.add(MaterialSaleItem());
                    _hasUnsavedChanges = true;
                  });
                },
                onRemoveItem: (index) {
                  setState(() {
                    _workingDocument.items.removeAt(index);
                    _hasUnsavedChanges = true;
                  });
                },
                onItemChanged: (index, item) {
                  setState(() {
                    _workingDocument.items[index] = item;
                    _hasUnsavedChanges = true;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Payment Section
              MSPaymentSection(
                totalAmount: _workingDocument.totalAmount,
                amountDue: _workingDocument.amountDue,
                paymentHistory: _workingDocument.paymentHistory,
                isEditable: _isEditable,
                onAddPayment: _isNewDocument ? _recordPayment : null,
                onRecordFinalPayment: !_isNewDocument ? _showDuePaymentDialog : null,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              if (_isNewDocument)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isValidForCreation ? _createSale : null,
                        child: const Text('Create Sale'),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showSummary,
                            icon: const Icon(Icons.summarize),
                            label: const Text('Summary'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showPreview,
                            icon: const Icon(Icons.preview),
                            label: const Text('Preview'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _mockPrint,
                            icon: const Icon(Icons.print),
                            label: const Text('Print'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Delete button - ONLY for PENDING status with no payments
                    if (_canDelete)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _confirmDelete,
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          label: const Text('Delete Sale', style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_hasUnsavedChanges && !_isSaving && _isEditable) ? _saveDocument : null,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(_isEditable ? 'Save' : 'Locked (Payment Recorded)'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isNewDocument ? 'Create Material Sale' : 'Material Sale Details',
      ),
      backgroundColor: _isNewDocument ? Colors.orange.shade600 : Colors.blue.shade700,
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
        if (_hasUnsavedChanges && !_isNewDocument)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Unsaved',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.store,
              color: Colors.blue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _workingDocument.invoiceNumber.isNotEmpty ? 'Invoice MS-${_workingDocument.invoiceNumber}' : 'New Material Sale Invoice',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(_workingDocument.saleDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Only show status badge in details mode (not create mode)
          if (!_isNewDocument) ...[
            // Lock indicator for non-editable documents
            if (!_isEditable)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.grey,
                  size: 16,
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor()),
              ),
              child: Text(
                _workingDocument.status.name.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_workingDocument.status) {
      case MaterialSaleStatus.pending:
        return Colors.orange;
      case MaterialSaleStatus.partial:
        return Colors.yellow.shade700;
      case MaterialSaleStatus.paid:
        return Colors.green;
      case MaterialSaleStatus.cancelled:
        return Colors.red;
    }
  }
}
