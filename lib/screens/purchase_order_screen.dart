import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/purchase_order/purchase_order_cubit.dart';
import 'package:tilework/cubits/purchase_order/purchase_order_state.dart';
import 'package:tilework/cubits/quotation/quotation_cubit.dart';
import 'package:tilework/cubits/quotation/quotation_state.dart';
import 'package:tilework/cubits/supplier/supplier_cubit.dart';
import 'package:tilework/cubits/supplier/supplier_state.dart';

import 'package:tilework/models/purchase_order/approved_quotation.dart';
import 'package:tilework/models/purchase_order/po_item.dart';
import 'package:tilework/models/purchase_order/purchase_order.dart';
import 'package:tilework/models/purchase_order/quotation_item.dart';
import 'package:tilework/models/purchase_order/supplier.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';
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
  // SCAFFOLD KEY FOR SNACKBAR
  // ============================================
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ============================================
  // TAB CONTROLLER
  // ============================================
  TabController? _tabController;
  int _currentTabIndex = 0;

  // ============================================
  // PROJECT PO FILTERS
  // ============================================
  String? _selectedQuotationId;
  String? _selectedSupplierId;
  String _searchQuery = '';
  String _statusFilter = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  // ============================================
  // APPROVED QUOTATIONS (loaded from API)
  // ============================================
  List<ApprovedQuotation> _approvedQuotations = [];
  bool _isLoadingQuotations = true;

  // ============================================
  // SUPPLIERS (loaded from API)
  // ============================================
  List<Supplier> _suppliers = [];
  bool _isLoadingSuppliers = true;

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

    // Set default date range to current month
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
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
      final supplierCubit = context.read<SupplierCubit>();

      // Load quotations, purchase orders, and suppliers in parallel
      await Future.wait([
        quotationCubit.loadQuotations(queryParams: {'status': 'approved'}),
        purchaseOrderCubit.loadPurchaseOrders(),
        supplierCubit.loadSuppliers(),
      ]);

      // Update local state with loaded data
      if (mounted) {
        final quotationState = quotationCubit.state;
        final purchaseOrderState = purchaseOrderCubit.state;
        final supplierState = supplierCubit.state;
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

          // Load suppliers
          _suppliers = supplierState.suppliers;
          _isLoadingSuppliers = false;
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
          _suppliers = [];
          _isLoadingSuppliers = false;
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
    // Use API-loaded purchase orders
    List<PurchaseOrder> list = _purchaseOrders;

    // Filter by Date Range (Order Date)
    if (_startDate != null && _endDate != null) {
      list = list.where((po) {
        final orderDate = po.orderDate;
        return orderDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
               orderDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by Supplier ID
    if (_selectedSupplierId != null) {
      list = list
          .where((po) => po.supplier.id == _selectedSupplierId)
          .toList();
    }

    // Filter by Quotation ID
    if (_selectedQuotationId != null) {
      list = list
          .where((po) => po.quotationId == _selectedQuotationId)
          .toList();
    }

    // Filter by Status
    if (_statusFilter != 'All') {
      if (_statusFilter == 'Active') {
        list = list.where((po) => ['Ordered', 'Delivered', 'Paid'].contains(po.status)).toList();
      } else {
        list = list.where((po) => po.status == _statusFilter).toList();
      }
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

  void _showOrderSummaryDialog(PurchaseOrder order) async {
    // Load suppliers for the dialog
    try {
      final supplierCubit = context.read<SupplierCubit>();
      await supplierCubit.loadSuppliers();
    } catch (e) {
      // Continue with empty list if loading fails
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => BlocBuilder<SupplierCubit, SupplierState>(
        builder: (context, supplierState) => OrderSummaryDialog(
          order: order,
          suppliers: supplierState.suppliers,
          onClose: () => Navigator.pop(context),
          onOrderUpdated: (PurchaseOrder updatedOrder) {
            setState(() {
              // Update the order in the local list
              final index = _purchaseOrders.indexWhere((po) => po.id == updatedOrder.id);
              if (index != -1) {
                _purchaseOrders[index] = updatedOrder;
              }
            });
          },
          onStatusChanged: (String newStatus) async {
            await _updatePurchaseOrderStatus(order, newStatus);
          },
          onCancel: (order.isOrdered || order.isDelivered)
              ? () async {
                  final confirm = await _showCancelConfirmation(order);
                  if (confirm == true) {
                    await _updatePurchaseOrderStatus(order, 'Cancelled');
                  }
                }
              : null,
          onDelete: order.isDraft
              ? () async {
                  final confirm = await _showDeleteConfirmation(order);
                  if (confirm == true) {
                    await _deletePurchaseOrder(order);
                    Navigator.pop(context, 'deleted');
                  }
                }
              : null,
        ),
      ),
    );

    // Handle the result if needed
    if (result == 'deleted' || result == 'cancelled') {
      // Refresh the list
      _loadApprovedQuotations();
    }
  }

  void _showCreatePODialog() async {
    // Capture the screen context for snackbar
    final screenContext = context;

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

    Navigator.push(
      context,
      MaterialPageRoute(
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
                    approvedDate:
                        doc.invoiceDate, // Using invoiceDate as approvedDate
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
                  suppliers: supplierState
                      .suppliers, // Now using real suppliers from API
                  onCreate: (quotationId, supplier, items, expectedDeliveryDate) async {
                    try {
                      final purchaseOrderCubit = context
                          .read<PurchaseOrderCubit>();

                      // Convert SelectedPOItem to POItem
                      final poItems = items
                          .map(
                            (item) => POItem(
                              itemName: item.name,
                              quantity: item.quantity.toDouble(),
                              unit: item.unit,
                              unitPrice: item.price,
                            ),
                          )
                          .toList();

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
                        expectedDelivery: expectedDeliveryDate ?? DateTime.now().add(
                          const Duration(days: 14),
                        ), // Use selected date or default to 14 days
                        status: 'Draft',
                        items: poItems,
                        notes: 'Created from quotation $quotationId',
                      );

                      // Create the PO via cubit
                      await purchaseOrderCubit.createPurchaseOrder(
                        purchaseOrder,
                      );

                      // Reload purchase orders to show the new PO
                      await purchaseOrderCubit.loadPurchaseOrders();

                      if (mounted) {
                        final updatedState = purchaseOrderCubit.state;
                        setState(() {
                          _purchaseOrders = updatedState.purchaseOrders;
                        });
                      }

                      // Use screen context for snackbar
                      ScaffoldMessenger.of(screenContext).showSnackBar(
                        const SnackBar(
                          content: Text('Purchase Order created successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      if (context.mounted) Navigator.pop(context); // Close the page
                    } catch (e) {
                      // Use screen context for snackbar
                      ScaffoldMessenger.of(screenContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to create Purchase Order: ${e.toString()}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      if (context.mounted) Navigator.pop(context); // Close the page on error too
                    }
                  },
                );
              },
            );
          },
        ),
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
      MaterialPageRoute(builder: (context) => const SupplierManagementScreen()),
    ).then((_) {
      // Refresh the screen when returning from supplier management
      // to reflect any changes made to suppliers
      setState(() {});
    });
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSupplierScreen(onAdd: _addSupplier),
    );
  }

  Future<void> _addSupplier(Supplier supplier) async {
    try {
      // Use the SupplierCubit to create supplier (categories are now preserved in the cubit)
      final supplierCubit = context.read<SupplierCubit>();
      final createdSupplier = await supplierCubit.createSupplier(supplier);

      _showSnackBar('Supplier "${createdSupplier.name}" added successfully!');
    } catch (e) {
      _showSnackBar('Failed to add supplier: ${e.toString()}');
    }
  }

  Future<void> _printPurchaseOrder(PurchaseOrder order) async {
    // TODO: Implement printing with watermark for cancelled orders
    // If order.isCancelled, add "CANCELLED" watermark across the document
    // This prevents the printed PO from being reused
    _showSnackBar('Printing ${order.poId}...');
  }

  Future<void> _updatePurchaseOrderStatus(
    PurchaseOrder order,
    String newStatus,
  ) async {
    try {
      final purchaseOrderCubit = context.read<PurchaseOrderCubit>();
      await purchaseOrderCubit.updatePurchaseOrderStatus(order.id!, {
        'status': newStatus,
      });

      // Update local state
      setState(() {
        order.status = newStatus;
      });

      _showSnackBar('${order.poId} status updated to $newStatus');
    } catch (e) {
      _showSnackBar('Failed to update status: ${e.toString()}');
    }
  }

  Future<bool?> _showDeleteConfirmation(PurchaseOrder order) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchase Order'),
        content: Text(
          'Are you sure you want to delete ${order.poId}? This action cannot be undone.',
        ),
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
  }

  Future<void> _deletePurchaseOrder(PurchaseOrder order) async {
    try {
      final purchaseOrderCubit = context.read<PurchaseOrderCubit>();
      await purchaseOrderCubit.deletePurchaseOrder(order.id!);

      // Remove from local state
      setState(() {
        _purchaseOrders.removeWhere((po) => po.id == order.id);
      });

      _showSnackBar('${order.poId} deleted successfully');
    } catch (e) {
      _showSnackBar('Failed to delete PO: ${e.toString()}');
    }
  }

  Future<bool?> _showCancelConfirmation(PurchaseOrder order) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Purchase Order'),
        content: Text(
          'Are you sure you want to cancel ${order.poId}? This will mark it as cancelled but keep the record for audit purposes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel PO'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchaseOrderCubit, PurchaseOrderState>(
      listener: (context, state) {
        // Update local state when cubit state changes
        if (state.purchaseOrders.isNotEmpty) {
          setState(() {
            _purchaseOrders = state.purchaseOrders;
          });
        }
        if (state.errorMessage != null) {
          _showSnackBar('Error: ${state.errorMessage}');
        }
      },
      builder: (context, purchaseOrderState) {
        return Scaffold(
          key: _scaffoldKey,
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
      },
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
          selectedSupplierId: _selectedSupplierId,
          selectedQuotationId: _selectedQuotationId,
          searchQuery: _searchQuery,
          statusFilter: _statusFilter,
          startDate: _startDate,
          endDate: _endDate,
          quotations: _approvedQuotations,
          suppliers: _suppliers,
          onSupplierChanged: (value) {
            setState(() => _selectedSupplierId = value);
          },
          onQuotationChanged: (value) {
            setState(() => _selectedQuotationId = value);
          },
          onSearchChanged: (value) {
            setState(() => _searchQuery = value);
          },
          onStatusFilterChanged: (value) {
            setState(() => _statusFilter = value);
          },
          onDateRangeChanged: (start, end) {
            setState(() {
              _startDate = start;
              _endDate = end;
            });
          },
          onClearSearch: () {
            setState(() => _searchQuery = '');
          },
          onManageSuppliers: _showSupplierManagementDialog,
        ),

        // Stats Row (existing)
        POStatsRow(
          orders: _filteredOrders,
          onFilterChanged: (filter) => setState(() => _statusFilter = filter ?? 'All'),
        ),

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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreatePODialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Purchase Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          Icon(Icons.store_outlined, size: 80, color: Colors.grey.shade300),
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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateMaterialSalePODialog,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Create Material Sale PO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
