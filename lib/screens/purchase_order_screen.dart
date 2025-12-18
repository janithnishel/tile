// import 'package:flutter/material.dart';
// import 'package:tilework/data/po_mock_data.dart';
// import 'package:tilework/models/purchase_order_screen/purchase_order.dart';
// import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/create_po_dialog.dart';
// import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/order_summary_dialog.dart';
// import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/po_header_section.dart';
// import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/po_stats_row.dart';
// import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/supplier_expansion_tile.dart';
// import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/supplier_management_dialog.dart';

// class PurchaseOrderScreen extends StatefulWidget {
//   const PurchaseOrderScreen({Key? key}) : super(key: key);

//   @override
//   State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
// }

// class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {
//   String? _selectedQuotationId;
//   String _searchQuery = '';
//   String _statusFilter = 'All';

//   // Get filtered POs
//   List<PurchaseOrder> get _filteredOrders {
//     List<PurchaseOrder> list = mockPurchaseOrders;

//     // Filter by Quotation ID
//     if (_selectedQuotationId != null) {
//       list = list
//           .where((po) => po.quotationId == _selectedQuotationId)
//           .toList();
//     }

//     // Filter by Status
//     if (_statusFilter != 'All') {
//       list = list.where((po) => po.status == _statusFilter).toList();
//     }

//     // Search
//     if (_searchQuery.isNotEmpty) {
//       final query = _searchQuery.toLowerCase();
//       list = list.where((po) {
//         return po.poId.toLowerCase().contains(query) ||
//             po.supplier.name.toLowerCase().contains(query) ||
//             po.customerName.toLowerCase().contains(query) ||
//             po.items.any((item) => item.name.toLowerCase().contains(query));
//       }).toList();
//     }

//     return list;
//   }

//   // Group by Supplier
//   Map<String, List<PurchaseOrder>> get _groupedOrders {
//     final filtered = _filteredOrders;
//     final Map<String, List<PurchaseOrder>> grouped = {};

//     for (var po in filtered) {
//       final supplierName = po.supplier.name;
//       grouped.putIfAbsent(supplierName, () => []).add(po);
//     }

//     return grouped;
//   }

//   void _showOrderSummaryDialog(PurchaseOrder order) {
//     showDialog(
//       context: context,
//       builder: (context) => OrderSummaryDialog(
//         order: order,
//         onClose: () => Navigator.pop(context),
//         onPrint: () {
//           Navigator.pop(context);
//           _showSnackBar('Printing ${order.poId}...');
//         },
//         onEdit: () {
//           Navigator.pop(context);
//           _showSnackBar('Edit ${order.poId}');
//         },
//         onStatusUpdate: () {
//           setState(() {
//             order.status = order.nextStatus;
//           });
//           Navigator.pop(context);
//           _showSnackBar('${order.poId} status updated to ${order.status}');
//         },
//       ),
//     );
//   }

//   void _showCreatePODialog() {
//     showDialog(
//       context: context,
//       builder: (context) => CreatePODialog(
//         quotations: mockApprovedQuotations,
//         suppliers: mockSuppliers,
//         onCreate: (quotationId, supplier, items) {
//           _showSnackBar('Purchase Order created successfully!');
//         },
//       ),
//     );
//   }

