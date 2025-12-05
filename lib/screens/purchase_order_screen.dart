import 'package:flutter/material.dart';
import 'package:tilework/data/po_mock_data.dart';
import 'package:tilework/models/purchase_order_screen/purchase_order.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/create_po_dialog.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/order_summary_dialog.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/po_header_section.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/po_stats_row.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/supplier_expansion_tile.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/supplier_management_dialog.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {
  String? _selectedQuotationId;
  String _searchQuery = '';
  String _statusFilter = 'All';

  // Get filtered POs
  List<PurchaseOrder> get _filteredOrders {
    List<PurchaseOrder> list = mockPurchaseOrders;

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

  // Group by Supplier
  Map<String, List<PurchaseOrder>> get _groupedOrders {
    final filtered = _filteredOrders;
    final Map<String, List<PurchaseOrder>> grouped = {};

    for (var po in filtered) {
      final supplierName = po.supplier.name;
      grouped.putIfAbsent(supplierName, () => []).add(po);
    }

    return grouped;
  }

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

  void _showCreatePODialog() {
    showDialog(
      context: context,
      builder: (context) => CreatePODialog(
        quotations: mockApprovedQuotations,
        suppliers: mockSuppliers,
        onCreate: (quotationId, supplier, items) {
          _showSnackBar('Purchase Order created successfully!');
        },
      ),
    );
  }

  void _showSupplierManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => SupplierManagementDialog(
        suppliers: mockSuppliers,
        onAddNew: () {
          _showSnackBar('Add new supplier');
        },
        onEdit: (supplier) {
          _showSnackBar('Edit ${supplier.name}');
        },
        onDelete: (supplier) {
          _showSnackBar('Delete ${supplier.name}');
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header Section
          POHeaderSection(
            selectedQuotationId: _selectedQuotationId,
            searchQuery: _searchQuery,
            statusFilter: _statusFilter,
            quotations: mockApprovedQuotations,
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

          // Stats Row
          POStatsRow(orders: _filteredOrders),

          // Main Content
          Expanded(child: _buildMainContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePODialog,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('New PO', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
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
}