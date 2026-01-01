import 'document_enums.dart';
import 'invoice_line_item.dart';
import 'item_description.dart';
import 'payment_record.dart';
import 'service_item.dart';

class QuotationDocument {
  String? id; // MongoDB ObjectId
  String documentNumber;
  DocumentType type;
  DocumentStatus status;
  String customerName;
  String customerPhone;
  String customerAddress;
  String projectTitle;
  DateTime invoiceDate;
  DateTime dueDate;
  int paymentTerms;
  List<InvoiceLineItem> lineItems;
  List<ServiceItem> serviceItems;
  List<PaymentRecord> paymentHistory;

  QuotationDocument({
    this.id,
    required this.documentNumber,
    this.type = DocumentType.quotation,
    this.status = DocumentStatus.pending,
    required this.customerName,
    this.customerPhone = '',
    this.customerAddress = '',
    this.projectTitle = '',
    required this.invoiceDate,
    required this.dueDate,
    this.paymentTerms = 30,
    List<InvoiceLineItem>? lineItems,
    List<ServiceItem>? serviceItems,
    List<PaymentRecord>? paymentHistory,
  })  : lineItems = lineItems ?? [],
        serviceItems = serviceItems ?? [],
        paymentHistory = paymentHistory ?? [];

  // Factory constructor for JSON deserialization
  factory QuotationDocument.fromJson(Map<String, dynamic> json) {
    return QuotationDocument(
      id: json['_id'] as String?,
      documentNumber: json['documentNumber']?.toString() ?? '',
      type: json['type'] == 'invoice' ? DocumentType.invoice : DocumentType.quotation,
      status: _statusFromString(json['status'] as String? ?? 'pending'),
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      customerAddress: json['customerAddress'] as String? ?? '',
      projectTitle: json['projectTitle'] as String? ?? '',
      invoiceDate: DateTime.parse(json['invoiceDate'] as String? ?? DateTime.now().toIso8601String()).toLocal(),
      dueDate: DateTime.parse(json['dueDate'] as String? ?? DateTime.now().toIso8601String()).toLocal(),
      paymentTerms: json['paymentTerms'] as int? ?? 30,
      lineItems: (json['lineItems'] as List<dynamic>?)
          ?.map((item) => InvoiceLineItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      serviceItems: (json['serviceItems'] as List<dynamic>?)
          ?.map((item) => ServiceItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      paymentHistory: (json['paymentHistory'] as List<dynamic>?)
          ?.map((payment) => PaymentRecord.fromJson(payment as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Convert to JSON with proper ISO8601 date formatting for backend validation
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      // ✅ Always send full document number with prefix
      'documentNumber': documentNumber,
      'type': type == DocumentType.invoice ? 'invoice' : 'quotation',
      'status': _statusToString(status),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'projectTitle': projectTitle,
      'invoiceDate': _formatDateForBackend(invoiceDate),
      'dueDate': _formatDateForBackend(dueDate),
      'paymentTerms': paymentTerms,
      'lineItems': lineItems.map((item) => item.toJson()).toList(),
      'serviceItems': serviceItems.map((item) => item.toJson()).toList(),
      'paymentHistory': paymentHistory.map((payment) => payment.toJson()).toList(),
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

    // Debug logging to verify format
    print('📅 Date formatting: ${date.toLocal()} -> $formattedDate');
    return formattedDate;
  }

  // Helper method to convert status string to enum
  static DocumentStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return DocumentStatus.pending;
      case 'approved':
        return DocumentStatus.approved;
      case 'partial':
        return DocumentStatus.partial;
      case 'paid':
        return DocumentStatus.paid;
      case 'closed':
        return DocumentStatus.closed;
      case 'converted':
        return DocumentStatus.converted;
      case 'invoiced':
        return DocumentStatus.invoiced;
      default:
        return DocumentStatus.pending;
    }
  }

  // Helper method to convert status enum to string
  static String _statusToString(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return 'pending';
      case DocumentStatus.approved:
        return 'approved';
      case DocumentStatus.partial:
        return 'partial';
      case DocumentStatus.paid:
        return 'paid';
      case DocumentStatus.closed:
        return 'closed';
      case DocumentStatus.converted:
        return 'converted';
      case DocumentStatus.invoiced:
        return 'invoiced';
    }
  }

  // Computed Properties
  double get subtotal {
    double total = lineItems.fold(0, (sum, item) => sum + item.amount);

    // Add service items to total
    double serviceTotal = serviceItems.fold(0, (sum, item) {
      // If service is already paid, subtract it (negative amount)
      return sum + (item.isAlreadyPaid ? -item.amount : item.amount);
    });

    return total + serviceTotal;
  }

  double get totalPayments =>
      paymentHistory.fold(0.0, (sum, payment) => sum + payment.amount);

  double get amountDue => subtotal - totalPayments;

  String get displayDocumentNumber {
    // Backend now stores prefixed document numbers (QUO-109, INV-109)
    return documentNumber;
  }

  bool get isLocked =>
      status == DocumentStatus.paid || status == DocumentStatus.closed;

  bool get isQuotation => type == DocumentType.quotation;

  bool get isInvoice => type == DocumentType.invoice;

  bool get isPending => status == DocumentStatus.pending;

  bool get isApproved => status == DocumentStatus.approved;

  bool get isPaid => status == DocumentStatus.paid;

  bool get hasOutstandingAmount =>
      type == DocumentType.invoice &&
      status != DocumentStatus.paid &&
      amountDue > 0;
}
