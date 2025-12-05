import 'document_enums.dart';
import 'invoice_line_item.dart';
import 'payment_record.dart';

class QuotationDocument {
  String documentNumber;
  DocumentType type;
  DocumentStatus status;
  String customerName;
  String customerPhone;
  String customerAddress;
  String projectTitle;
  DateTime invoiceDate;
  DateTime dueDate;
  List<InvoiceLineItem> lineItems;
  List<PaymentRecord> paymentHistory;

  QuotationDocument({
    required this.documentNumber,
    this.type = DocumentType.quotation,
    this.status = DocumentStatus.pending,
    required this.customerName,
    this.customerPhone = '',
    this.customerAddress = '',
    this.projectTitle = '',
    required this.invoiceDate,
    required this.dueDate,
    List<InvoiceLineItem>? lineItems,
    List<PaymentRecord>? paymentHistory,
  })  : lineItems = lineItems ?? [],
        paymentHistory = paymentHistory ?? [];

  // Computed Properties
  double get subtotal => lineItems.fold(0, (sum, item) => sum + item.amount);

  double get totalPayments =>
      paymentHistory.fold(0.0, (sum, payment) => sum + payment.amount);

  double get amountDue => subtotal - totalPayments;

  String get displayDocumentNumber {
    final prefix = type == DocumentType.quotation ? 'QUO' : 'INV';
    return '$prefix-$documentNumber';
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