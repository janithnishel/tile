import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/purchase_order_screen/purchase_order.dart';
import 'package:tilework/models/purchase_order_screen/supplier.dart';
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
    if (categories.isEmpty) return const SizedBox.shrink();

    // Show up to 3 categories, with +X more if there are more
    final displayCategories = categories.take(3).toList();
    final remainingCount = categories.length - 3;

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        ...displayCategories.map((category) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200, width: 0.5),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )),
        if (remainingCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 0.5),
            ),
            child: Text(
              '+$remainingCount',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
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
