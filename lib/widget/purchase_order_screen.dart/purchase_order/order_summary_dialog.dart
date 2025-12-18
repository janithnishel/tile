import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/purchase_order/purchase_order.dart';
import 'package:tilework/utils/po_status_helpers.dart';
import 'package:tilework/widget/shared/info_card.dart';
import 'order_item_card.dart';

class OrderSummaryDialog extends StatelessWidget {
  final PurchaseOrder order;
  final VoidCallback onClose;
  final VoidCallback onPrint;
  final VoidCallback onEdit;
  final VoidCallback onStatusUpdate;

  const OrderSummaryDialog({
    Key? key,
    required this.order,
    required this.onClose,
    required this.onPrint,
    required this.onEdit,
    required this.onStatusUpdate,
  }) : super(key: key);

  Color get _statusColor => POStatusHelpers.getStatusColor(order.status);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(child: _buildContent()),
            _buildActionButtons(context),
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
          colors: [
            _statusColor.withOpacity(0.8),
            _statusColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.poId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onClose,
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
          // Info Cards Row 1
          Row(
            children: [
              Expanded(
                child: InfoCard(
                  icon: Icons.business,
                  title: 'Supplier',
                  value: order.supplier.name,
                  subtitle: order.supplier.phone,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoCard(
                  icon: Icons.description,
                  title: 'Quotation',
                  value: order.displayQuotationId,
                  subtitle: order.customerName,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Info Cards Row 2
          Row(
            children: [
              Expanded(
                child: InfoCard(
                  icon: Icons.calendar_today,
                  title: 'Order Date',
                  value: DateFormat('d MMMM yyyy').format(order.orderDate),
                  subtitle: DateFormat('EEEE').format(order.orderDate),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoCard(
                  icon: Icons.local_shipping,
                  title: 'Expected Delivery',
                  value: order.expectedDelivery != null
                      ? DateFormat('d MMMM yyyy').format(order.expectedDelivery!)
                      : 'Not Set',
                  subtitle: order.daysUntilDelivery != null
                      ? '${order.daysUntilDelivery} days remaining'
                      : '-',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Invoice Image Section
          _buildInvoiceSection(),
          const SizedBox(height: 24),

          // Order Items
          const Text(
            'Order Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => OrderItemCard(item: item)),
          const SizedBox(height: 16),

          // Total Section
          _buildTotalSection(),
        ],
      ),
    );
  }

  Widget _buildInvoiceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.image, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Invoice Image',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Upload Invoice'),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.indigo.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Amount',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Rs ${NumberFormat('#,##0.00').format(order.totalAmount)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
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
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPrint,
              icon: const Icon(Icons.print),
              label: const Text('Print'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: order.isPaid ? null : onStatusUpdate,
              icon: Icon(POStatusHelpers.getNextActionIcon(order.status)),
              label: Text(order.nextActionText),
              style: ElevatedButton.styleFrom(
                backgroundColor: POStatusHelpers.getStatusColor(order.nextStatus),
                padding: const EdgeInsets.all(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
