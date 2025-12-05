import 'package:flutter/material.dart';
import 'package:tilework/models/job_cost_screen/po_item_cost.dart';
import 'package:tilework/utils/job_cost_formatters.dart';
import 'package:tilework/widget/purchase_order_screen.dart/status_badge.dart';

class POItemRow extends StatelessWidget {
  final POItemCost po;

  const POItemRow({
    Key? key,
    required this.po,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // PO ID
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                po.poId,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ),
          ),
          // Supplier
          Expanded(
            flex: 2,
            child: Text(po.supplierName, style: const TextStyle(fontSize: 13)),
          ),
          // Item
          Expanded(
            flex: 2,
            child: Text(po.itemName, style: const TextStyle(fontSize: 13)),
          ),
          // Quantity
          Expanded(
            child: Text(
              po.quantityDisplay,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          // Unit Price
          Expanded(
            child: Text(
              AppFormatters.formatCurrency(po.unitPrice),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          // Total
          Expanded(
            child: Text(
              AppFormatters.formatCurrency(po.totalCost),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
          ),
          // Status
          Expanded(
            child: Center(
              child: StatusBadge(status: po.status),
            ),
          ),
        ],
      ),
    );
  }
}