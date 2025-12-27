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

// ========== MAIN DIALOG ==========

class CreateMaterialSalePODialog extends StatefulWidget {
  final List<ApprovedMaterialSale> materialSales;
  final List<Supplier> suppliers;
  final Function(String saleId, Supplier supplier, List<SelectedPOItem> items, DateTime? expectedDeliveryDate) onCreate;

  const CreateMaterialSalePODialog({
    Key? key,
    required this.materialSales,
    required this.suppliers,
    required this.onCreate,
  }) : super(key: key);

  @override
  State<CreateMaterialSalePODialog> createState() => _CreateMaterialSalePODialogState();
}

class _CreateMaterialSalePODialogState extends State<CreateMaterialSalePODialog> with TickerProviderStateMixin {
  // Selection State
  String? _selectedSaleId;
  Supplier? _selectedSupplier;
  DateTime? _expectedDeliveryDate;

  // Items
  List<QuotationItem> _saleItems = [];
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
    _expectedDeliveryDate = DateTime.now().add(const Duration(days: 7)); // Default: Current Date + 7 days
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

  // ========== SALE CHANGE ==========
  void _onSaleChanged(String? value) {
    setState(() {
      _selectedSaleId = value;
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
        final sale = widget.materialSales.firstWhere((s) => s.saleId == value);
        _saleItems = sale.availableItems.where((item) => item.category != 'Services').toList();

        for (var item in _saleItems) {
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
    for (var item in _saleItems) {
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
        // Real-time total update
        setState(() {});
      });
    }
  }

  // ========== UPDATE PRICE ==========
  void _updatePrice(String id, String priceText) {
    if (_selectedItems.containsKey(id)) {
      setState(() {
        _selectedItems[id]!.price = double.tryParse(priceText) ?? 0;
        // Real-time total update
        setState(() {});
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
      _selectedSaleId != null &&
      _selectedSupplier != null &&
      _selectedItems.isNotEmpty;

  // ========== BUILD ==========
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Material Sale Purchase Order'),
        backgroundColor: Colors.orange.shade700,
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
          colors: [Colors.orange.shade600, Colors.orange.shade800],
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
            child: const Icon(Icons.store, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Material Sale Purchase Order',
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
          // Step 1: Select Material Sale
          _buildStepSection(
            step: 1,
            title: 'Select Approved Material Sale',
            icon: Icons.store_outlined,
            child: _buildSaleDropdown(),
          ),

          if (_selectedSaleId != null) ...[
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

            // Step 3: Sale Items (Auto-selected)
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildStepSection(
                step: 3,
                title: 'Sale Items',
                subtitle: 'These items are auto-selected from the material sale',
                icon: Icons.check_circle_outline,
                headerAction: _buildSelectAllButton(),
                child: _buildSaleItemsList(),
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
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
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

  // ========== SALE DROPDOWN ==========
  Widget _buildSaleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSaleId,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.store, color: Colors.orange.shade400),
        hintText: 'Choose an approved material sale...',
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: widget.materialSales.map((s) {
        return DropdownMenuItem(
          value: s.saleId,
          child: Text(
            s.displayName,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _onSaleChanged,
    );
  }

  // ========== SUPPLIER DROPDOWN ==========
  Widget _buildSupplierDropdown() {
    return DropdownButtonFormField<Supplier>(
      value: _selectedSupplier,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.business, color: Colors.orange.shade400),
        hintText: 'Choose a supplier...',
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: widget.suppliers.map((s) {
        return DropdownMenuItem(
          value: s,
          child: Text(
            '${s.name} - ${s.categoriesDisplayText}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _onSupplierChanged,
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
                  primary: Colors.orange,
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
            Icon(Icons.calendar_today, color: Colors.orange.shade400, size: 24),
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
                      color: Colors.orange,
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

  // ========== CATEGORY CHIPS ==========
  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _availableCategories.map((category) {
          final isSelected = _selectedCategory == category;
          final itemCount = category == 'All'
              ? _saleItems.length + _additionalItems.length
              : _saleItems.where((i) => i.category == category).length +
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
                        color: isSelected ? Colors.orange : Colors.grey.shade700,
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
              selectedColor: Colors.orange.shade100,
              checkmarkColor: Colors.orange,
              backgroundColor: Colors.grey.shade100,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ========== SELECT ALL BUTTON ==========
  Widget _buildSelectAllButton() {
    final allSelected = _saleItems.isNotEmpty &&
        _saleItems.every((item) => _selectedItems.containsKey(item.id));

    return TextButton.icon(
      onPressed: _saleItems.isEmpty ? null : () {
        setState(() {
          if (allSelected) {
            for (var item in _saleItems) {
              _selectedItems.remove(item.id);
            }
          } else {
            for (var item in _saleItems) {
              if (!_selectedItems.containsKey(item.id)) {
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
        foregroundColor: Colors.orange,
      ),
    );
  }

  // ========== SALE ITEMS LIST ==========
  Widget _buildSaleItemsList() {
    final filteredItems = _selectedCategory == 'All'
        ? _saleItems
        : _saleItems.where((i) => i.category == _selectedCategory).toList();

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
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
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
                  color: Colors.blue.shade700,
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
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Text(
                        '${_additionalItems.length} more items available',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _showAdditionalItems ? Icons.expand_less : Icons.expand_more,
                  color: Colors.blue.shade700,
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

  // ========== ITEM CARD ==========
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
            ? (isFromQuotation ? Colors.orange.shade50 : Colors.blue.shade50)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? (isFromQuotation ? Colors.orange.shade300 : Colors.blue.shade300)
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
                  activeColor: isFromQuotation ? Colors.orange : Colors.blue,
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
                                  'From Material Sale',
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

          // Quantity & Price Row
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: LayoutBuilder(
              builder: (context, constraints) {
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

          // Price warning
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
                    child: Text(
                      'Price is ${((currentPrice - lastPurchasePrice!) / lastPurchasePrice! * 100).toStringAsFixed(1)}% higher than last purchase',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildQuantityControl(String id, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            color: Colors.orange.shade700,
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

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          top: BorderSide(color: Colors.orange.shade100),
          bottom: BorderSide(color: Colors.orange.shade100),
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
                Icon(Icons.store, size: 18, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  '$_selectedItemCount items',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade700,
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
                  color: Colors.orange.shade700,
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
          if (_selectedSupplier != null)
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.orange.shade100,
                    child: Text(
                      _selectedSupplier!.initials,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
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
              backgroundColor: Colors.orange,
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
      _selectedSaleId!,
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
