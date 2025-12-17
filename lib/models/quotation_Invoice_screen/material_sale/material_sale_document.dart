// lib/models/material_sale/material_sale_document.dart

import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sales_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/payment_record.dart';

class MaterialSaleDocument {
  String? id; // MongoDB ObjectId
  String invoiceNumber;
  DateTime saleDate;

  // Customer Details
  String customerName;
  String customerPhone;
  String? customerAddress;

  // Payment Terms
  int paymentTerms;

  // Due Date
  DateTime dueDate;

  // Line Items
  List<MaterialSaleItem> items;

  // Payment
  List<PaymentRecord> paymentHistory;
  MaterialSaleStatus status;

  // Notes
  String? notes;

  MaterialSaleDocument({
    this.id,
    required this.invoiceNumber,
    required this.saleDate,
    required this.customerName,
    this.customerPhone = '',
    this.customerAddress,
    this.paymentTerms = 30,
    DateTime? dueDate,
    List<MaterialSaleItem>? items,
    List<PaymentRecord>? paymentHistory,
    this.status = MaterialSaleStatus.pending,
    this.notes,
  }) : dueDate = dueDate ?? saleDate.add(const Duration(days: 30)),
       items = items ?? [],
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

  // Factory constructor for JSON deserialization
  factory MaterialSaleDocument.fromJson(Map<String, dynamic> json) {
    return MaterialSaleDocument(
      id: json['_id'] as String?,
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      saleDate: DateTime.parse(json['saleDate'] as String? ?? DateTime.now().toIso8601String()),
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      customerAddress: json['customerAddress'] as String?,
      paymentTerms: json['paymentTerms'] as int? ?? 30,
      dueDate: DateTime.parse(json['dueDate'] as String? ?? DateTime.now().add(const Duration(days: 30)).toIso8601String()),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => MaterialSaleItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      paymentHistory: (json['paymentHistory'] as List<dynamic>?)
          ?.map((payment) => PaymentRecord.fromJson(payment as Map<String, dynamic>))
          .toList() ?? [],
      status: _statusFromString(json['status'] as String? ?? 'pending'),
      notes: json['notes'] as String?,
    );
  }

  // Convert to JSON with proper ISO8601 date formatting for backend validation
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'invoiceNumber': invoiceNumber,
      'saleDate': _formatDateForBackend(saleDate),
      'customerName': customerName,
      'customerPhone': customerPhone,
      if (customerAddress != null) 'customerAddress': customerAddress,
      'paymentTerms': paymentTerms,
      'dueDate': _formatDateForBackend(dueDate),
      'items': items.map((item) => item.toJson()).toList(),
      'paymentHistory': paymentHistory.map((payment) => payment.toJson()).toList(),
      'status': _statusToString(status),
      if (notes != null) 'notes': notes,
    };
  }

  // Format date for backend validation (strict ISO8601 without microseconds, with 'Z')
  String _formatDateForBackend(DateTime date) {
    // Convert to UTC and format as ISO8601 without microseconds
    final utcDate = date.toUtc();
    final isoString = utcDate.toIso8601String();
    // Remove microseconds (everything after the dot) and ensure 'Z' suffix
    final dotIndex = isoString.indexOf('.');
    final formattedDate = dotIndex != -1
        ? '${isoString.substring(0, dotIndex)}Z'
        : isoString.replaceAll('+00:00', 'Z');

    return formattedDate;
  }

  // Helper method to convert status string to enum
  static MaterialSaleStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return MaterialSaleStatus.pending;
      case 'partial':
        return MaterialSaleStatus.partial;
      case 'paid':
        return MaterialSaleStatus.paid;
      case 'cancelled':
        return MaterialSaleStatus.cancelled;
      default:
        return MaterialSaleStatus.pending;
    }
  }

  // Helper method to convert status enum to string
  static String _statusToString(MaterialSaleStatus status) {
    switch (status) {
      case MaterialSaleStatus.pending:
        return 'pending';
      case MaterialSaleStatus.partial:
        return 'partial';
      case MaterialSaleStatus.paid:
        return 'paid';
      case MaterialSaleStatus.cancelled:
        return 'cancelled';
    }
  }

  // Deep copy
  MaterialSaleDocument copyWith({
    String? invoiceNumber,
    DateTime? saleDate,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    int? paymentTerms,
    DateTime? dueDate,
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
      paymentTerms: paymentTerms ?? this.paymentTerms,
      dueDate: dueDate ?? this.dueDate,
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
