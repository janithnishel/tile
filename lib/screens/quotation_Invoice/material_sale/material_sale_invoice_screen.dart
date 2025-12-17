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

    try {
      // Create material sale using the cubit (calls backend API)
      await context.read<MaterialSaleCubit>().createMaterialSale(_workingDocument);

      _showSnackBar('Material Sale created successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Failed to create material sale: ${e.toString()}');
    }
  }

  void _saveDocument() {
    // Copy changes back
    widget.document.customerName = _customerNameController.text.trim();
    widget.document.customerPhone = _customerPhoneController.text.trim();
    widget.document.customerAddress = _customerAddressController.text.trim();
    widget.document.items = _workingDocument.items;
    widget.document.paymentHistory = _workingDocument.paymentHistory;
    widget.document.status = _workingDocument.status;

    setState(() {
      _hasUnsavedChanges = false;
    });

    _showSnackBar('Sale saved successfully!');
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

  void _addAdvancePayment() {
    MSPaymentDialog.show(
      context,
      amountDue: _workingDocument.amountDue,
      isAdvance: true,
      onPaymentRecorded: _onPaymentRecorded,
    );
  }

  void _recordFinalPayment() {
    MSPaymentDialog.show(
      context,
      amountDue: _workingDocument.amountDue,
      isAdvance: false,
      onPaymentRecorded: _onPaymentRecorded,
    );
  }

  void _onPaymentRecorded(PaymentRecord payment) {
    setState(() {
      _workingDocument.paymentHistory = List.from(_workingDocument.paymentHistory)..add(payment);

      // Update status based on payment
      if (_workingDocument.amountDue <= 0) {
        _workingDocument.status = MaterialSaleStatus.paid;
      } else if (_workingDocument.paymentHistory.isNotEmpty) {
        _workingDocument.status = MaterialSaleStatus.partial;
      }

      _hasUnsavedChanges = true;
    });

    _showSnackBar('Payment recorded successfully!');
  }

  void _showPreview() {
    MSPreviewDialog.show(context, _workingDocument);
  }

  void _mockPrint() {
    _showSnackBar('Simulating print of Material Sale Invoice #${_workingDocument.displayInvoiceNumber}...');
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
                onAddPayment: _isEditable ? _addAdvancePayment : null,
                onRecordFinalPayment: _isEditable && _workingDocument.amountDue > 0 ? _recordFinalPayment : null,
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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _hasUnsavedChanges ? _saveDocument : null,
                        child: const Text('Save'),
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
                  'Invoice MS-${_workingDocument.invoiceNumber}',
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
