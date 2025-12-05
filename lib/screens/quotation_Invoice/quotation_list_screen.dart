// lib/screens/quotation_Invoice/quotation_list_screen.dart

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:tilework/data/material_sale_data.dart';
import 'package:tilework/data/mock_data.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';
import 'package:tilework/screens/quotation_Invoice/material_sale/material_sale_invoice_screen.dart';
import 'package:tilework/screens/quotation_Invoice/quotation_invoice_screen.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_list/project_tab_view/project_tab_view.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_list/material_sales_tab_view/material_sale_tab_view.dart';

class QuotationListScreen extends StatefulWidget {
  const QuotationListScreen({Key? key}) : super(key: key);

  @override
  State<QuotationListScreen> createState() => _QuotationListScreenState();
}

class _QuotationListScreenState extends State<QuotationListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  // ============================================
  // NAVIGATION METHODS
  // ============================================

  Future<void> _openDocument(QuotationDocument doc) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => QuotationInvoiceScreen(
          document: doc,
          isNewDocument: false,
        ),
      ),
    );

    if (result == true || result == null) {
      setState(() {});
    }
  }

  Future<void> _createNewQuotation() async {
    // Generate new document number
    int maxNum = mockDocuments.isEmpty
        ? 1500
        : mockDocuments
            .map((d) => int.tryParse(d.documentNumber) ?? 0)
            .reduce(max);
    final newNumber = (maxNum + 1).toString();

    // Create new document
    final newDoc = QuotationDocument(
      documentNumber: newNumber,
      customerName: '',
      customerPhone: '',
      customerAddress: '',
      projectTitle: '',
      invoiceDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      lineItems: [],
      paymentHistory: [],
      type: DocumentType.quotation,
      status: DocumentStatus.pending,
    );

    // Navigate to create screen
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => QuotationInvoiceScreen(
          document: newDoc,
          isNewDocument: true,
        ),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _openMaterialSaleDocument(MaterialSaleDocument doc) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MaterialSaleInvoiceScreen(
          document: doc,
          isNewDocument: false,
        ),
      ),
    );

    if (result == true || result == null) {
      setState(() {});
    }
  }

  Future<void> _createNewMaterialSale() async {
    // Generate new invoice number
    int maxNum = materialSaleDocuments.isEmpty
        ? 1000
        : materialSaleDocuments
            .map((d) => int.tryParse(d.invoiceNumber) ?? 0)
            .reduce(max);
    final newNumber = (maxNum + 1).toString();

    // Create new document
    final newDoc = MaterialSaleDocument(
      invoiceNumber: newNumber,
      saleDate: DateTime.now(),
      customerName: '',
      customerPhone: '',
      customerAddress: '',
      items: [],
      paymentHistory: [],
      status: MaterialSaleStatus.pending,
    );

    // Navigate to create screen
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MaterialSaleInvoiceScreen(
          document: newDoc,
          isNewDocument: true,
        ),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  void _showMaterialSaleComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Material Sale feature coming soon!'),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Project
          ProjectTabView(
            onCreateNew: _createNewQuotation,
            onDocumentTap: _openDocument,
          ),

          // Tab 2: Material Sale
          MaterialSaleTabView(
            onCreateNew: _createNewMaterialSale,
            onDocumentTap: _openMaterialSaleDocument,
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Document List'),
      backgroundColor: Colors.purple.shade700,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => setState(() {}),
          tooltip: 'Refresh',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: Colors.purple.shade700,
            unselectedLabelColor: Colors.white,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Project'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Material Sale'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    // Project Tab FAB
    if (_currentTabIndex == 0) {
      return FloatingActionButton.extended(
        heroTag: 'fab_project',
        onPressed: _createNewQuotation,
        label: const Text(
          'New Quotation',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.purple.shade700,
      );
    }

    // Material Sale Tab FAB
    return FloatingActionButton.extended(
      heroTag: 'fab_material_sale',
      onPressed: _createNewMaterialSale,
      label: const Text(
        'New Sale',
        style: TextStyle(color: Colors.white),
      ),
      icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
      backgroundColor: Colors.orange.shade600,
    );
  }
}
