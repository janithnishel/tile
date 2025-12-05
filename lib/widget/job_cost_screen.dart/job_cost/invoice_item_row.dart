import 'package:flutter/material.dart';
import 'package:tilework/models/job_cost_screen/invoice_item.dart';
import 'package:tilework/utils/job_cost_formatters.dart';

class InvoiceItemRow extends StatelessWidget {
  final InvoiceItem item;
  final int index;
  final VoidCallback onEditCostPrice;

  const InvoiceItemRow({
    Key? key,
    required this.item,
    required this.index,
    required this.onEditCostPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.hasCostPrice ? Colors.white : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.hasCostPrice
              ? Colors.grey.shade200
              : Colors.amber.shade300,
        ),
      ),
      child: Row(
        children: [
          // Item Name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  item.unit,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          // Quantity
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                AppFormatters.formatQuantity(item.quantity),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          // Selling Price
          Expanded(
            flex: 2,
            child: Text(
              AppFormatters.formatCurrency(item.sellingPrice),
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.blue.shade700),
            ),
          ),
          // Cost Price
          Expanded(
            flex: 2,
            child: item.hasCostPrice
                ? Text(
                    AppFormatters.formatCurrency(item.costPrice!),
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.orange.shade700),
                  )
                : _buildEditCostButton(),
          ),
          // Profit
          Expanded(
            flex: 2,
            child: Text(
              item.hasCostPrice
                  ? AppFormatters.formatCurrency(item.profit)
                  : '-',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: item.profit >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditCostButton() {
    return InkWell(
      onTap: onEditCostPrice,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 14, color: Colors.orange),
            SizedBox(width: 4),
            Text(
              'Enter',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}