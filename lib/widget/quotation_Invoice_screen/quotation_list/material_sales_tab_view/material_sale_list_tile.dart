
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_enums.dart';

class MaterialSaleListTile extends StatelessWidget {
  final MaterialSaleDocument sale;
  final VoidCallback? onTap;

  const MaterialSaleListTile({
    Key? key,
    required this.sale,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, yyyy');
    final totalAmount = sale.totalAmount;
    final totalPaid = sale.totalPaid;
    final amountDue = sale.amountDue;
    final paymentProgress = totalAmount > 0 ? (totalPaid / totalAmount) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Column(
                  children: [
                    // ═══════════════════════════════════════
                    // 🔝 ROW 1 - Invoice + Status + Arrow
                    // ═══════════════════════════════════════
                    Row(
                      children: [
                        // Invoice Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${sale.invoiceNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Date
                        Text(
                          dateFormat.format(sale.saleDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const Spacer(),

                        // Status
                        _buildStatusBadge(sale.status),

                        const SizedBox(width: 8),

                        // Arrow
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ═══════════════════════════════════════
                    // 👤 ROW 2 - Customer + Items
                    // ═══════════════════════════════════════
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getStatusColor(sale.status).withOpacity(0.2),
                                _getStatusColor(sale.status).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              sale.customerName.isNotEmpty
                                  ? sale.customerName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(sale.status),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Name + Items
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sale.customerName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${sale.items.length} item${sale.items.length == 1 ? '' : 's'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Due Amount (Highlighted)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Due',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              'Rs.${_formatAmount(amountDue)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: amountDue > 0
                                    ? Colors.red.shade600
                                    : Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ═══════════════════════════════════════
                    // 💰 ROW 3 - Total & Paid (Inline)
                    // ═══════════════════════════════════════
                    Row(
                      children: [
                        // Total
                        _buildInlineAmount(
                          Icons.account_balance_wallet_outlined,
                          'Total',
                          totalAmount,
                          Colors.blue,
                        ),

                        const SizedBox(width: 20),

                        // Paid
                        _buildInlineAmount(
                          Icons.check_circle_outline,
                          'Paid',
                          totalPaid,
                          Colors.green,
                        ),

                        const Spacer(),

                        // Percentage Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getProgressColor(paymentProgress).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${(paymentProgress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getProgressColor(paymentProgress),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ═══════════════════════════════════════
              // 📊 BOTTOM - Thin Progress Bar
              // ═══════════════════════════════════════
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft, // ◄── Left එකෙන් start
                  child: FractionallySizedBox(
                    widthFactor: paymentProgress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: _getProgressGradient(paymentProgress),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: const Radius.circular(14),
                          bottomRight: paymentProgress >= 1.0
                              ? const Radius.circular(14)
                              : Radius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // 💵 Inline Amount Widget
  // ═══════════════════════════════════════
  Widget _buildInlineAmount(
    IconData icon,
    String label,
    double amount,
    Color color,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          'Rs.${_formatAmount(amount)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color.shade700,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // 🏷️ Status Badge Widget
  // ═══════════════════════════════════════
  Widget _buildStatusBadge(MaterialSaleStatus status) {
    late Color color;
    late String text;

    switch (status) {
      case MaterialSaleStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case MaterialSaleStatus.partial:
        color = Colors.amber.shade700;
        text = 'Partial';
        break;
      case MaterialSaleStatus.paid:
        color = Colors.green;
        text = 'Paid';
        break;
      case MaterialSaleStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // 🎨 Helper Methods
  // ═══════════════════════════════════════
  Color _getStatusColor(MaterialSaleStatus status) {
    switch (status) {
      case MaterialSaleStatus.pending:
        return Colors.orange;
      case MaterialSaleStatus.partial:
        return Colors.amber.shade700;
      case MaterialSaleStatus.paid:
        return Colors.green;
      case MaterialSaleStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.5) return Colors.amber.shade700;
    return Colors.orange;
  }

  List<Color> _getProgressGradient(double progress) {
    if (progress >= 1.0) {
      return [Colors.green.shade400, Colors.green.shade600];
    }
    if (progress >= 0.5) {
      return [Colors.amber.shade400, Colors.amber.shade600];
    }
    return [Colors.orange.shade400, Colors.orange.shade600];
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 100000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else if (amount >= 1000) {
      return NumberFormat('#,###').format(amount.toInt());
    }
    return amount.toStringAsFixed(0);
  }
}

// Extension for color shades
extension _ColorShade on Color {
  Color get shade700 {
    if (this == Colors.blue) return Colors.blue.shade700;
    if (this == Colors.green) return Colors.green.shade700;
    if (this == Colors.orange) return Colors.orange.shade700;
    if (this == Colors.red) return Colors.red.shade700;
    if (this == Colors.amber) return Colors.amber.shade700;
    return this;
  }
}