//   void _showSupplierManagementDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => SupplierManagementDialog(
//         suppliers: mockSuppliers,
//         onAddNew: () {
//           _showSnackBar('Add new supplier');
//         },
//         onEdit: (supplier) {
//           _showSnackBar('Edit ${supplier.name}');
//         },
//         onDelete: (supplier) {
//           _showSnackBar('Delete ${supplier.name}');
//         },
//       ),
//     );
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       body: Column(
//         children: [
//           // Header Section
//           POHeaderSection(
//             selectedQuotationId: _selectedQuotationId,
//             searchQuery: _searchQuery,
//             statusFilter: _statusFilter,
//             quotations: mockApprovedQuotations,
//             onQuotationChanged: (value) {
//               setState(() => _selectedQuotationId = value);
//             },
//             onSearchChanged: (value) {
//               setState(() => _searchQuery = value);
//             },
//             onStatusFilterChanged: (value) {
//               setState(() => _statusFilter = value);
//             },
//             onClearSearch: () {
//               setState(() => _searchQuery = '');
//             },
//             onManageSuppliers: _showSupplierManagementDialog,
//           ),

//           // Stats Row
//           POStatsRow(orders: _filteredOrders),

//           // Main Content
//           Expanded(child: _buildMainContent()),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showCreatePODialog,
//         icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
//         label: const Text('New PO', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.indigo,
//       ),
//     );
//   }

//   Widget _buildMainContent() {
//     final groupedOrders = _groupedOrders;

//     if (groupedOrders.isEmpty) {
//       return _buildEmptyState();
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       itemCount: groupedOrders.keys.length,
//       itemBuilder: (context, index) {
//         final supplierName = groupedOrders.keys.elementAt(index);
//         final supplierOrders = groupedOrders[supplierName]!;
//         final supplier = supplierOrders.first.supplier;

//         return SupplierExpansionTile(
//           supplier: supplier,
//           orders: supplierOrders,
//           onOrderTap: _showOrderSummaryDialog,
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.shopping_cart_outlined,
//             size: 80,
//             color: Colors.grey.shade300,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No Purchase Orders Found',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Create a new PO from an approved quotation',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade500,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: _showCreatePODialog,
//             icon: const Icon(Icons.add),
//             label: const Text('Create Purchase Order'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.indigo,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 24,
//                 vertical: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/purchase_order/purchase_order_cubit.dart';
import 'package:tilework/cubits/quotation/quotation_cubit.dart';
import 'package:tilework/cubits/quotation/quotation_state.dart';
import 'package:tilework/cubits/supplier/supplier_cubit.dart';
import 'package:tilework/cubits/supplier/supplier_state.dart';
import 'package:tilework/data/po_mock_data.dart';
import 'package:tilework/models/purchase_order/approved_quotation.dart';
import 'package:tilework/models/purchase_order/po_item.dart';
import 'package:tilework/models/purchase_order/purchase_order.dart';
import 'package:tilework/models/purchase_order/quotation_item.dart';
import 'package:tilework/models/purchase_order/supplier.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/add_supplier_screen.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/create_po_screen.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/order_summary_dialog.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/po_header_section.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/po_stats_row.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/supplier_expansion_tile.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/supplier_management_screen.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen>
    with SingleTickerProviderStateMixin {
  // ============================================
  // TAB CONTROLLER
  // ============================================
  TabController? _tabController;
  int _currentTabIndex = 0;

  // ============================================
  // PROJECT PO FILTERS
  // ============================================
  String? _selectedQuotationId;
  String _searchQuery = '';
  String _statusFilter = 'All';

  // ============================================
  // APPROVED QUOTATIONS (loaded from API)
  // ============================================
  List<ApprovedQuotation> _approvedQuotations = [];
  bool _isLoadingQuotations = true;

  // ============================================
  // PURCHASE ORDERS (loaded from API)
  // ============================================
  List<PurchaseOrder> _purchaseOrders = [];
  bool _isLoadingPurchaseOrders = true;

  // ============================================
  // MATERIAL SALE PO FILTERS (for future use)
  // ============================================
  String _materialSearchQuery = '';
  String _materialStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(_onTabChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load approved quotations when context is available
    if (_isLoadingQuotations) {
      _loadApprovedQuotations();
    }
  }

  Future<void> _loadApprovedQuotations() async {
    try {
      final quotationCubit = context.read<QuotationCubit>();
      final purchaseOrderCubit = context.read<PurchaseOrderCubit>();

      // Load both quotations and purchase orders in parallel
      await Future.wait([
        quotationCubit.loadQuotations(queryParams: {'status': 'approved'}),
        purchaseOrderCubit.loadPurchaseOrders(),
      ]);

      // Update local state with loaded quotations
      if (mounted) {
        final quotationState = quotationCubit.state;
        final purchaseOrderState = purchaseOrderCubit.state;
        setState(() {
          _approvedQuotations = quotationState.quotations.map((doc) {
            return ApprovedQuotation(
              quotationId: doc.documentNumber,
              customerName: doc.customerName,
              projectTitle: doc.projectTitle,
              approvedDate: doc.invoiceDate,
              totalAmount: doc.subtotal,
              items: doc.lineItems.map((item) {
                return QuotationItem(
                  id: item.displayName,
                  name: item.displayName,
                  category: item.item.category,
                  quantity: item.quantity.toInt(),
                  unit: item.item.unit,
                  estimatedPrice: item.item.sellingPrice,
                  isOrdered: false,
                );
              }).toList(),
            );
          }).toList();
          _isLoadingQuotations = false;

          // Load purchase orders
          _purchaseOrders = purchaseOrderState.purchaseOrders;
          _isLoadingPurchaseOrders = false;
        });
      }
    } catch (e) {
      // On error, keep empty lists
      if (mounted) {
        setState(() {
          _approvedQuotations = [];
          _isLoadingQuotations = false;
          _purchaseOrders = [];
          _isLoadingPurchaseOrders = false;
        });
      }
    }
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
    if (_tabController != null) {
      _tabController!.removeListener(_onTabChanged);
      _tabController!.dispose();
    }
    super.dispose();
  }

  // ============================================
  // PROJECT PO FILTERS & GROUPING
  // ============================================

  List<PurchaseOrder> get _filteredOrders {
    // Use API-loaded purchase orders if available, otherwise fall back to mock data
    List<PurchaseOrder> list = _purchaseOrders.isNotEmpty ? _purchaseOrders : mockPurchaseOrders;

    // Filter by Quotation ID
    if (_selectedQuotationId != null) {
      list = list
          .where((po) => po.quotationId == _selectedQuotationId)
          .toList();
    }

    // Filter by Status
    if (_statusFilter != 'All') {
      list = list.where((po) => po.status == _statusFilter).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((po) {
        return po.poId.toLowerCase().contains(query) ||
            po.supplier.name.toLowerCase().contains(query) ||
            po.customerName.toLowerCase().contains(query) ||
            po.items.any((item) => item.name.toLowerCase().contains(query));
      }).toList();
    }

    return list;
  }

  Map<String, List<PurchaseOrder>> get _groupedOrders {
    final filtered = _filteredOrders;
    final Map<String, List<PurchaseOrder>> grouped = {};

    for (var po in filtered) {
      final supplierName = po.supplier.name;
      grouped.putIfAbsent(supplierName, () => []).add(po);
    }

    return grouped;
  }

  // ============================================
  // DIALOG METHODS
  // ============================================

  void _showOrderSummaryDialog(PurchaseOrder order) {
    showDialog(
      context: context,
      builder: (context) => OrderSummaryDialog(
        order: order,
        onClose: () => Navigator.pop(context),
        onPrint: () {
          Navigator.pop(context);
          _showSnackBar('Printing ${order.poId}...');
        },
        onEdit: () {
          Navigator.pop(context);
          _showSnackBar('Edit ${order.poId}');
        },
        onStatusUpdate: () {
          setState(() {
            order.status = order.nextStatus;
          });
          Navigator.pop(context);
          _showSnackBar('${order.poId} status updated to ${order.status}');
        },
      ),
    );
  }

  void _showCreatePODialog() async {
    // Load approved quotations and suppliers for the dropdowns
    try {
      final quotationCubit = context.read<QuotationCubit>();
      final supplierCubit = context.read<SupplierCubit>();

      // Load both quotations and suppliers in parallel
      await Future.wait([
        quotationCubit.loadQuotations(queryParams: {'status': 'approved'}),
        supplierCubit.loadSuppliers(),
      ]);
    } catch (e) {
      // Continue with empty lists if loading fails
    }

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<QuotationCubit, QuotationState>(
        builder: (context, quotationState) {
          return BlocBuilder<SupplierCubit, SupplierState>(
            builder: (context, supplierState) {
              // Convert QuotationDocument to ApprovedQuotation
              final approvedQuotations = quotationState.quotations.map((doc) {
                return ApprovedQuotation(
                  quotationId: doc.documentNumber,
                  customerName: doc.customerName,
                  projectTitle: doc.projectTitle,
                  approvedDate: doc.invoiceDate, // Using invoiceDate as approvedDate
                  totalAmount: doc.subtotal,
                  items: doc.lineItems.map((item) {
                    return QuotationItem(
                      id: item.displayName,
                      name: item.displayName,
                      category: item.item.category,
                      quantity: item.quantity.toInt(),
                      unit: item.item.unit,
                      estimatedPrice: item.item.sellingPrice,
                      isOrdered: false, // Assuming none are ordered yet
                    );
                  }).toList(),
                );
              }).toList();

              return CreatePODialog(
                quotations: approvedQuotations,
                suppliers: supplierState.suppliers, // Now using real suppliers from API
                onCreate: (quotationId, supplier, items) async {
                  try {
                    final purchaseOrderCubit = context.read<PurchaseOrderCubit>();

                    // Convert SelectedPOItem to POItem
                    final poItems = items.map((item) => POItem(
                      name: item.name,
                      quantity: item.quantity.toDouble(),
                      unit: item.unit,
                      unitPrice: item.price,
                    )).toList();

                    // Get quotation details for customer name
                    final selectedQuotation = approvedQuotations.firstWhere(
                      (q) => q.quotationId == quotationId,
                    );

                    // Create PurchaseOrder object
                    final purchaseOrder = PurchaseOrder(
                      poId: '', // Will be generated by backend
                      quotationId: quotationId,
                      customerName: selectedQuotation.customerName,
                      supplier: supplier,
                      orderDate: DateTime.now(),
                      expectedDelivery: DateTime.now().add(const Duration(days: 14)), // Default 14 days
                      status: 'Draft',
                      items: poItems,
                      notes: 'Created from quotation $quotationId',
                    );

                    // Create the PO via cubit
                    await purchaseOrderCubit.createPurchaseOrder(purchaseOrder);

                    // Reload purchase orders to show the new PO
                    await purchaseOrderCubit.loadPurchaseOrders();

                    if (mounted) {
                      final updatedState = purchaseOrderCubit.state;
                      setState(() {
                        _purchaseOrders = updatedState.purchaseOrders;
                      });
                    }

                    _showSnackBar('Purchase Order created successfully!');
                  } catch (e) {
                    _showSnackBar('Failed to create Purchase Order: ${e.toString()}');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateMaterialSalePODialog() {
    // TODO: Implement Material Sale PO creation dialog
    _showSnackBar('Material Sale PO creation coming soon!');
  }

  void _showSupplierManagementDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SupplierManagementScreen(),
      ),
    ).then((_) {
      // Refresh the screen when returning from supplier management
      // to reflect any changes made to suppliers
      setState(() {});
    });
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSupplierScreen(
        onAdd: _addSupplier,
      ),
    );
  }

  Future<void> _addSupplier(Supplier supplier) async {
    try {
      // Use the SupplierCubit to create supplier (categories are now preserved in the cubit)
      final supplierCubit = context.read<SupplierCubit>();
      final createdSupplier = await supplierCubit.createSupplier(supplier);

      // Add to mock data for immediate UI update
      mockSuppliers.add(createdSupplier);

      _showSnackBar('Supplier "${createdSupplier.name}" added successfully!');
    } catch (e) {
      _showSnackBar('Failed to add supplier: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Project POs
          _buildProjectPOContent(),

          // Tab 2: Material Sale POs
          _buildMaterialSalePOContent(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // ============================================
  // APP BAR WITH TAB BAR
  // ============================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Purchase Orders'),
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            setState(() {});
            _showSnackBar('Refreshing...');
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
            labelColor: Colors.indigo,
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

  // ============================================
  // TAB 1: PROJECT PO CONTENT (Existing UI)
  // ============================================

  Widget _buildProjectPOContent() {
    return Column(
      children: [
        // Header Section with real API data
        POHeaderSection(
          selectedQuotationId: _selectedQuotationId,
          searchQuery: _searchQuery,
          statusFilter: _statusFilter,
          quotations: _approvedQuotations,
          onQuotationChanged: (value) {
            setState(() => _selectedQuotationId = value);
          },
          onSearchChanged: (value) {
            setState(() => _searchQuery = value);
          },
          onStatusFilterChanged: (value) {
            setState(() => _statusFilter = value);
          },
          onClearSearch: () {
            setState(() => _searchQuery = '');
          },
          onManageSuppliers: _showSupplierManagementDialog,
        ),

        // Stats Row (existing)
        POStatsRow(orders: _filteredOrders),

        // Main Content (existing)
        Expanded(child: _buildMainContent()),
      ],
    );
  }

  Widget _buildMainContent() {
    final groupedOrders = _groupedOrders;

    if (groupedOrders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedOrders.keys.length,
      itemBuilder: (context, index) {
        final supplierName = groupedOrders.keys.elementAt(index);
        final supplierOrders = groupedOrders[supplierName]!;
        final supplier = supplierOrders.first.supplier;

        return SupplierExpansionTile(
          supplier: supplier,
          orders: supplierOrders,
          onOrderTap: _showOrderSummaryDialog,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Purchase Orders Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new PO from an approved quotation',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreatePODialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Purchase Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // TAB 2: MATERIAL SALE PO CONTENT
  // ============================================

  Widget _buildMaterialSalePOContent() {
    // TODO: Implement Material Sale PO content with real data
    // For now showing placeholder
    return _buildMaterialSaleEmptyState();
  }

  Widget _buildMaterialSaleEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Material Sale Purchase Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new PO for material sales',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateMaterialSalePODialog,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Create Material Sale PO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // FLOATING ACTION BUTTON
  // ============================================

  Widget? _buildFloatingActionButton() {
    // Project Tab FAB
    if (_currentTabIndex == 0) {
      return FloatingActionButton.extended(
        heroTag: 'fab_project_po',
        onPressed: _showCreatePODialog,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('New PO', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      );
    }

    // Material Sale Tab FAB
    return FloatingActionButton.extended(
      heroTag: 'fab_material_sale_po',
      onPressed: _showCreateMaterialSalePODialog,
      icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
      label: const Text('New Sale PO', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.orange.shade600,
    );
  }
}
