// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:tilework/models/purchase_order/purchase_order.dart';
// import 'package:tilework/utils/po_status_helpers.dart';
// import 'package:tilework/widget/shared/info_card.dart';
// import 'order_item_card.dart';

// class OrderSummaryDialog extends StatelessWidget {
//   final PurchaseOrder order;
//   final VoidCallback onClose;
//   final VoidCallback onPrint;
//   final VoidCallback onEdit;
//   final VoidCallback onStatusUpdate;
//   final VoidCallback? onDelete;
//   final VoidCallback? onCancel;

//   const OrderSummaryDialog({
//     Key? key,
//     required this.order,
//     required this.onClose,
//     required this.onPrint,
//     required this.onEdit,
//     required this.onStatusUpdate,
//     this.onDelete,
//     this.onCancel,
//   }) : super(key: key);

//   Color get _statusColor => POStatusHelpers.getStatusColor(order.status);

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Container(
//         width: 600,
//         constraints: const BoxConstraints(maxHeight: 700),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildHeader(),
//             Flexible(child: _buildContent()),
//             _buildActionButtons(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             _statusColor.withOpacity(0.8),
//             _statusColor,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 order.poId,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   order.status.toUpperCase(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           IconButton(
//             onPressed: onClose,
//             icon: const Icon(Icons.close, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Info Cards Row 1
//           Row(
//             children: [
//               Expanded(
//                 child: InfoCard(
//                   icon: Icons.business,
//                   title: 'Supplier',
//                   value: order.supplier.name,
//                   subtitle: order.supplier.phone,
//                   color: Colors.indigo,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: InfoCard(
//                   icon: Icons.description,
//                   title: 'Quotation',
//                   value: order.displayQuotationId,
//                   subtitle: order.customerName,
//                   color: Colors.orange,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Info Cards Row 2
//           Row(
//             children: [
//               Expanded(
//                 child: InfoCard(
//                   icon: Icons.calendar_today,
//                   title: 'Order Date',
//                   value: DateFormat('d MMMM yyyy').format(order.orderDate),
//                   subtitle: DateFormat('EEEE').format(order.orderDate),
//                   color: Colors.blue,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: InfoCard(
//                   icon: Icons.local_shipping,
//                   title: 'Expected Delivery',
//                   value: order.expectedDelivery != null
//                       ? DateFormat('d MMMM yyyy').format(order.expectedDelivery!)
//                       : 'Not Set',
//                   subtitle: order.daysUntilDelivery != null
//                       ? '${order.daysUntilDelivery} days remaining'
//                       : '-',
//                   color: Colors.green,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),

//           // Invoice Image Section
//           _buildInvoiceSection(),
//           const SizedBox(height: 24),

//           // Order Items
//           const Text(
//             'Order Items',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 12),
//           ...order.items.map((item) => OrderItemCard(item: item)),
//           const SizedBox(height: 16),

//           // Total Section
//           _buildTotalSection(),
//         ],
//       ),
//     );
//   }

//   Widget _buildInvoiceSection() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Column(
//         children: [
//           Icon(Icons.image, size: 48, color: Colors.grey.shade400),
//           const SizedBox(height: 8),
//           Text(
//             'Invoice Image',
//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 12),
//           OutlinedButton.icon(
//             onPressed: () {},
//             icon: const Icon(Icons.upload_file, size: 18),
//             label: const Text('Upload Invoice'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTotalSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.indigo.shade50, Colors.indigo.shade100],
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             'Total Amount',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             'Rs ${NumberFormat('#,##0.00').format(order.totalAmount)}',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.indigo.shade700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: OutlinedButton.icon(
//               onPressed: onPrint,
//               icon: const Icon(Icons.print),
//               label: const Text('Print'),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.all(14),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: OutlinedButton.icon(
//               onPressed: onEdit,
//               icon: const Icon(Icons.edit),
//               label: const Text('Edit'),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.all(14),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             flex: 2,
//             child: _buildActionButton(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton() {
//     if (order.isDraft && onDelete != null) {
//       // For Draft: Show Delete button
//       return ElevatedButton.icon(
//         onPressed: onDelete,
//         icon: const Icon(Icons.delete),
//         label: const Text('Delete PO'),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.red,
//           padding: const EdgeInsets.all(14),
//         ),
//       );
//     } else if ((order.isOrdered || order.isDelivered) && onCancel != null) {
//       // For Ordered/Delivered: Show Cancel button
//       return ElevatedButton.icon(
//         onPressed: onCancel,
//         icon: const Icon(Icons.cancel),
//         label: const Text('Cancel PO'),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.red,
//           padding: const EdgeInsets.all(14),
//         ),
//       );
//     } else if (!order.isPaid && !order.isCancelled && onStatusUpdate != null) {
//       // For other statuses that can be updated: Show status update button
//       return ElevatedButton.icon(
//         onPressed: onStatusUpdate,
//         icon: Icon(POStatusHelpers.getNextActionIcon(order.status)),
//         label: Text(order.nextActionText),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: POStatusHelpers.getStatusColor(order.nextStatus),
//           padding: const EdgeInsets.all(14),
//         ),
//       );
//     } else {
//       // For Paid/Cancelled or no action available: Disabled button
//       return ElevatedButton.icon(
//         onPressed: null,
//         icon: const Icon(Icons.check_circle),
//         label: const Text('Completed'),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.grey,
//           padding: const EdgeInsets.all(14),
//         ),
//       );
//     }
//   }
// }
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tilework/models/purchase_order/purchase_order.dart';
import 'package:tilework/models/purchase_order/invoice_details.dart';
import 'package:tilework/models/purchase_order/delivery_item.dart';
import 'package:tilework/models/purchase_order/supplier.dart';
import 'package:tilework/utils/po_status_helpers.dart';
import 'package:tilework/cubits/purchase_order/purchase_order_cubit.dart';
import 'package:tilework/widget/purchase_order_screen.dart/purchase_order/create_po_screen.dart';

class OrderSummaryDialog extends StatefulWidget {
  final PurchaseOrder order;
  final List<Supplier> suppliers;
  final VoidCallback onClose;
  final Function(PurchaseOrder)? onOrderUpdated;
  final Function(String status)? onStatusChanged;
  final Function(InvoiceDetails)? onInvoiceUploaded;
  final Function(List<DeliveryItem>)? onDeliveryVerified;
  final String? invoiceImageUrl;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const OrderSummaryDialog({
    Key? key,
    required this.order,
    required this.suppliers,
    required this.onClose,
    this.onOrderUpdated,
    this.onStatusChanged,
    this.onInvoiceUploaded,
    this.onDeliveryVerified,
    this.invoiceImageUrl,
    this.onCancel,
    this.onDelete,
  }) : super(key: key);

  @override
  State<OrderSummaryDialog> createState() => _OrderSummaryDialogState();
}

class _OrderSummaryDialogState extends State<OrderSummaryDialog> {
  late PurchaseOrder _currentOrder;
  bool _isFullPreviewMode = false;
  bool _isGeneratingPDF = false;

  // Invoice Details State
  InvoiceDetails _invoiceDetails = InvoiceDetails.empty();
  File? _selectedInvoiceImage;

  // Delivery Verification State
  late List<DeliveryItem> _deliveryItems;
  bool _isVerificationMode = false;

  Color get _statusColor => POStatusHelpers.getStatusColor(_currentOrder.status);

  // Calculate totals
  double get _subtotal => _currentOrder.items.fold(
      0.0, (sum, item) => sum + (item.quantity * item.unitPrice));
  double get _taxAmount => _subtotal * 0.0;
  double get _grandTotal => _subtotal + _taxAmount;

  // Status checks
  bool get _shouldShowWatermark =>
      _currentOrder.isDraft || _currentOrder.isCancelled;
  bool get _canVerifyDelivery => _currentOrder.isOrdered;
  bool get _allItemsVerified => _deliveryItems.every((item) => item.isVerified);
  bool get _canConfirmDelivery =>
      _currentOrder.isOrdered && _allItemsVerified && _invoiceDetails.hasInvoice;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _initializeDeliveryItems();
    _loadExistingInvoiceDetails();
  }

  void _initializeDeliveryItems() {
    _deliveryItems = _currentOrder.items.map((item) {
      return DeliveryItem(
        itemId: item.id ?? '',
        itemName: item.itemName,
        orderedQuantity: item.quantity.toDouble(),
        receivedQuantity: 0,
        isVerified: false,
      );
    }).toList();
  }

  void _loadExistingInvoiceDetails() {
    if (widget.invoiceImageUrl != null) {
      _invoiceDetails = _invoiceDetails.copyWith(imageUrl: widget.invoiceImageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: _isFullPreviewMode ? MediaQuery.of(context).size.width * 0.9 : 800,
        constraints: BoxConstraints(
          maxHeight: _isFullPreviewMode
              ? MediaQuery.of(context).size.height * 0.95
              : 900,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(),
            if (_currentOrder.isDraft) _buildDraftWarningBanner(),
            if (_canVerifyDelivery) _buildDeliveryVerificationBanner(),
            if (_currentOrder.isDelivered && !_currentOrder.isPaid)
              _buildPaymentReadyBanner(),
            Flexible(child: _buildDocumentContent(context)),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔝 DIALOG HEADER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_statusColor.withOpacity(0.9), _statusColor],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Purchase Order',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                    if (_currentOrder.isDraft) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'INTERNAL ONLY',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _currentOrder.poId,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _buildStatusBadge(),
          const SizedBox(width: 16),
          Material(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: widget.onClose,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    IconData statusIcon;
    switch (_currentOrder.status.toLowerCase()) {
      case 'draft':
        statusIcon = Icons.edit_note_rounded;
        break;
      case 'ordered':
        statusIcon = Icons.shopping_cart_checkout_rounded;
        break;
      case 'delivered':
        statusIcon = Icons.local_shipping_rounded;
        break;
      case 'paid':
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusIcon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 18, color: _statusColor),
          const SizedBox(width: 8),
          Text(
            _currentOrder.status.toUpperCase(),
            style: TextStyle(color: _statusColor, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔔 BANNERS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDraftWarningBanner() {
    return _buildBanner(
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.orange.shade500,
      title: 'This is a Draft Document',
      subtitle: 'Please click "Place Order" to generate the official document.',
      gradientColors: [Colors.orange.shade100, Colors.amber.shade50],
      borderColor: Colors.orange.shade300,
    );
  }

  Widget _buildDeliveryVerificationBanner() {
    final verifiedCount = _deliveryItems.where((item) => item.isVerified).length;
    final totalCount = _deliveryItems.length;
    final progress = totalCount > 0 ? verifiedCount / totalCount : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.indigo.shade50]),
        border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fact_check_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Verification Required',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Verify received items and upload supplier invoice to proceed.',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => _isVerificationMode = !_isVerificationMode),
                icon: Icon(_isVerificationMode ? Icons.close : Icons.checklist_rounded, size: 16),
                label: Text(_isVerificationMode ? 'Close' : 'Verify Items'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isVerificationMode ? Colors.grey.shade600 : Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
          if (_isVerificationMode) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 1.0 ? Colors.green : Colors.blue.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$verifiedCount / $totalCount verified',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: progress == 1.0 ? Colors.green.shade700 : Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentReadyBanner() {
    return _buildBanner(
      icon: Icons.payments_rounded,
      iconColor: Colors.green.shade600,
      title: 'Ready for Payment',
      subtitle: _invoiceDetails.hasInvoice
          ? 'Invoice #${_invoiceDetails.invoiceNumber} - Click "Mark as Paid" to complete.'
          : 'Upload supplier invoice first, then mark as paid.',
      gradientColors: [Colors.green.shade50, Colors.teal.shade50],
      borderColor: Colors.green.shade200,
      trailing: _invoiceDetails.hasInvoice
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 6),
                  Text('Invoice Uploaded', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildBanner({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required Color borderColor,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: iconColor)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: iconColor.withOpacity(0.8))),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📄 DOCUMENT CONTENT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDocumentContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Stack(
        children: [
          if (_shouldShowWatermark) _buildWatermark(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompanyHeader(),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildPODetails(),
                const SizedBox(height: 32),
                _buildItemsTableWithVerification(),
                const SizedBox(height: 24),
                _buildTotalsSection(),
                const SizedBox(height: 32),
                _buildEnhancedInvoiceSection(),
                const SizedBox(height: 32),
                _buildTermsSection(),
                const SizedBox(height: 24),
                _buildSignatureSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatermark() {
    final watermarkText = _currentOrder.isCancelled ? 'CANCELLED' : 'DRAFT';
    final watermarkColor = _currentOrder.isCancelled ? Colors.red : Colors.orange;

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Transform.rotate(
            angle: -0.4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: watermarkColor.withOpacity(0.4), width: 4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                watermarkText,
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: watermarkColor.withOpacity(0.2), letterSpacing: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo.shade700, Colors.indigo.shade400, Colors.indigo.shade200]),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.indigo.shade700, Colors.indigo.shade500]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('IH', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Immense Home (Private) Limited', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 4),
              Text('123 Main Street, Colombo 07, Sri Lanka', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              Text('Tel: +94 11 234 5678  •  Email: info@immensehome.lk', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _currentOrder.isDraft ? Colors.orange.shade50 : Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _currentOrder.isDraft ? Colors.orange.shade300 : Colors.indigo.shade200),
          ),
          child: Column(
            children: [
              Text(
                _currentOrder.isDraft ? 'DRAFT' : 'PURCHASE ORDER',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _currentOrder.isDraft ? Colors.orange.shade800 : Colors.indigo),
              ),
              const SizedBox(height: 4),
              Text(_currentOrder.poId, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.indigo.shade700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPODetails() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDetailCard('SUPPLIER', Icons.business, [
          _buildDetailText(_currentOrder.supplier.name, isBold: true),
          _buildDetailRow2(Icons.phone, _currentOrder.supplier.phone),
          if (_currentOrder.supplier.email?.isNotEmpty ?? false)
            _buildDetailRow2(Icons.email, _currentOrder.supplier.email!),
        ])),
        const SizedBox(width: 16),
        Expanded(child: _buildDetailCard('ORDER DETAILS', Icons.info_outline, [
          _buildLabelValue('Order Date', DateFormat('d MMMM yyyy').format(_currentOrder.orderDate)),
          _buildLabelValue('Expected Delivery', _currentOrder.expectedDelivery != null 
              ? DateFormat('d MMMM yyyy').format(_currentOrder.expectedDelivery!) 
              : 'Not Set'),
          _buildLabelValue('Quotation', _currentOrder.displayQuotationId),
          _buildLabelValue('Customer', _currentOrder.customerName),
        ])),
      ],
    );
  }

  Widget _buildDetailCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.indigo.shade600),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailText(String text, {bool isBold = false}) {
    return Text(text, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal));
  }

  Widget _buildDetailRow2(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text('$label:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📦 ITEMS TABLE WITH VERIFICATION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildItemsTableWithVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.inventory_2_rounded, size: 20, color: Colors.indigo.shade600),
            ),
            const SizedBox(width: 12),
            const Text('Order Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (_isVerificationMode && _canVerifyDelivery)
              TextButton.icon(
                onPressed: _markAllItemsVerified,
                icon: const Icon(Icons.done_all, size: 16),
                label: const Text('Verify All'),
                style: TextButton.styleFrom(foregroundColor: Colors.green.shade700),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
              child: Text('${_currentOrder.items.length} items', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildItemsTable(),
        if (_isVerificationMode && _canVerifyDelivery) ...[
          const SizedBox(height: 12),
          _buildVerificationSummary(),
        ],
      ],
    );
  }

  Widget _buildItemsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.indigo.shade700, Colors.indigo.shade600]),
              ),
              child: Row(
                children: [
                  if (_isVerificationMode && _canVerifyDelivery)
                    const SizedBox(width: 50, child: Text('✓', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  _tableHeader('#', 40),
                  _tableHeader('Description', null, TextAlign.left, 4),
                  _tableHeader('Category', null, TextAlign.left, 2),
                  _tableHeader('Qty', 70, TextAlign.center),
                  _tableHeader('Unit Price', 100, TextAlign.right),
                  _tableHeader('Total (LKR)', 120, TextAlign.right),
                ],
              ),
            ),
            // Rows
            ..._currentOrder.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isEven = index % 2 == 0;
              final rowTotal = item.quantity * item.unitPrice;
              final deliveryItem = _deliveryItems[index];

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: deliveryItem.isVerified ? Colors.green.shade50 : (isEven ? Colors.white : Colors.grey.shade50),
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    if (_isVerificationMode && _canVerifyDelivery)
                      SizedBox(
                        width: 50,
                        child: Checkbox(
                          value: deliveryItem.isVerified,
                          onChanged: (value) => _toggleItemVerification(index, value ?? false),
                          activeColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    _tableCell('${index + 1}', 40),
                    _tableCellExpanded(item.itemName, flex: 4, isBold: true, verified: deliveryItem.isVerified),
                    _tableCellExpanded(item.category ?? '-', flex: 2, color: Colors.grey.shade600),
                    _tableCell('${item.quantity} ${item.unit ?? ''}', 70, align: TextAlign.center),
                    _tableCell(NumberFormat('#,##0.00').format(item.unitPrice), 100, align: TextAlign.right),
                    _tableCell(NumberFormat('#,##0.00').format(rowTotal), 120, align: TextAlign.right, isBold: true, color: Colors.indigo.shade700),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text, [double? width, TextAlign align = TextAlign.left, int flex = 0]) {
    final widget = Text(text, textAlign: align, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold));
    if (flex > 0) return Expanded(flex: flex, child: widget);
    return SizedBox(width: width, child: widget);
  }

  Widget _tableCell(String text, double width, {TextAlign align = TextAlign.left, bool isBold = false, Color? color}) {
    return SizedBox(
      width: width,
      child: Text(text, textAlign: align, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w600 : FontWeight.normal, color: color ?? Colors.black87)),
    );
  }

  Widget _tableCellExpanded(String text, {int flex = 1, bool isBold = false, Color? color, bool verified = false}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          if (verified) ...[
            Icon(Icons.check_circle, size: 16, color: Colors.green),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w600 : FontWeight.normal, color: color ?? Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSummary() {
    final verifiedCount = _deliveryItems.where((item) => item.isVerified).length;
    final totalCount = _deliveryItems.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _allItemsVerified ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _allItemsVerified ? Colors.green.shade300 : Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            _allItemsVerified ? Icons.check_circle_rounded : Icons.pending_rounded,
            color: _allItemsVerified ? Colors.green.shade700 : Colors.blue.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _allItemsVerified ? 'All Items Verified! ✓' : 'Verification In Progress',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _allItemsVerified ? Colors.green.shade800 : Colors.blue.shade800),
                ),
                Text('$verifiedCount of $totalCount items verified', style: TextStyle(fontSize: 12, color: _allItemsVerified ? Colors.green.shade700 : Colors.blue.shade700)),
              ],
            ),
          ),
          if (_allItemsVerified && !_invoiceDetails.hasInvoice)
            ElevatedButton.icon(
              onPressed: _showInvoiceUploadDialog,
              icon: const Icon(Icons.upload_file, size: 16),
              label: const Text('Upload Invoice'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white),
            ),
        ],
      ),
    );
  }

  void _toggleItemVerification(int index, bool isVerified) {
    setState(() {
      _deliveryItems[index] = _deliveryItems[index].copyWith(
        isVerified: isVerified,
        receivedQuantity: isVerified ? _deliveryItems[index].orderedQuantity : 0,
        verifiedAt: isVerified ? DateTime.now() : null,
      );
    });
  }

  void _markAllItemsVerified() {
    setState(() {
      _deliveryItems = _deliveryItems.map((item) => item.copyWith(
        isVerified: true,
        receivedQuantity: item.orderedQuantity,
        verifiedAt: DateTime.now(),
      )).toList();
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💰 TOTALS SECTION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTotalsSection() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.note_alt_outlined, size: 18, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Text('Remarks', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _currentOrder.notes ?? 'No remarks added.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: _currentOrder.notes == null ? FontStyle.italic : FontStyle.normal),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: Column(
              children: [
                _buildTotalRow('Sub Total', _subtotal),
                const SizedBox(height: 8),
                _buildTotalRow('Tax (0%)', _taxAmount),
                const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                _buildTotalRow('Grand Total', _grandTotal, isGrandTotal: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isGrandTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isGrandTotal ? 15 : 13, fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w500, color: isGrandTotal ? Colors.indigo.shade800 : Colors.grey.shade700)),
        Text('Rs ${NumberFormat('#,##0.00').format(amount)}', style: TextStyle(fontSize: isGrandTotal ? 18 : 14, fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w600, color: isGrandTotal ? Colors.indigo.shade800 : Colors.black87)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🧾 INVOICE SECTION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildEnhancedInvoiceSection() {
    final hasInvoice = _invoiceDetails.hasInvoice;
    final canUpload = _currentOrder.isOrdered || _currentOrder.isDelivered;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasInvoice ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasInvoice ? Colors.green.shade300 : Colors.grey.shade200, width: hasInvoice ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: hasInvoice ? Colors.green.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(hasInvoice ? Icons.receipt_long_rounded : Icons.receipt_outlined, size: 24, color: hasInvoice ? Colors.green.shade700 : Colors.grey.shade600),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Supplier Invoice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: hasInvoice ? Colors.green.shade800 : Colors.black87)),
                    if (hasInvoice)
                      Text('Invoice #${_invoiceDetails.invoiceNumber}', style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              if (hasInvoice)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 6),
                      Text('Verified', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (hasInvoice)
            _buildInvoiceDetailsView()
          else
            _buildInvoiceUploadPrompt(canUpload),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetailsView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          if (_selectedInvoiceImage != null || _invoiceDetails.hasImage)
            GestureDetector(
              onTap: () {
                // open full screen zoomable viewer
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    insetPadding: EdgeInsets.all(0),
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 1,
                      maxScale: 5,
                      child: _selectedInvoiceImage != null
                          ? Image.file(_selectedInvoiceImage!)
                          : (_invoiceDetails.imageUrl != null ? Image.network(_invoiceDetails.imageUrl!) : const SizedBox.shrink()),
                    ),
                  ),
                );
              },
              child: Container(
                width: 100,
                height: 80,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  image: _selectedInvoiceImage != null
                      ? DecorationImage(image: FileImage(_selectedInvoiceImage!), fit: BoxFit.cover)
                      : (_invoiceDetails.imageUrl != null ? DecorationImage(image: NetworkImage(_invoiceDetails.imageUrl!), fit: BoxFit.cover) : null),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvoiceDetailRow('Invoice Number', _invoiceDetails.invoiceNumber ?? '-'),
                const SizedBox(height: 8),
                _buildInvoiceDetailRow('Received Date', _invoiceDetails.receivedDate != null ? DateFormat('d MMMM yyyy').format(_invoiceDetails.receivedDate!) : '-'),
              ],
            ),
          ),
          IconButton(onPressed: _showInvoiceUploadDialog, icon: const Icon(Icons.edit), tooltip: 'Edit Invoice Details', color: Colors.blue),
        ]
      ),
    );
  }

  Widget _buildInvoiceDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text('$label:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildInvoiceUploadPrompt(bool canUpload) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_upload_outlined, size: 48, color: canUpload ? Colors.indigo.shade400 : Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            canUpload ? 'Upload Supplier Invoice' : 'Invoice upload available after order is placed',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: canUpload ? Colors.black87 : Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: canUpload ? _showInvoiceUploadDialog : null,
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Upload Invoice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📝 TERMS & SIGNATURE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTermsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel_rounded, size: 18, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text('Terms & Conditions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '1. Payment terms: Net 30 days from invoice date.\n'
            '2. All goods must be delivered to the specified address.\n'
            '3. Quality must meet the agreed specifications.\n'
            '4. Any discrepancies must be reported within 48 hours of delivery.',
            style: TextStyle(fontSize: 11, color: Colors.blue.shade900, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Row(
      children: [
        Expanded(child: _buildSignatureLine('Authorized Signature')),
        const SizedBox(width: 40),
        Expanded(child: _buildSignatureLine('Date')),
      ],
    );
  }

  Widget _buildSignatureLine(String label) {
    return Column(
      children: [
        Container(width: 180, height: 1, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔘 ACTION BUTTONS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          if (_currentOrder.isDraft) _buildDraftInfoBar(),
          Row(
            children: [
              // Preview Button
              _buildActionButton(
                icon: _currentOrder.isDraft ? Icons.preview_rounded : Icons.picture_as_pdf_rounded,
                label: _currentOrder.isDraft ? 'Preview' : 'View PDF',
                color: _currentOrder.isDraft ? Colors.orange : Colors.red.shade600,
                onPressed: _handlePreview,
                isLoading: _isGeneratingPDF,
              ),
              const SizedBox(width: 10),

              // Print Button
              _buildActionButton(
                icon: Icons.print_rounded,
                label: 'Print',
                color: Colors.grey.shade700,
                onPressed: _handlePrint,
              ),
              const SizedBox(width: 10),

              // Edit Button
              // Edit or View depending on status
              if (_currentOrder.isDraft)
                _buildActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  color: Colors.blue.shade600,
                  onPressed: _handleEdit,
                )
              else
                _buildActionButton(
                  icon: Icons.remove_red_eye_rounded,
                  label: 'View',
                  color: Colors.grey.shade700,
                  onPressed: _handleView,
                ),
              const SizedBox(width: 10),

              // Delete Button (only for Draft)
              if (_currentOrder.isDraft && widget.onDelete != null)
                _buildActionButton(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  color: Colors.red.shade600,
                  onPressed: widget.onDelete!,
                ),

              const Spacer(),

              // Cancel Button (for ordered/delivered orders)
              if ((_currentOrder.isOrdered || _currentOrder.isDelivered) && widget.onCancel != null)
                _buildActionButton(
                  icon: Icons.cancel,
                  label: 'Cancel',
                  color: Colors.red.shade600,
                  onPressed: widget.onCancel!,
                ),

              // Primary Action Button
              _buildPrimaryActionButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDraftInfoBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(child: Text('Draft documents include watermark. Place order for official version.', style: TextStyle(fontSize: 12, color: Colors.orange.shade800))),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: color))
          : Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildPrimaryActionButton() {
    // Draft: Place Order
    if (_currentOrder.isDraft) {
      return _buildGlowingButton(
        icon: Icons.send_rounded,
        label: 'Place Order',
        color: Colors.green,
        onPressed: _handlePlaceOrder,
      );
    }

    // Ordered: Confirm Delivery
    if (_currentOrder.isOrdered) {
      return _buildGlowingButton(
        icon: Icons.local_shipping_rounded,
        label: 'Confirm Delivery',
        color: _canConfirmDelivery ? Colors.blue : Colors.grey,
        onPressed: _canConfirmDelivery ? _handleConfirmDelivery : _showDeliveryRequirementsWarning,
      );
    }

    // Delivered: Mark as Paid
    if (_currentOrder.isDelivered) {
      return _buildGlowingButton(
        icon: Icons.payments_rounded,
        label: 'Mark as Paid',
        color: Colors.green,
        onPressed: _showPaymentConfirmationDialog,
      );
    }

    // Paid: Completed
    if (_currentOrder.isPaid) {
      return _buildStatusChip(Icons.check_circle_rounded, 'Completed', Colors.green);
    }

    // Cancelled
    if (_currentOrder.isCancelled) {
      return _buildStatusChip(Icons.cancel_rounded, 'Cancelled', Colors.red);
    }

    return const SizedBox.shrink();
  }

  Widget _buildGlowingButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildStatusChip(IconData icon, String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.shade700, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color.shade700, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 ACTION HANDLERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Handle Preview Button - Opens Full Screen Preview
  void _handlePreview() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _buildFullScreenPreview(),
    );
  }

  /// Handle Print Button - Generates and Prints PDF
  Future<void> _handlePrint() async {
    setState(() => _isGeneratingPDF = true);

  // try {
  //   final pdfData = await _generatePDF();

  //   await printing.layoutPdf(
  //     onLayout: (format) async => pdfData,
  //     name: '${_currentOrder.poId}.pdf',
  //   );

  //     _showSuccessSnackBar('Print dialog opened for ${_currentOrder.poId}');
  //   } catch (e) {
  //     _showErrorSnackBar('Failed to print: $e');
  //   } finally {
  //     setState(() => _isGeneratingPDF = false);
  //   }
  }

  /// Handle Edit Button - Opens Edit Dialog or Full-Screen Edit
  void _handleEdit() {
    if (_currentOrder.isDraft) {
      // For Draft POs, navigate to full-screen edit
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditPODialog(
            order: _currentOrder,
            suppliers: widget.suppliers,
            onUpdate: (updatedOrder) {
              setState(() {
                _currentOrder = updatedOrder;
              });
              widget.onOrderUpdated?.call(updatedOrder);
              _showSuccessSnackBar('Purchase Order updated successfully!');
            },
          ),
        ),
      );
    } else {
      // For non-draft POs, show small edit dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildEditDialog(),
      );
    }
  }

  /// Handle View Button - Opens Full Screen Preview for non-draft orders
  void _handleView() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _buildFullScreenPreview(),
    );
  }

  /// Handle Place Order (Draft -> Ordered)
  void _handlePlaceOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.send_rounded, color: Colors.green.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Place Order'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to place this order?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What happens next:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                  const SizedBox(height: 8),
                  _buildInfoPoint('Status changes to "Ordered"'),
                  _buildInfoPoint('Official document generated (no watermark)'),
                  _buildInfoPoint('Ready to send to supplier'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus('Ordered');
              _showSuccessSnackBar('Order placed successfully! Status: ORDERED');
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Confirm'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Handle Confirm Delivery (Ordered -> Delivered)
  void _handleConfirmDelivery() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.local_shipping_rounded, color: Colors.blue.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Confirm Delivery'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Confirm that all items have been received?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text('${_deliveryItems.length} items verified', style: TextStyle(color: Colors.green.shade700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.receipt, size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text('Invoice #${_invoiceDetails.invoiceNumber}', style: TextStyle(color: Colors.green.shade700)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                // Update delivery verification in backend
                final deliveryItemsMap = _deliveryItems.map((item) => item.toJson()).toList();
                await context.read<PurchaseOrderCubit>().updateDeliveryVerification(
                  widget.order.id!,
                  deliveryItemsMap,
                );

                Navigator.pop(context);
                _updateStatus('Delivered');
                widget.onDeliveryVerified?.call(_deliveryItems);
                _showSuccessSnackBar('Delivery confirmed! Status: DELIVERED');
              } catch (e) {
                _showErrorSnackBar('Failed to confirm delivery: $e');
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Confirm Delivery'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Show warning if delivery requirements not met
  void _showDeliveryRequirementsWarning() {
    final issues = <String>[];
    if (!_allItemsVerified) issues.add('Verify all received items');
    if (!_invoiceDetails.hasInvoice) issues.add('Upload supplier invoice');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Before confirming: ${issues.join(', ')}')),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(Icons.arrow_right, size: 16, color: Colors.blue.shade600),
          const SizedBox(width: 4),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: Colors.blue.shade700))),
        ],
      ),
    );
  }

  /// Update Order Status
  void _updateStatus(String newStatus) {
    setState(() {
      // Create updated order with new status
      _currentOrder = _currentOrder.copyWith(status: newStatus);
    });
    widget.onStatusChanged?.call(newStatus);
    widget.onOrderUpdated?.call(_currentOrder);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📄 FULL SCREEN PREVIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFullScreenPreview() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _currentOrder.isDraft ? Colors.orange.shade600 : Colors.indigo.shade700,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(_currentOrder.isDraft ? Icons.preview_rounded : Icons.picture_as_pdf_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_currentOrder.isDraft ? 'Draft Preview' : 'Official Document Preview', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(_currentOrder.poId, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                      ],
                    ),
                  ),
                  if (_currentOrder.isDraft)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: const Text('WITH WATERMARK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(width: 12),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
            ),

            // Content with watermark
            Expanded(
              child: Stack(
                children: [
                  if (_currentOrder.isDraft)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.4,
                            child: Text('DRAFT', style: TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: Colors.orange.withOpacity(0.1), letterSpacing: 20)),
                          ),
                        ),
                      ),
                    ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCompanyHeader(),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        _buildPODetails(),
                        const SizedBox(height: 32),
                        _buildItemsTable(),
                        const SizedBox(height: 24),
                        _buildTotalsSection(),
                        const SizedBox(height: 32),
                        _buildTermsSection(),
                        const SizedBox(height: 24),
                        _buildSignatureSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 18), label: const Text('Close')),
                  const SizedBox(width: 12),
                  if (!_currentOrder.isDraft)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _handlePrint();
                      },
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: const Text('Print Document'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _handlePlaceOrder();
                      },
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Place Order'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✏️ EDIT DIALOG
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildEditDialog() {
    final notesController = TextEditingController(text: _currentOrder.notes);
    DateTime? expectedDelivery = _currentOrder.expectedDelivery;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.edit_rounded, color: Colors.blue.shade700, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Purchase Order', style: TextStyle(fontSize: 18)),
                  Text(_currentOrder.poId, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.normal)),
                ],
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expected Delivery Date (only for Draft POs)
                  if (_currentOrder.isDraft) ...[
                    const Text('Expected Delivery Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: expectedDelivery ?? DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => expectedDelivery = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.grey.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                expectedDelivery != null ? DateFormat('d MMMM yyyy').format(expectedDelivery!) : 'Select date',
                                style: TextStyle(fontSize: 15, color: expectedDelivery != null ? Colors.black87 : Colors.grey.shade500),
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Notes
                  const Text('Notes / Remarks', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add any notes for this order...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),

                  // Status Info (Read Only)
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Current Status: ${_currentOrder.status.toUpperCase()}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton.icon(
              onPressed: () {
                // Save changes
                setState(() {
                  _currentOrder = _currentOrder.copyWith(
                    expectedDelivery: expectedDelivery,
                    notes: notesController.text.isNotEmpty ? notesController.text : null,
                  );
                });
                widget.onOrderUpdated?.call(_currentOrder);
                Navigator.pop(context);
                _showSuccessSnackBar('Changes saved successfully!');
              },
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📤 INVOICE UPLOAD DIALOG
  // ═══════════════════════════════════════════════════════════════════════════
  void _showInvoiceUploadDialog() {
    final invoiceNumberController = TextEditingController(text: _invoiceDetails.invoiceNumber);
    final notesController = TextEditingController(text: _invoiceDetails.notes);
    DateTime selectedDate = _invoiceDetails.receivedDate ?? DateTime.now();
    File? tempSelectedImage = _selectedInvoiceImage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.indigo.shade100, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.receipt_long, color: Colors.indigo.shade700, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload Supplier Invoice', style: TextStyle(fontSize: 18)),
                    Text('Enter invoice details', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal)),
                  ],
                ),
              ],
            ),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Upload
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: tempSelectedImage != null ? Colors.green.shade400 : Colors.grey.shade300, width: tempSelectedImage != null ? 2 : 1),
                      ),
                      child: tempSelectedImage != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.file(tempSelectedImage!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Material(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                    child: InkWell(
                                      onTap: () => setDialogState(() => tempSelectedImage = null),
                                      borderRadius: BorderRadius.circular(20),
                                      child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.close, color: Colors.white, size: 16)),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : InkWell(
                              onTap: () async {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  setDialogState(() => tempSelectedImage = File(pickedFile.path));
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text('Tap to upload invoice image', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Invoice Number
                    TextFormField(
                      controller: invoiceNumberController,
                      decoration: InputDecoration(
                        labelText: 'Invoice Number *',
                        hintText: 'e.g., INV-2024-001',
                        prefixIcon: const Icon(Icons.numbers),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Received Date
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                        if (picked != null) setDialogState(() => selectedDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.grey.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Received Date *', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  const SizedBox(height: 2),
                                  Text(DateFormat('d MMMM yyyy').format(selectedDate), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
                        prefixIcon: const Icon(Icons.note),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                          const SizedBox(width: 10),
                          Expanded(child: Text('After saving, you can confirm delivery.', style: TextStyle(fontSize: 12, color: Colors.blue.shade800))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              ElevatedButton.icon(
                onPressed: invoiceNumberController.text.isNotEmpty
                    ? () async {
                        final newInvoiceDetails = InvoiceDetails(
                          invoiceNumber: invoiceNumberController.text.trim(),
                          receivedDate: selectedDate,
                          notes: notesController.text.trim(),
                          uploadedAt: DateTime.now(),
                        );

                        // Upload invoice image if selected
                        if (tempSelectedImage != null) {
                          await context.read<PurchaseOrderCubit>().uploadInvoiceImage(
                            widget.order.id!,
                            tempSelectedImage!.path,
                          );
                        }

                        // Update local state with invoice details
                        setState(() {
                          _invoiceDetails = newInvoiceDetails;
                          _selectedInvoiceImage = tempSelectedImage;
                        });

                        widget.onInvoiceUploaded?.call(newInvoiceDetails);
                        Navigator.pop(dialogContext);
                        _showSuccessSnackBar('Invoice #${invoiceNumberController.text} saved and uploaded!');
                      }
                    : null,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Save Invoice'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade300),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💳 PAYMENT DIALOG
  // ═══════════════════════════════════════════════════════════════════════════
  void _showPaymentConfirmationDialog() {
    final paymentRefController = TextEditingController();
    String paymentMethod = 'Bank Transfer';
    DateTime paymentDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.payments_rounded, color: Colors.green.shade700, size: 24),
                ),
                const SizedBox(width: 12),
                const Text('Mark as Paid'),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Invoice #', style: TextStyle(color: Colors.grey.shade600)),
                            Text(_invoiceDetails.invoiceNumber ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Amount', style: TextStyle(color: Colors.grey.shade600)),
                            Text('Rs ${NumberFormat('#,##0.00').format(_grandTotal)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment Method
                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: const Icon(Icons.account_balance),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: ['Bank Transfer', 'Cash', 'Cheque', 'Credit Card', 'Online Payment'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (value) => setDialogState(() => paymentMethod = value ?? 'Bank Transfer'),
                  ),
                  const SizedBox(height: 16),

                  // Reference
                  TextFormField(
                    controller: paymentRefController,
                    decoration: InputDecoration(
                      labelText: 'Payment Reference',
                      hintText: 'e.g., TRX-123456',
                      prefixIcon: const Icon(Icons.tag),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _updateStatus('Paid');
                  _showSuccessSnackBar('${_currentOrder.poId} marked as PAID!');
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Confirm Payment'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📄 PDF GENERATION
  // ═══════════════════════════════════════════════════════════════════════════
  // Future<Uint8List> _generatePDF() async {
  //   final pdf = pw.Document();

  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: pw.PdfPageFormat.a4,
  //       margin: const pw.EdgeInsets.all(40),
  //       build: (pw.Context context) {
  //         return pw.Stack(
  //           children: [
  //             // Watermark for Draft
  //             if (_currentOrder.isDraft)
  //               pw.Positioned.fill(
  //                 child: pw.Center(
  //                   child: pw.Transform.rotate(
  //                     angle: -0.4,
  //                     child: pw.Text(
  //                       'DRAFT',
  //                       style: pw.TextStyle(
  //                         fontSize: 80,
  //                         fontWeight: pw.FontWeight.bold,
  //                         color: pw.PdfColors.orange100,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),

  //             // Content
  //             pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //               children: [
  //                 // Header
  //                 pw.Row(
  //                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     pw.Column(
  //                       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                       children: [
  //                         pw.Text('Immense Home (Private) Limited', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: pw.PdfColors.indigo)),
  //                         pw.SizedBox(height: 4),
  //                         pw.Text('123 Main Street, Colombo 07', style: const pw.TextStyle(fontSize: 10, color: pw.PdfColors.grey700)),
  //                         pw.Text('Tel: +94 11 234 5678', style: const pw.TextStyle(fontSize: 10, color: pw.PdfColors.grey700)),
  //                       ],
  //                     ),
  //                     pw.Container(
  //                       padding: const pw.EdgeInsets.all(12),
  //                       decoration: pw.BoxDecoration(
  //                         border: pw.Border.all(color: pw.PdfColors.indigo),
  //                         borderRadius: pw.BorderRadius.circular(8),
  //                       ),
  //                       child: pw.Column(
  //                         children: [
  //                           pw.Text(_currentOrder.isDraft ? 'DRAFT' : 'PURCHASE ORDER', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: pw.PdfColors.indigo)),
  //                           pw.SizedBox(height: 4),
  //                           pw.Text(_currentOrder.poId, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 pw.SizedBox(height: 20),
  //                 pw.Divider(color: pw.PdfColors.indigo, thickness: 2),
  //                 pw.SizedBox(height: 20),

  //                 // Details
  //                 pw.Row(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                   children: [
  //                     pw.Expanded(
  //                       child: pw.Column(
  //                         crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                         children: [
  //                           pw.Text('SUPPLIER', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: pw.PdfColors.grey600)),
  //                           pw.SizedBox(height: 8),
  //                           pw.Text(_currentOrder.supplier.name, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
  //                           pw.Text(_currentOrder.supplier.phone, style: const pw.TextStyle(fontSize: 10)),
  //                         ],
  //                       ),
  //                     ),
  //                     pw.Expanded(
  //                       child: pw.Column(
  //                         crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                         children: [
  //                           pw.Text('ORDER DETAILS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: pw.PdfColors.grey600)),
  //                           pw.SizedBox(height: 8),
  //                           pw.Text('Date: ${DateFormat('d MMMM yyyy').format(_currentOrder.orderDate)}', style: const pw.TextStyle(fontSize: 10)),
  //                           pw.Text('Customer: ${_currentOrder.customerName}', style: const pw.TextStyle(fontSize: 10)),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 pw.SizedBox(height: 24),

  //                 // Table
  //                 pw.Table(
  //                   border: pw.TableBorder.all(color: pw.PdfColors.grey400),
  //                   children: [
  //                     // Header
  //                     pw.TableRow(
  //                       decoration: const pw.BoxDecoration(color: pw.PdfColors.indigo),
  //                       children: [
  //                         _pdfTableHeader('#', 30),
  //                         _pdfTableHeader('Description', 200),
  //                         _pdfTableHeader('Qty', 60),
  //                         _pdfTableHeader('Unit Price', 80),
  //                         _pdfTableHeader('Total', 80),
  //                       ],
  //                     ),
  //                     // Rows
  //                     ..._currentOrder.items.asMap().entries.map((entry) {
  //                       final index = entry.key;
  //                       final item = entry.value;
  //                       return pw.TableRow(
  //                         children: [
  //                           _pdfTableCell('${index + 1}', 30),
  //                           _pdfTableCell(item.itemName, 200, align: pw.TextAlign.left),
  //                           _pdfTableCell('${item.quantity}', 60),
  //                           _pdfTableCell(NumberFormat('#,##0.00').format(item.unitPrice), 80, align: pw.TextAlign.right),
  //                           _pdfTableCell(NumberFormat('#,##0.00').format(item.quantity * item.unitPrice), 80, align: pw.TextAlign.right),
  //                         ],
  //                       );
  //                     }),
  //                   ],
  //                 ),
  //                 pw.SizedBox(height: 16),

  //                 // Total
  //                 pw.Align(
  //                   alignment: pw.Alignment.centerRight,
  //                   child: pw.Container(
  //                     width: 200,
  //                     padding: const pw.EdgeInsets.all(12),
  //                     decoration: pw.BoxDecoration(
  //                       color: pw.PdfColors.indigo50,
  //                       borderRadius: pw.BorderRadius.circular(8),
  //                     ),
  //                     child: pw.Row(
  //                       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         pw.Text('TOTAL:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                         pw.Text('Rs ${NumberFormat('#,##0.00').format(_grandTotal)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 pw.Spacer(),

  //                 // Signatures
  //                 pw.Row(
  //                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     pw.Column(
  //                       children: [
  //                         pw.Container(width: 150, height: 1, color: pw.PdfColors.grey400),
  //                         pw.SizedBox(height: 4),
  //                         pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 10, color: pw.PdfColors.grey600)),
  //                       ],
  //                     ),
  //                     pw.Column(
  //                       children: [
  //                         pw.Container(width: 150, height: 1, color: pw.PdfColors.grey400),
  //                         pw.SizedBox(height: 4),
  //                         pw.Text('Date', style: const pw.TextStyle(fontSize: 10, color: pw.PdfColors.grey600)),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );

  //   return pdf.save();
  // }

  // pw.Widget _pdfTableHeader(String text, double width) {
  //   return pw.Container(
  //     width: width,
  //     padding: const pw.EdgeInsets.all(8),
  //     child: pw.Text(text, style: pw.TextStyle(color: pw.PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.center),
  //   );
  // }

  // pw.Widget _pdfTableCell(String text, double width, {pw.TextAlign align = pw.TextAlign.center}) {
  //   return pw.Container(
  //     width: width,
  //     padding: const pw.EdgeInsets.all(8),
  //     child: pw.Text(text, style: const pw.TextStyle(fontSize: 10), textAlign: align),
  //   );
  // }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔔 SNACKBARS
  // ═══════════════════════════════════════════════════════════════════════════
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 12), Text(message)]),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.error, color: Colors.white), const SizedBox(width: 12), Text(message)]),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
