import 'package:flutter/material.dart';
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';
import 'package:tilework/utils/job_cost_formatters.dart';
import 'package:tilework/widget/job_cost_screen.dart/data_table_header.dart';
import 'po_item_row.dart';

class PurchaseOrdersTab extends StatelessWidget {
  final JobCostDocument job;

  const PurchaseOrdersTab({
    Key? key,
    required this.job,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (job.purchaseOrderItems.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          const DataTableHeader(
            columns: [
              DataTableColumn(label: 'PO ID'),
              DataTableColumn(label: 'Supplier', flex: 2),
              DataTableColumn(label: 'Item', flex: 2),
              DataTableColumn(label: 'Qty', alignment: TextAlign.center),
              DataTableColumn(label: 'Unit Price', alignment: TextAlign.right),
              DataTableColumn(label: 'Total', alignment: TextAlign.right),
              DataTableColumn(label: 'Status', alignment: TextAlign.center),
            ],
          ),
          const SizedBox(height: 8),

          // Items
          Expanded(
            child: ListView.builder(
              itemCount: job.purchaseOrderItems.length,
              itemBuilder: (context, index) {
                return POItemRow(po: job.purchaseOrderItems[index]);
              },
            ),
          ),

          // Total
          _buildTotalRow(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No Purchase Orders for this job',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 6,
            child: Text('TOTAL PO COST',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              AppFormatters.formatCurrency(job.purchaseOrderCost),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}