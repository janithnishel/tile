// lib/models/material_sale/material_sale_document.dart

import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sales_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/payment_record.dart';

class MaterialSaleDocument {
  String invoiceNumber;
  DateTime saleDate;

  // Customer Details
  String customerName;
  String customerPhone;
  String? customerAddress;

  // Line Items
  List<MaterialSaleItem> items;

  // Payment
  List<PaymentRecord> paymentHistory;
  MaterialSaleStatus status;

  // Notes
  String? notes;

  MaterialSaleDocument({
    required this.invoiceNumber,
    required this.saleDate,
    required this.customerName,
    this.customerPhone = '',
    this.customerAddress,
    List<MaterialSaleItem>? items,
    List<PaymentRecord>? paymentHistory,
    this.status = MaterialSaleStatus.pending,
    this.notes,
  }) : items = items ?? [],
       paymentHistory = paymentHistory ?? [];

  // ============================================
  // COMPUTED PROPERTIES
  // ============================================

  // Display invoice number with prefix
  String get displayInvoiceNumber => 'MS-$invoiceNumber';

  // Total amount (sum of all items)
  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + item.amount);
  }

  // Total cost (sum of all item costs)
  double get totalCost {
    return items.fold(0.0, (sum, item) => sum + item.totalCost);
  }

  // Total profit
  double get totalProfit => totalAmount - totalCost;

  // Profit percentage
  double get profitPercentage {
    if (totalCost > 0) {
      return ((totalAmount - totalCost) / totalCost) * 100;
    }
    return 0;
  }

  // Total sqft
  double get totalSqft {
    return items.fold(0.0, (sum, item) => sum + item.totalSqft);
  }

  // Total planks
  double get totalPlanks {
    return items.fold(0.0, (sum, item) => sum + item.plank);
  }

  // Total paid amount
  double get totalPaid {
    return paymentHistory.fold(0.0, (sum, p) => sum + p.amount);
  }

  // Amount due
  double get amountDue => totalAmount - totalPaid;

  // Check if fully paid
  bool get isFullyPaid => amountDue <= 0;

  // Check if has advance payment
  bool get hasAdvancePayment => paymentHistory.isNotEmpty && !isFullyPaid;

  // ============================================
  // STATUS HELPERS
  // ============================================

  bool get isPending => status == MaterialSaleStatus.pending;
  bool get isPartial => status == MaterialSaleStatus.partial;
  bool get isPaid => status == MaterialSaleStatus.paid;
  bool get isCancelled => status == MaterialSaleStatus.cancelled;

  // ============================================
  // METHODS
  // ============================================

  // Add payment and update status
  void addPayment(PaymentRecord payment) {
    paymentHistory.add(payment);
    _updateStatus();
  }

  // Update status based on payments
  void _updateStatus() {
    if (amountDue <= 0) {
      status = MaterialSaleStatus.paid;
    } else if (paymentHistory.isNotEmpty) {
      status = MaterialSaleStatus.partial;
    } else {
      status = MaterialSaleStatus.pending;
    }
  }

  // Deep copy
  MaterialSaleDocument copyWith({
    String? invoiceNumber,
    DateTime? saleDate,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    List<MaterialSaleItem>? items,
    List<PaymentRecord>? paymentHistory,
    MaterialSaleStatus? status,
    String? notes,
  }) {
    return MaterialSaleDocument(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      saleDate: saleDate ?? this.saleDate,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items.map((i) => i.copyWith()).toList(),
      paymentHistory:
          paymentHistory ??
          this.paymentHistory
              .map(
                (p) =>
                    PaymentRecord(p.amount, p.date, description: p.description),
              )
              .toList(),
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
