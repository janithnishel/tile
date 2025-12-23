// lib/screens/quotation_Invoice/quotation_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/material_sale/material_sale_cubit.dart';
import 'package:tilework/cubits/quotation/quotation_cubit.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';
import 'package:tilework/repositories/material_sale/material_sale_repository.dart';
import 'package:tilework/repositories/quotation/quotation_repository.dart';
import 'package:tilework/screens/quotation_Invoice/material_sale/material_sale_invoice_screen.dart';
import 'package:tilework/screens/quotation_Invoice/quotation_invoice_screen.dart';
import 'package:tilework/services/material_sale/material_sale_api_service.dart';
import 'package:tilework/services/quotation/quotation_api_service.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/project_tab_view/project_tab_view.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/material_sales_tab_view/material_sale_tab_view.dart';

class QuotationListScreen extends StatefulWidget {
  const QuotationListScreen({Key? key}) : super(key: key);

  @override
  State<QuotationListScreen> createState() => _QuotationListScreenState();
}

class _QuotationListScreenState extends State<QuotationListScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(_onTabChanged);

    // Load quotations when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<QuotationCubit>().loadQuotations();
      }
    });
  }

  void _onTabChanged() {
    if (_tabController != null && !_tabController!.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController!.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController!.removeListener(_onTabChanged);
    _tabController!.dispose();
    super.dispose();
  }

  // Cubits are now provided globally in main.dart, no need to create local instances

  // Refresh callback for app bar
  void _refreshQuotations() {
    print('🔄 Manual refresh triggered - reloading quotations from backend...');
    context.read<QuotationCubit>().loadQuotations();
  }

  // ============================================
  // NAVIGATION METHODS
  // ============================================

  void _openDocument(QuotationDocument doc, QuotationCubit cubit) {
    debugPrint('📂 Opening document: ${doc.documentNumber} (${doc.type})');
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => QuotationInvoiceScreen(
          document: doc,
          isNewDocument: false,
        ),
      ),
    ).then((result) {
      debugPrint('📂 Document screen closed with result: $result');
      if (result == true || result == null) {
        // Refresh quotations list after editing
        debugPrint('🔄 Refreshing quotations list after editing...');
        cubit.loadQuotations();
      }
    }).catchError((error) {
      debugPrint('❌ Error opening document: $error');
    });
  }

  void _createNewQuotation(QuotationCubit cubit) {
    // Create new document with empty documentNumber for backend auto-generation
    final newDoc = QuotationDocument(
      documentNumber: '', // Backend will auto-generate this
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

    // Navigate to create screen with the same cubit instance
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider<QuotationCubit>.value(
          value: cubit, // Pass cubit instance
          child: QuotationInvoiceScreen(
            document: newDoc,
            isNewDocument: true,
          ),
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Force refresh quotations from API after successful creation
        debugPrint('🔄 Refreshing quotations list after creation...');
        cubit.loadQuotations();
      }
    });
  }

  void _openMaterialSaleDocument(MaterialSaleDocument doc, MaterialSaleCubit cubit) {
    debugPrint('📂 Opening material sale: ${doc.invoiceNumber}');
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MaterialSaleInvoiceScreen(
          document: doc,
          isNewDocument: false,
        ),
      ),
    ).then((result) {
      debugPrint('📂 Material sale screen closed with result: $result');
      if (result == true || result == null) {
        // Refresh material sales list after editing
        debugPrint('🔄 Refreshing material sales list after editing...');
        cubit.loadMaterialSales();
      }
    }).catchError((error) {
      debugPrint('❌ Error opening material sale: $error');
    });
  }

  void _createNewMaterialSale(MaterialSaleCubit cubit) {
    // Create new document with empty invoiceNumber for backend auto-generation
    final newDoc = MaterialSaleDocument(
      invoiceNumber: '', // Backend will auto-generate this
      saleDate: DateTime.now(),
      customerName: '',
      customerPhone: '',
      customerAddress: '',
      items: [],
      paymentHistory: [],
      status: MaterialSaleStatus.pending,
    );

    // Navigate to create screen with the same cubit instance
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider<MaterialSaleCubit>.value(
          value: cubit, // Pass cubit instance
          child: MaterialSaleInvoiceScreen(
            document: newDoc,
            isNewDocument: true,
          ),
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Force refresh material sales from API after successful creation
        debugPrint('🔄 Refreshing material sales list after creation...');
        cubit.loadMaterialSales();
      }
    });
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
    // Use global BlocProviders from main.dart instead of local ones
    final quotationCubit = context.read<QuotationCubit>();
    final materialSaleCubit = context.read<MaterialSaleCubit>();

    return Scaffold(
      appBar: _buildAppBar(quotationCubit),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Project
          ProjectTabView(
            onCreateNew: (cubit) => _createNewQuotation(cubit),
            onDocumentTap: (doc, cubit) => _openDocument(doc, cubit),
          ),

          // Tab 2: Material Sale
          MaterialSaleTabView(
            onCreateNew: (cubit) => _createNewMaterialSale(cubit),
            onDocumentTap: (doc, cubit) => _openMaterialSaleDocument(doc, cubit),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(quotationCubit, materialSaleCubit),
    );
  }

  PreferredSizeWidget _buildAppBar(QuotationCubit quotationCubit) {
    return AppBar(
      title: const Text('Document List'),
      backgroundColor: Colors.purple.shade700,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            print('🔄 Manual refresh triggered - reloading quotations from backend...');
            quotationCubit.loadQuotations();
          },
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

  Widget _buildBottomActionBar(QuotationCubit quotationCubit, MaterialSaleCubit materialSaleCubit) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: _currentTabIndex == 0
          ? _buildActionBarButton(
              key: const ValueKey('project_action_bar'),
              label: 'New Project',
              icon: Icons.add,
              color: Colors.purple.shade700,
              onPressed: () => _createNewQuotation(quotationCubit),
            )
          : _buildActionBarButton(
              key: const ValueKey('material_sale_action_bar'),
              label: 'New Sale',
              icon: Icons.add_shopping_cart,
              color: Colors.orange.shade600,
              onPressed: () => _createNewMaterialSale(materialSaleCubit),
            ),
    );
  }

  Widget _buildActionBarButton({
    required Key key,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      key: key,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white, size: 24),
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
      ),
    );
  }
}
