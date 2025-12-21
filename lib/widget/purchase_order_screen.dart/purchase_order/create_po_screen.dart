import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/purchase_order/approved_quotation.dart';
import 'package:tilework/models/purchase_order/quotation_item.dart';
import 'package:tilework/models/purchase_order/supplier.dart';
import 'package:tilework/models/purchase_order/supplier_item.dart';
import 'package:tilework/models/purchase_order/purchase_order.dart';
import 'package:tilework/models/purchase_order/po_item.dart';

// ========== LOCAL MODEL CLASSES ==========

class SelectedPOItem {
  final String id;
  final String name;
  final String category;
  int quantity;
  final String unit;
  double price;
  final double? lastPurchasePrice;
  final bool isFromQuotation;

  SelectedPOItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.price,
    this.lastPurchasePrice,
    this.isFromQuotation = false,
  });

  double get totalPrice => quantity * price;

  bool get isPriceHigherThanLast =>
      lastPurchasePrice != null && price > lastPurchasePrice!;

  double get priceDifferencePercentage {
    if (lastPurchasePrice == null || lastPurchasePrice == 0) return 0;
    return ((price - lastPurchasePrice!) / lastPurchasePrice!) * 100;
  }
}

// ========== EDIT PO DIALOG ==========

class EditPODialog extends StatefulWidget {
  final PurchaseOrder order;
  final List<Supplier> suppliers;
  final Function(PurchaseOrder updatedOrder) onUpdate;

