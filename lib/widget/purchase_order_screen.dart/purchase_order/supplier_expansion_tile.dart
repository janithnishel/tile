import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/purchase_order/purchase_order.dart';
import 'package:tilework/models/purchase_order/supplier.dart';
import 'po_list_tile.dart';

class SupplierExpansionTile extends StatelessWidget {
  final Supplier supplier;
  final List<PurchaseOrder> orders;
  final Function(PurchaseOrder) onOrderTap;

  const SupplierExpansionTile({
    Key? key,
    required this.supplier,
    required this.orders,
    required this.onOrderTap,
  }) : super(key: key);

  double get _totalValue =>
      orders.fold<double>(0, (sum, po) => sum + po.totalAmount);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: orders.length <= 3,
        leading: _buildSupplierAvatar(),
        title: Text(
          supplier.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: _buildSubtitle(),
        children: orders
            .map((po) => POListTile(
                  order: po,
                  onTap: () => onOrderTap(po),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSupplierAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.indigo.shade100,
      child: Text(
        supplier.initials,
        style: TextStyle(
          color: Colors.indigo.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoriesRow(),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildOrderCountBadge(),
              const Spacer(),
              _buildTotalAmount(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow() {
    final categories = supplier.categories;
    if (categories.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if no categories
    }

    // Show all categories in a wrap layout
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: categories.map((category) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200, width: 0.5),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
    );
  }

  Widget _buildOrderCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.indigo.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${orders.length} Orders',
        style: TextStyle(
          fontSize: 11,
          color: Colors.indigo.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTotalAmount() {
    return Text(
      'Rs ${NumberFormat('#,##0').format(_totalValue)}',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.green.shade700,
      ),
    );
  }
}
