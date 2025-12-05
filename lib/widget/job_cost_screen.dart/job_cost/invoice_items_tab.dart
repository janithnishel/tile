import 'package:flutter/material.dart';
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';
import 'package:tilework/utils/job_cost_formatters.dart';
import 'package:tilework/widget/job_cost_screen.dart/data_table_header.dart';
import '../dialogs/cost_price_dialog.dart';
import 'invoice_item_row.dart';

class InvoiceItemsTab extends StatelessWidget {
  final JobCostDocument job;
  final VoidCallback onDataChanged;

  const InvoiceItemsTab({
    Key? key,
    required this.job,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const DataTableHeader(
            columns: [
              DataTableColumn(label: 'Item', flex: 3),
              DataTableColumn(label: 'Qty', alignment: TextAlign.center),
              DataTableColumn(label: 'Selling Price', flex: 2, alignment: TextAlign.right),
              DataTableColumn(label: 'Cost Price', flex: 2, alignment: TextAlign.right),
              DataTableColumn(label: 'Profit', flex: 2, alignment: TextAlign.right),
            ],
          ),
          const SizedBox(height: 8),

          // Items List
          Expanded(
            child: ListView.builder(
              itemCount: job.invoiceItems.length,
              itemBuilder: (context, index) {
                final item = job.invoiceItems[index];
                return InvoiceItemRow(
                  item: item,
                  index: index,
                  onEditCostPrice: () => _showCostPriceDialog(context, item),
                );
              },
            ),
          ),

          // Total Row
          _buildTotalRow(),
        ],
      ),
    );
  }

  void _showCostPriceDialog(BuildContext context, item) {
    showDialog(
      context: context,
      builder: (context) => CostPriceDialog(
        item: item,
        onSave: (price) {
          item.costPrice = price;
          onDataChanged();
        },
      ),
    );
  }

  Widget _buildTotalRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Expanded(child: SizedBox()),
          Expanded(
            flex: 2,
            child: Text(
              AppFormatters.formatCurrency(job.totalRevenue),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              AppFormatters.formatCurrency(job.materialCost),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              AppFormatters.formatCurrency(job.invoiceItemsProfit),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}