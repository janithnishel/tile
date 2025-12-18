import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/purchase_order/purchase_order.dart';
import 'package:tilework/widget/purchase_order_screen.dart/stat_card.dart';

class POStatsRow extends StatelessWidget {
  final List<PurchaseOrder> orders;

  const POStatsRow({
    Key? key,
    required this.orders,
  }) : super(key: key);

  int get _totalOrders => orders.length;

  int get _pendingOrders =>
      orders.where((po) => po.status == 'Ordered').length;

  int get _deliveredOrders =>
      orders.where((po) => po.status == 'Delivered').length;

  double get _totalValue =>
      orders.fold(0, (sum, po) => sum + po.totalAmount);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          StatCard(
            icon: Icons.receipt_long,
            title: 'Total Orders',
            value: _totalOrders.toString(),
            color: Colors.indigo,
          ),
          const SizedBox(width: 12),
          StatCard(
            icon: Icons.local_shipping,
            title: 'Pending Delivery',
            value: _pendingOrders.toString(),
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          StatCard(
            icon: Icons.check_circle,
            title: 'Delivered',
            value: _deliveredOrders.toString(),
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          StatCard(
            icon: Icons.account_balance_wallet,
            title: 'Total Value',
            value: 'Rs ${NumberFormat('#,##0').format(_totalValue)}',
            color: Colors.blue,
            isWide: true,
          ),
        ],
      ),
    );
  }
}
