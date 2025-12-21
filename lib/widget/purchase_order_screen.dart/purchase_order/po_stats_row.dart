import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/purchase_order/purchase_order.dart';
import 'package:tilework/widget/purchase_order_screen.dart/stat_card.dart';

class POStatsRow extends StatelessWidget {
  final List<PurchaseOrder> orders;
  final Function(String? filterStatus)? onFilterChanged;

  const POStatsRow({
    Key? key,
    required this.orders,
    this.onFilterChanged,
  }) : super(key: key);

  // Only include committed orders (Ordered, Delivered, Paid) - exclude Drafts
  List<PurchaseOrder> get _committedOrders => orders.where((po) {
    final status = po.status.toLowerCase();
    return status == 'ordered' || status == 'delivered' || status == 'paid';
  }).toList();

  int get _totalOrders => _committedOrders.length;

  int get _pendingOrders =>
      _committedOrders.where((po) => po.status.toLowerCase() == 'ordered').length;

  int get _deliveredOrders =>
      _committedOrders.where((po) => po.status.toLowerCase() == 'delivered').length;

  // Financial calculations for committed orders
  double get _totalValue =>
      _committedOrders.fold(0, (sum, po) => sum + po.totalAmount);

  double get _totalPaid =>
      _committedOrders.where((po) => po.status.toLowerCase() == 'paid')
          .fold(0, (sum, po) => sum + po.totalAmount);

  double get _awaitingPayment =>
      _committedOrders.where((po) => po.status.toLowerCase() == 'delivered')
          .fold(0, (sum, po) => sum + po.totalAmount);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 240,
              child: StatCard(
                icon: Icons.receipt_long,
                title: 'Total Active Orders',
                value: _totalOrders.toString(),
                color: Colors.indigo,
                onTap: () => onFilterChanged?.call('Active'),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 240,
              child: StatCard(
                icon: Icons.local_shipping,
                title: 'Pending Delivery',
                value: _pendingOrders.toString(),
                color: Colors.orange,
                onTap: () => onFilterChanged?.call('Ordered'),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 240,
              child: StatCard(
                icon: Icons.check_circle,
                title: 'Ready for Payment',
                value: _deliveredOrders.toString(),
                color: Colors.green,
                onTap: () => onFilterChanged?.call('Delivered'),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 480,
              child: StatCard(
                icon: Icons.account_balance_wallet,
                title: 'Total Investment',
                value: 'Rs ${NumberFormat('#,##0').format(_totalValue)}',
                color: Colors.blue,
                isWide: true,
                onTap: () => onFilterChanged?.call('Active'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
