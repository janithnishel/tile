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
      child: Row(
        children: [
          _buildCategoryBadge(),
          const SizedBox(width: 8),
          _buildOrderCountBadge(),
          const Spacer(),
          _buildTotalAmount(),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        supplier.category,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade700,
        ),
      ),
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