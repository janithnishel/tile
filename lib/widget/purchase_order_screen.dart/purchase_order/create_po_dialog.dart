import 'package:flutter/material.dart';
import 'package:tilework/models/purchase_order_screen/approved_quotation.dart';
import 'package:tilework/models/purchase_order_screen/quotation_item.dart';
import 'package:tilework/models/purchase_order_screen/supplier.dart';

class CreatePODialog extends StatefulWidget {
  final List<ApprovedQuotation> quotations;
  final List<Supplier> suppliers;
  final Function(String quotationId, Supplier supplier, List<QuotationItem> items) onCreate;

  const CreatePODialog({
    Key? key,
    required this.quotations,
    required this.suppliers,
    required this.onCreate,
  }) : super(key: key);

  @override
  State<CreatePODialog> createState() => _CreatePODialogState();
}

class _CreatePODialogState extends State<CreatePODialog> {
  String? _selectedQuotationId;
  Supplier? _selectedSupplier;
  List<QuotationItem> _availableItems = [];
  final Map<String, bool> _selectedItems = {};
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};

  @override
  void dispose() {
    _quantityControllers.values.forEach((c) => c.dispose());
    _priceControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _onQuotationChanged(String? value) {
    setState(() {
      _selectedQuotationId = value;
      if (value != null) {
        final quotation = widget.quotations
            .firstWhere((q) => q.quotationId == value);
        _availableItems = quotation.availableItems;
        _selectedItems.clear();
        _quantityControllers.clear();
        _priceControllers.clear();

        for (var item in _availableItems) {
          _selectedItems[item.name] = false;
          _quantityControllers[item.name] = TextEditingController(
            text: item.quantity.toString(),
          );
          _priceControllers[item.name] = TextEditingController(
            text: item.estimatedPrice.toString(),
          );
        }
      }
    });
  }

  bool get _canCreate =>
      _selectedQuotationId != null &&
      _selectedSupplier != null &&
      _selectedItems.values.any((v) => v);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

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
          const Icon(
            Icons.add_shopping_cart,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Create Purchase Order',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
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
          // Step 1: Select Quotation
          _buildSectionTitle('① Select Approved Quotation'),
          const SizedBox(height: 12),
          _buildQuotationDropdown(),

          if (_selectedQuotationId != null) ...[
            const SizedBox(height: 24),

            // Step 2: Select Supplier
            _buildSectionTitle('② Select Supplier'),
            const SizedBox(height: 12),
            _buildSupplierDropdown(),
            const SizedBox(height: 24),

            // Step 3: Select Items
            _buildSectionTitle('③ Select Items to Order'),
            const SizedBox(height: 12),
            _buildItemsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildQuotationDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedQuotationId,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.description),
        hintText: 'Choose a quotation...',
      ),
      items: widget.quotations.map((q) {
        return DropdownMenuItem(
          value: q.quotationId,
          child: Text(q.displayName),
        );
      }).toList(),
      onChanged: _onQuotationChanged,
    );
  }

  Widget _buildSupplierDropdown() {
    return DropdownButtonFormField<Supplier>(
      value: _selectedSupplier,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.business),
        hintText: 'Choose a supplier...',
      ),
      items: widget.suppliers.map((s) {
        return DropdownMenuItem(
          value: s,
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.indigo.shade100,
                child: Text(
                  s.initials,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(s.name),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  s.category,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSupplier = value;
        });
      },
    );
  }

  Widget _buildItemsList() {
    if (_availableItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.info, color: Colors.orange),
            SizedBox(width: 12),
            Text('All items from this quotation have been ordered.'),
          ],
        ),
      );
    }

    return Column(
      children: _availableItems.map((item) => _buildItemRow(item)).toList(),
    );
  }

  Widget _buildItemRow(QuotationItem item) {
    final isSelected = _selectedItems[item.name] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.indigo.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.indigo.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                _selectedItems[item.name] = value ?? false;
              });
            },
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _quantityControllers[item.name],
              keyboardType: TextInputType.number,
              enabled: isSelected,
              decoration: InputDecoration(
                labelText: 'Qty',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(item.unit),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _priceControllers[item.name],
              keyboardType: TextInputType.number,
              enabled: isSelected,
              decoration: InputDecoration(
                labelText: 'Price',
                prefixText: 'Rs ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _canCreate
                ? () {
                    final selectedItemsList = _availableItems
                        .where((item) => _selectedItems[item.name] == true)
                        .toList();
                    widget.onCreate(
                      _selectedQuotationId!,
                      _selectedSupplier!,
                      selectedItemsList,
                    );
                    Navigator.pop(context);
                  }
                : null,
            icon: const Icon(Icons.check),
            label: const Text('Create Purchase Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}