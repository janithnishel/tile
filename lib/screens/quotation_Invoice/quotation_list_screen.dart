// lib/screens/quotation_Invoice/quotation_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/material_sale/material_sale_cubit.dart';
import 'package:tilework/cubits/quotation/quotation_cubit.dart';
import 'package:tilework/data/material_sale_data.dart';
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

  // Create QuotationCubit with proper context access
  QuotationCubit _createQuotationCubit(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final token = (authCubit.state as AuthAuthenticated?)?.token;

    return QuotationCubit(
      QuotationRepository(
        QuotationApiService(),
        token,
      ),
      authCubit,
    )..loadQuotations();
  }

  // Create MaterialSaleCubit with proper context access
  MaterialSaleCubit _createMaterialSaleCubit(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final token = (authCubit.state as AuthAuthenticated?)?.token;

    return MaterialSaleCubit(
      MaterialSaleRepository(
        MaterialSaleApiService(),
        token,
      ),
      authCubit,
    );
  }

  // Refresh callback for app bar
  void _refreshQuotations() {
    print('🔄 Manual refresh triggered - reloading quotations from backend...');
    context.read<QuotationCubit>().loadQuotations();
  }

  // ============================================
  // NAVIGATION METHODS
  // ============================================

  void _openDocument(QuotationDocument doc, QuotationCubit cubit) {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider<QuotationCubit>.value(
          value: cubit,
          child: QuotationInvoiceScreen(
            document: doc,
            isNewDocument: false,
          ),
        ),
      ),
    ).then((result) {
      if (result == true || result == null) {
        // Refresh quotations list after editing
        cubit.loadQuotations();
      }
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
        // Refresh quotations from API after successful creation
        cubit.loadQuotations();
      }
    });
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => _createQuotationCubit(context),
        ),
        BlocProvider(
          create: (context) => _createMaterialSaleCubit(context),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Now context has access to both BlocProviders
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
                  onCreateNew: (cubit) => _createNewMaterialSale(),
                  onDocumentTap: (doc, cubit) => _openMaterialSaleDocument(doc),
                ),
              ],
            ),
            floatingActionButton: _buildFloatingActionButton(quotationCubit),
          );
        },
      ),
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

  Widget? _buildFloatingActionButton(QuotationCubit quotationCubit) {
    // Project Tab FAB
    if (_currentTabIndex == 0) {
      return FloatingActionButton.extended(
        heroTag: 'fab_project',
        onPressed: () => _createNewQuotation(quotationCubit),
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