  const EditPODialog({
    Key? key,
    required this.order,
    required this.suppliers,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<EditPODialog> createState() => _EditPODialogState();
}

class _EditPODialogState extends State<EditPODialog> {
  late PurchaseOrder _currentOrder;
  late List<SelectedPOItem> _selectedItems;
  late String _selectedQuotationId;
  late Supplier _selectedSupplier;

  void _onSupplierChanged(Supplier? supplier) {
    if (supplier != null) {
      setState(() {
        _selectedSupplier = supplier;
      });
    }
  }

  // Controllers
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _selectedQuotationId = _currentOrder.quotationId;
    // Find the matching supplier from the loaded suppliers list
    _selectedSupplier = widget.suppliers.firstWhere(
      (s) => s.id == _currentOrder.supplier.id,
      orElse: () => _currentOrder.supplier, // Fallback to order supplier if not found
    );
    _initializeSelectedItems();
  }

  void _initializeSelectedItems() {
    _selectedItems = _currentOrder.items.map((item) {
      final controllerId = item.id ?? item.itemName;
      _initializeItemControllers(controllerId, item.quantity.toInt(), item.unitPrice);
      return SelectedPOItem(
        id: item.id ?? item.itemName,
        name: item.itemName,
        category: item.category ?? 'Other',
        quantity: item.quantity.toInt(),
        unit: item.unit ?? 'pcs',
        price: item.unitPrice,
        isFromQuotation: true,
      );
    }).toList();
  }

  void _initializeItemControllers(String id, int qty, double price) {
    _quantityControllers[id] = TextEditingController(text: qty.toString());
    _priceControllers[id] = TextEditingController(text: price.toString());
  }

  void _updateQuantity(String id, int delta) {
    final controller = _quantityControllers[id];
    if (controller == null) return;

    int currentQty = int.tryParse(controller.text) ?? 0;
    int newQty = (currentQty + delta).clamp(1, 99999);

    controller.text = newQty.toString();

    final itemIndex = _selectedItems.indexWhere((item) => item.id == id);
    if (itemIndex != -1) {
      setState(() {
        _selectedItems[itemIndex].quantity = newQty;
      });
    }
  }

  void _updatePrice(String id, String priceText) {
    final itemIndex = _selectedItems.indexWhere((item) => item.id == id);
    if (itemIndex != -1) {
      setState(() {
        _selectedItems[itemIndex].price = double.tryParse(priceText) ?? 0;
      });
    }
  }

  double get _totalAmount {
    return _selectedItems.fold(0.0, (sum, item) {
      final qty = int.tryParse(_quantityControllers[item.id]?.text ?? '') ?? item.quantity;
      return sum + (qty * item.price);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Purchase Order - ${_currentOrder.poId}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildContent()),
          _buildTotalSection(),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Section
          _buildStepSection(
            step: 1,
            title: 'Purchase Order Details',
            icon: Icons.info_outline,
            child: _buildOrderDetails(),
          ),

          const SizedBox(height: 20),

          // Items Section
          _buildStepSection(
            step: 2,
            title: 'Order Items',
            subtitle: 'Edit quantities and prices',
            icon: Icons.inventory_2_rounded,
            child: _buildItemsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('PO ID', _currentOrder.poId),
          const SizedBox(height: 8),
          // Supplier selector (editable)
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(width: 120, child: Text('Supplier:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
              Expanded(
                child: DropdownButton<Supplier>(
                  value: _selectedSupplier,
                  isExpanded: true,
                  hint: const Text('Select supplier'),
                  items: widget.suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                  onChanged: (s) => _onSupplierChanged(s),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Customer', _currentOrder.customerName),
          const SizedBox(height: 8),
          _buildDetailRow('Order Date', DateFormat('d MMMM yyyy').format(_currentOrder.orderDate)),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(width: 120, child: Text('Expected Delivery:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
              Expanded(
                  child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: _currentOrder.expectedDelivery, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (picked != null) setState(() => _currentOrder = _currentOrder.copyWith(expectedDelivery: picked));
                  },
                  child: Text(
                    _currentOrder.expectedDelivery != null ? DateFormat('d MMMM yyyy').format(_currentOrder.expectedDelivery!) : DateFormat('d MMMM yyyy').format(DateTime.now().add(const Duration(days: 7))),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text('$label:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildItemsList() {
    return Column(
      children: _selectedItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return _buildEditableItemCard(item, index);
      }).toList(),
    );
  }

  Widget _buildEditableItemCard(SelectedPOItem item, int index) {
    final controller = _priceControllers[item.id];
    final currentPrice = double.tryParse(controller?.text ?? '') ?? item.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selection checkbox (always selected in edit mode)
              Checkbox(
                value: true,
                onChanged: null, // Disabled in edit mode
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quantity & Price Row
          Row(
            children: [
              // Quantity Control
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _updateQuantity(item.id, -1),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(9),
                            bottomLeft: Radius.circular(9),
                          ),
                        ),
                        child: Icon(Icons.remove, size: 18, color: Colors.grey.shade700),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _quantityControllers[item.id],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        enabled: true,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        onChanged: (value) {
                          final qty = int.tryParse(value) ?? 0;
                          setState(() {
                            item.quantity = qty;
                          });
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () => _updateQuantity(item.id, 1),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(9),
                            bottomRight: Radius.circular(9),
                          ),
                        ),
                        child: Icon(Icons.add, size: 18, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(item.unit, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _priceControllers[item.id],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Unit Price',
                    prefixText: 'Rs ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => _updatePrice(item.id, value),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Rs ${_formatCurrency(_calculateItemTotal(item))}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateItemTotal(SelectedPOItem item) {
    final qty = int.tryParse(_quantityControllers[item.id]?.text ?? '') ?? item.quantity;
    final price = double.tryParse(_priceControllers[item.id]?.text ?? '') ?? item.price;
    return qty * price;
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        border: Border(
          top: BorderSide(color: Colors.indigo.shade100),
          bottom: BorderSide(color: Colors.indigo.shade100),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_rounded, size: 18, color: Colors.indigo.shade700),
                const SizedBox(width: 8),
                Text(
                  '${_selectedItems.length} items',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'TOTAL AMOUNT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rs ${_formatCurrency(_totalAmount)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _handleUpdate,
            icon: const Icon(Icons.save),
            label: const Text('Update PO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpdate() async {
    try {
      // Update items with current values
      final updatedItems = _selectedItems.map((item) {
        final qty = int.tryParse(_quantityControllers[item.id]?.text ?? '') ?? item.quantity;
        final price = double.tryParse(_priceControllers[item.id]?.text ?? '') ?? item.price;

        return POItem(
          id: item.id,
          itemName: item.name,
          quantity: qty.toDouble(),
          unit: item.unit,
          unitPrice: price,
          category: item.category,
        );
      }).toList();

      final updatedOrder = _currentOrder.copyWith(items: updatedItems);

      // Call the update callback
      widget.onUpdate(updatedOrder);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Purchase Order updated successfully!')
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Text('Failed to update PO: $e')
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildStepSection({
    required int step,
    required String title,
    String? subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    for (var c in _quantityControllers.values) {
      c.dispose();
    }
    for (var c in _priceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}

// ========== MAIN DIALOG ==========

class CreatePODialog extends StatefulWidget {
  final List<ApprovedQuotation> quotations;
  final List<Supplier> suppliers;
  final Function(String quotationId, Supplier supplier, List<SelectedPOItem> items, DateTime? expectedDeliveryDate) onCreate;

  const CreatePODialog({
    Key? key,
    required this.quotations,
    required this.suppliers,
    required this.onCreate,
  }) : super(key: key);

  @override
  State<CreatePODialog> createState() => _CreatePODialogState();
}

class _CreatePODialogState extends State<CreatePODialog> with TickerProviderStateMixin {
  // Selection State
  String? _selectedQuotationId;
  Supplier? _selectedSupplier;
  DateTime? _expectedDeliveryDate;

  // Items
  List<QuotationItem> _quotationItems = [];
  List<SupplierItem> _additionalItems = [];

  // Selected Items Map
  final Map<String, SelectedPOItem> _selectedItems = {};

  // Controllers
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};

  // Category Filter
  String _selectedCategory = 'All';
  List<String> _availableCategories = ['All'];

  // UI State
  bool _showAdditionalItems = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _expectedDeliveryDate = DateTime.now().add(const Duration(days: 7));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var c in _quantityControllers.values) {
      c.dispose();
    }
    for (var c in _priceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ========== QUOTATION CHANGE ==========
  void _onQuotationChanged(String? value) {
    setState(() {
      _selectedQuotationId = value;
      _selectedSupplier = null;
      _selectedItems.clear();
      
      for (var c in _quantityControllers.values) {
        c.dispose();
      }
      for (var c in _priceControllers.values) {
        c.dispose();
      }
      _quantityControllers.clear();
      _priceControllers.clear();

      if (value != null) {
        final quotation = widget.quotations.firstWhere((q) => q.quotationId == value);
        _quotationItems = quotation.availableItems.where((item) => item.category != 'Services').toList();

        for (var item in _quotationItems) {
          _initializeItemControllers(item.id, item.quantity, item.estimatedPrice);

          _selectedItems[item.id] = SelectedPOItem(
            id: item.id,
            name: item.name,
            category: item.category,
            quantity: item.quantity,
            unit: item.unit,
            price: item.estimatedPrice,
            lastPurchasePrice: item.lastPurchasePrice,
            isFromQuotation: true,
          );
        }

        _updateCategories();
        _animationController.forward();
      }
    });
  }

  // ========== SUPPLIER CHANGE ==========
  void _onSupplierChanged(Supplier? supplier) {
    setState(() {
      _selectedSupplier = supplier;
      _additionalItems = supplier?.availableItems ?? [];

      for (var item in _additionalItems) {
        if (!_quantityControllers.containsKey(item.id)) {
          _initializeItemControllers(item.id, 1, item.price);
        }
      }

      _updateCategories();
    });
  }

  void _initializeItemControllers(String id, int qty, double price) {
    _quantityControllers[id] = TextEditingController(text: qty.toString());
    _priceControllers[id] = TextEditingController(text: ''); // Leave price empty for user input
  }

  void _updateCategories() {
    final categories = <String>{'All'};
    for (var item in _quotationItems) {
      categories.add(item.category);
    }
    for (var item in _additionalItems) {
      categories.add(item.category);
    }
    _availableCategories = categories.toList();
  }

  // ========== TOGGLE ITEM SELECTION ==========
  void _toggleItemSelection(String id, {
    required String name,
    required String category,
    required int quantity,
    required String unit,
    required double price,
    double? lastPurchasePrice,
    bool isFromQuotation = false,
  }) {
    setState(() {
      if (_selectedItems.containsKey(id)) {
        _selectedItems.remove(id);
      } else {
        _selectedItems[id] = SelectedPOItem(
          id: id,
          name: name,
          category: category,
          quantity: int.tryParse(_quantityControllers[id]?.text ?? '') ?? quantity,
          unit: unit,
          price: double.tryParse(_priceControllers[id]?.text ?? '') ?? price,
          lastPurchasePrice: lastPurchasePrice,
          isFromQuotation: isFromQuotation,
        );
      }
    });
  }

  // ========== UPDATE QUANTITY ==========
  void _updateQuantity(String id, int delta) {
    final controller = _quantityControllers[id];
    if (controller == null) return;

    int currentQty = int.tryParse(controller.text) ?? 0;
    int newQty = (currentQty + delta).clamp(1, 99999);

    controller.text = newQty.toString();

    if (_selectedItems.containsKey(id)) {
      setState(() {
        _selectedItems[id]!.quantity = newQty;
      });
    }
  }

  // ========== UPDATE PRICE ==========
  void _updatePrice(String id, String priceText) {
    if (_selectedItems.containsKey(id)) {
      setState(() {
        _selectedItems[id]!.price = double.tryParse(priceText) ?? 0;
      });
    }
  }

  // ========== CALCULATE TOTAL ==========
  double get _totalAmount {
    return _selectedItems.values.fold(0.0, (sum, item) {
      final qty = int.tryParse(_quantityControllers[item.id]?.text ?? '') ?? item.quantity;
      final price = double.tryParse(_priceControllers[item.id]?.text ?? '') ?? item.price;
      return sum + (qty * price);
    });
  }

  int get _selectedItemCount => _selectedItems.length;

  bool get _canCreate =>
      _selectedQuotationId != null &&
      _selectedSupplier != null &&
      _selectedItems.isNotEmpty;

  // ========== BUILD ==========
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Purchase Order'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildContent()),
          _buildTotalSection(),
          _buildFooter(context),
        ],
      ),
    );
  }

  // ========== HEADER ==========
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade800],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Purchase Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedItemCount > 0)
                  Text(
                    '$_selectedItemCount items selected • Rs ${_formatCurrency(_totalAmount)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  // ========== CONTENT ==========
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 1: Select Quotation
          _buildStepSection(
            step: 1,
            title: 'Select Approved Quotation',
            icon: Icons.description_outlined,
            child: _buildQuotationDropdown(),
          ),

          if (_selectedQuotationId != null) ...[
            const SizedBox(height: 20),

            // Step 2: Select Supplier
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildStepSection(
                step: 2,
                title: 'Select Supplier',
                icon: Icons.business_outlined,
                child: _buildSupplierDropdown(),
              ),
            ),

            if (_selectedSupplier != null) ...[
              const SizedBox(height: 20),

              // Step 3: Expected Delivery Date
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildStepSection(
                  step: 3,
                  title: 'Expected Delivery Date',
                  subtitle: 'Select the expected delivery date',
                  icon: Icons.calendar_today,
                  child: _buildDeliveryDatePicker(),
                ),
              ),

              const SizedBox(height: 20),
            ],

            // Category Filter Chips
            if (_availableCategories.length > 1) ...[
              _buildCategoryChips(),
              const SizedBox(height: 16),
            ],

            // Step 3: Quotation Items (Auto-selected)
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildStepSection(
                step: 3,
                title: 'Quotation Items',
                subtitle: 'These items are auto-selected from the quotation',
                icon: Icons.check_circle_outline,
                headerAction: _buildSelectAllButton(),
                child: _buildQuotationItemsList(),
              ),
            ),

            // Additional Items Section
            if (_selectedSupplier != null && _additionalItems.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildAdditionalItemsSection(),
            ],
          ],
        ],
      ),
    );
  }

  // ========== STEP SECTION ==========
  Widget _buildStepSection({
    required int step,
    required String title,
    String? subtitle,
    required IconData icon,
    required Widget child,
    Widget? headerAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              if (headerAction != null) headerAction,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ========== DELIVERY DATE PICKER ==========
  Widget _buildDeliveryDatePicker() {
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _expectedDeliveryDate ?? DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.indigo,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          setState(() {
            _expectedDeliveryDate = pickedDate;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.indigo.shade400, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expected Delivery Date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(_expectedDeliveryDate!),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  // ========== QUOTATION DROPDOWN - 🔧 FIXED ==========
  Widget _buildQuotationDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedQuotationId,
      isExpanded: true, // 🔧 FIX: Added isExpanded
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.description, color: Colors.indigo.shade400),
        hintText: 'Choose an approved quotation...',
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: widget.quotations.map((q) {
        return DropdownMenuItem(
          value: q.quotationId,
          // 🔧 FIX: Use Text with overflow instead of Row with Expanded
          child: Text(
            '${q.displayName} (${q.availableItems.length} items)',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _onQuotationChanged,
      // 🔧 FIX: Custom selected item builder
      selectedItemBuilder: (context) {
        return widget.quotations.map((q) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${q.displayName} (${q.availableItems.length} items)',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
    );
  }

  // ========== SUPPLIER DROPDOWN - 🔧 FIXED ==========
  Widget _buildSupplierDropdown() {
    return DropdownButtonFormField<Supplier>(
      value: _selectedSupplier,
      isExpanded: true, // 🔧 FIX: Added isExpanded
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.business, color: Colors.indigo.shade400),
        hintText: 'Choose a supplier...',
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: widget.suppliers.map((s) {
        return DropdownMenuItem(
          value: s,
          // 🔧 FIX: Show all categories instead of just first one
          child: Text(
            '${s.name} - ${s.categoriesDisplayText}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _onSupplierChanged,
      // 🔧 FIX: Custom selected item builder for better display
      selectedItemBuilder: (context) {
        return widget.suppliers.map((s) {
          return Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.indigo.shade100,
                child: Text(
                  s.initials,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s.categoriesDisplayText,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        }).toList();
      },
    );
  }

  // ========== CATEGORY CHIPS ==========
  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _availableCategories.map((category) {
          final isSelected = _selectedCategory == category;
          final itemCount = category == 'All'
              ? _quotationItems.length + _additionalItems.length
              : _quotationItems.where((i) => i.category == category).length +
                _additionalItems.where((i) => i.category == category).length;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$itemCount',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.indigo : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: Colors.indigo.shade100,
              checkmarkColor: Colors.indigo,
              backgroundColor: Colors.grey.shade100,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ========== SELECT ALL BUTTON ==========
  Widget _buildSelectAllButton() {
    final allSelected = _quotationItems.isNotEmpty && 
        _quotationItems.every((item) => _selectedItems.containsKey(item.id));

    return TextButton.icon(
      onPressed: _quotationItems.isEmpty ? null : () {
        setState(() {
          if (allSelected) {
            for (var item in _quotationItems) {
              _selectedItems.remove(item.id);
            }
          } else {
            for (var item in _quotationItems) {
              if (!_selectedItems.containsKey(item.id)) {
                _selectedItems[item.id] = SelectedPOItem(
                  id: item.id,
                  name: item.name,
                  category: item.category,
                  quantity: int.tryParse(_quantityControllers[item.id]?.text ?? '') ?? item.quantity,
                  unit: item.unit,
                  price: double.tryParse(_priceControllers[item.id]?.text ?? '') ?? item.estimatedPrice,
                  lastPurchasePrice: item.lastPurchasePrice,
                  isFromQuotation: true,
                );
              }
            }
          }
        });
      },
      icon: Icon(
        allSelected ? Icons.deselect : Icons.select_all,
        size: 18,
      ),
      label: Text(allSelected ? 'Deselect All' : 'Select All'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.indigo,
      ),
    );
  }

  // ========== QUOTATION ITEMS LIST ==========
  Widget _buildQuotationItemsList() {
    final filteredItems = _selectedCategory == 'All'
        ? _quotationItems
        : _quotationItems.where((i) => i.category == _selectedCategory).toList();

    if (filteredItems.isEmpty) {
      return _buildEmptyState('No items in this category');
    }

    return Column(
      children: filteredItems.map((item) => _buildItemCard(
        id: item.id,
        name: item.name,
        category: item.category,
        quantity: item.quantity,
        unit: item.unit,
        price: item.estimatedPrice,
        lastPurchasePrice: item.lastPurchasePrice,
        lastPurchaseDate: item.lastPurchaseDate,
        isFromQuotation: true,
      )).toList(),
    );
  }

  // ========== ADDITIONAL ITEMS SECTION ==========
  Widget _buildAdditionalItemsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _showAdditionalItems = !_showAdditionalItems;
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Items from Supplier',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      Text(
                        '${_additionalItems.length} more items available',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _showAdditionalItems ? Icons.expand_less : Icons.expand_more,
                  color: Colors.orange.shade700,
                ),
              ],
            ),
          ),
          if (_showAdditionalItems) ...[
            const SizedBox(height: 16),
            ..._getFilteredAdditionalItems().map((item) => _buildItemCard(
              id: item.id,
              name: item.name,
              category: item.category,
              quantity: 1,
              unit: item.unit,
              price: item.price,
              lastPurchasePrice: item.lastPurchasePrice,
              isFromQuotation: false,
            )),
          ],
        ],
      ),
    );
  }

  List<SupplierItem> _getFilteredAdditionalItems() {
    if (_selectedCategory == 'All') return _additionalItems;
    return _additionalItems.where((i) => i.category == _selectedCategory).toList();
  }

  // ========== ITEM CARD - 🔧 FIXED LAYOUT ==========
  Widget _buildItemCard({
    required String id,
    required String name,
    required String category,
    required int quantity,
    required String unit,
    required double price,
    double? lastPurchasePrice,
    String? lastPurchaseDate,
    required bool isFromQuotation,
  }) {
    final isSelected = _selectedItems.containsKey(id);
    final controller = _priceControllers[id];
    final currentPrice = double.tryParse(controller?.text ?? '') ?? price;
    final isPriceHigher = lastPurchasePrice != null && currentPrice > lastPurchasePrice;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            ? (isFromQuotation ? Colors.indigo.shade50 : Colors.orange.shade50)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? (isFromQuotation ? Colors.indigo.shade300 : Colors.orange.shade300)
              : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleItemSelection(
                    id,
                    name: name,
                    category: category,
                    quantity: quantity,
                    unit: unit,
                    price: price,
                    lastPurchasePrice: lastPurchasePrice,
                    isFromQuotation: isFromQuotation,
                  ),
                  activeColor: isFromQuotation ? Colors.indigo : Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Item Name & Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        if (isFromQuotation)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, size: 10, color: Colors.green.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  'From Quotation',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quantity & Price Row - 🔧 FIXED: Made responsive
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // For smaller screens, use column layout
                if (constraints.maxWidth < 400) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuantityControl(id, isSelected),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(unit, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          const Spacer(),
                          SizedBox(
                            width: 120,
                            child: _buildPriceField(id, isSelected, isPriceHigher),
                          ),
                        ],
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 8),
                        _buildItemTotal(id),
                      ],
                    ],
                  );
                }
                
                // For larger screens, use row layout
                return Row(
                  children: [
                    _buildQuantityControl(id, isSelected),
                    const SizedBox(width: 8),
                    Text(unit, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 120,
                      child: _buildPriceField(id, isSelected, isPriceHigher),
                    ),
                    const Spacer(),
                    if (isSelected) _buildItemTotal(id),
                  ],
                );
              },
            ),
          ),

          // Last Purchase Price Warning
          if (isPriceHigher && isSelected) ...[
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 44),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price is ${((currentPrice - lastPurchasePrice!) / lastPurchasePrice! * 100).toStringAsFixed(1)}% higher than last purchase',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Last price: Rs ${_formatCurrency(lastPurchasePrice)}${lastPurchaseDate != null ? ' ($lastPurchaseDate)' : ''}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (lastPurchasePrice != null && isSelected) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Row(
                children: [
                  Icon(Icons.history, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    'Last purchase: Rs ${_formatCurrency(lastPurchasePrice)}${lastPurchaseDate != null ? ' ($lastPurchaseDate)' : ''}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 🔧 NEW: Extracted quantity control widget
  Widget _buildQuantityControl(String id, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus Button
          InkWell(
            onTap: isSelected ? () => _updateQuantity(id, -1) : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey.shade100 : Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(9),
                  bottomLeft: Radius.circular(9),
                ),
              ),
              child: Icon(
                Icons.remove,
                size: 18,
                color: isSelected ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
            ),
          ),

          // Quantity Field
          SizedBox(
            width: 50,
            child: TextField(
              controller: _quantityControllers[id],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              enabled: isSelected,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (value) {
                if (_selectedItems.containsKey(id)) {
                  setState(() {
                    _selectedItems[id]!.quantity = int.tryParse(value) ?? 0;
                  });
                }
              },
            ),
          ),

          // Plus Button
          InkWell(
            onTap: isSelected ? () => _updateQuantity(id, 1) : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey.shade100 : Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(9),
                  bottomRight: Radius.circular(9),
                ),
              ),
              child: Icon(
                Icons.add,
                size: 18,
                color: isSelected ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔧 NEW: Extracted price field widget
  Widget _buildPriceField(String id, bool isSelected, bool isPriceHigher) {
    return TextField(
      controller: _priceControllers[id],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      enabled: isSelected,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: isPriceHigher ? Colors.red.shade700 : null,
      ),
      decoration: InputDecoration(
        labelText: 'Price',
        prefixText: 'Rs ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: isPriceHigher ? Colors.red.shade50 : Colors.white,
      ),
      onChanged: (value) => _updatePrice(id, value),
    );
  }

  // 🔧 NEW: Extracted item total widget
  Widget _buildItemTotal(String id) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Total',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          'Rs ${_formatCurrency(_calculateItemTotal(id))}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.indigo.shade700,
          ),
        ),
      ],
    );
  }

  double _calculateItemTotal(String id) {
    final qty = int.tryParse(_quantityControllers[id]?.text ?? '') ?? 0;
    final price = double.tryParse(_priceControllers[id]?.text ?? '') ?? 0;
    return qty * price;
  }

  // ========== EMPTY STATE ==========
  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ========== TOTAL SECTION ==========
  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        border: Border(
          top: BorderSide(color: Colors.indigo.shade100),
          bottom: BorderSide(color: Colors.indigo.shade100),
        ),
      ),
      child: Row(
        children: [
          // Selected Items Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart, size: 18, color: Colors.indigo.shade700),
                const SizedBox(width: 8),
                Text(
                  '$_selectedItemCount items',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Total Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'TOTAL AMOUNT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rs ${_formatCurrency(_totalAmount)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== FOOTER ==========
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Quick Info
          if (_selectedSupplier != null)
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(
                      _selectedSupplier!.initials,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      _selectedSupplier!.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          const Spacer(),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _canCreate ? _handleCreate : null,
            icon: const Icon(Icons.check_circle),
            label: const Text('Create PO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCreate() {
    final itemsList = _selectedItems.values.map((item) {
      return SelectedPOItem(
        id: item.id,
        name: item.name,
        category: item.category,
        quantity: int.tryParse(_quantityControllers[item.id]?.text ?? '') ?? item.quantity,
        unit: item.unit,
        price: double.tryParse(_priceControllers[item.id]?.text ?? '') ?? item.price,
        lastPurchasePrice: item.lastPurchasePrice,
        isFromQuotation: item.isFromQuotation,
      );
    }).toList();

    widget.onCreate(
      _selectedQuotationId!,
      _selectedSupplier!,
      itemsList,
      _expectedDeliveryDate,
    );
    Navigator.pop(context);
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2);
  }
}
