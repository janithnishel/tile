import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/invoice_line_item.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/payment_record.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';


// Master Item List
final List<ItemDescription> masterItemList = [
  ItemDescription('LVT & installation 2mm', sellingPrice: 365.00, unit: 'sqft'),
  ItemDescription('Skirting 3" inch', sellingPrice: 410.00, unit: 'linear ft'),
  ItemDescription('Floor preparation', sellingPrice: 8500.00, unit: 'Lump Sum'),
  ItemDescription('Transport', sellingPrice: 6850.00, unit: 'Lump Sum'),
  ItemDescription('Other (Custom Item)', sellingPrice: 0.00, unit: 'units'),
];

// Mock Document List
List<QuotationDocument> mockDocuments = [
  QuotationDocument(
    documentNumber: '1499',
    type: DocumentType.quotation,
    status: DocumentStatus.pending,
    customerName: 'Mr. Suresh Jayathunga',
    customerPhone: '+94 76 553 4844',
    customerAddress: 'Colombo, LK',
    projectTitle: 'Villa LVT Flooring',
    invoiceDate: DateTime(2025, 7, 2),
    dueDate: DateTime(2025, 7, 9),
    lineItems: [
      InvoiceLineItem(
        item: masterItemList.firstWhere((i) => i.name.contains('LVT')),
        quantity: 385.0,
      ),
      InvoiceLineItem(
        item: masterItemList.firstWhere((i) => i.name.contains('Skirting')),
        quantity: 120.0,
      ),
      InvoiceLineItem(
        item: masterItemList.firstWhere((i) => i.name.contains('Floor')),
        quantity: 1.0,
      ),
      InvoiceLineItem(
        item: masterItemList.firstWhere((i) => i.name.contains('Transport')),
        quantity: 1.0,
      ),
    ],
  ),
  QuotationDocument(
    documentNumber: '1500',
    type: DocumentType.invoice,
    status: DocumentStatus.partial,
    customerName: 'Mr. Suresh Jayathunga',
    customerPhone: '+94 76 553 4844',
    customerAddress: 'Colombo, LK',
    projectTitle: 'Office Renovation',
    invoiceDate: DateTime(2025, 6, 15),
    dueDate: DateTime(2025, 7, 15),
    lineItems: [
      InvoiceLineItem(
        item: masterItemList.firstWhere((i) => i.name.contains('LVT')),
        quantity: 200.0,
      ),
    ],
    paymentHistory: [
      PaymentRecord(50000.00, DateTime(2025, 6, 20), description: 'Advance'),
    ],
  ),
  QuotationDocument(
    documentNumber: '1498',
    type: DocumentType.invoice,
    status: DocumentStatus.partial,
    customerName: 'Mrs. Kumudu Perera',
    customerPhone: '+94 71 123 4567',
    customerAddress: 'Kandy, LK',
    projectTitle: 'Home Flooring Project',
    invoiceDate: DateTime(2025, 6, 20),
    dueDate: DateTime(2025, 7, 20),
    lineItems: [
      InvoiceLineItem(
        item: masterItemList.firstWhere((i) => i.name.contains('LVT')),
        quantity: 200.0,
      ),
      InvoiceLineItem(
        item: masterItemList.firstWhere((i) => i.name.contains('Skirting')),
        quantity: 80.0,
      ),
      InvoiceLineItem(
        item: masterItemList.firstWhere((i) => i.name.contains('Other')),
        quantity: 1.0,
        customDescription: 'Extra Wire',
        isOriginalQuotationItem: false,
      ),
    ],
    paymentHistory: [
      PaymentRecord(100000.00, DateTime(2025, 6, 25), description: 'Advance'),
    ],
  ),
  QuotationDocument(
    documentNumber: '1497',
    type: DocumentType.invoice,
    status: DocumentStatus.paid,
    customerName: 'Mr. Nimal Bandara',
    customerPhone: '+94 77 987 6543',
    customerAddress: 'Galle, LK',
    projectTitle: 'Beach House Flooring',
    invoiceDate: DateTime(2025, 5, 10),
    dueDate: DateTime(2025, 6, 10),
    lineItems: [
      InvoiceLineItem(
        item: masterItemList.firstWhere((i) => i.name.contains('LVT')),
        quantity: 100.0,
      ),
      InvoiceLineItem(
        item: masterItemList.firstWhere((i) => i.name.contains('Transport')),
        quantity: 1.0,
      ),
    ],
    paymentHistory: [
      PaymentRecord(42000.00, DateTime(2025, 5, 15), description: 'Advance'),
      PaymentRecord(12000.00, DateTime(2025, 6, 5), description: 'Final Settlement'),
    ],
  ),
  QuotationDocument(
    documentNumber: '1496',
    type: DocumentType.quotation,
    status: DocumentStatus.approved,
    customerName: 'Mrs. Kumudu Perera',
    customerPhone: '+94 71 123 4567',
    customerAddress: 'Kandy, LK',
    projectTitle: 'Kitchen Renovation',
    invoiceDate: DateTime(2025, 7, 1),
    dueDate: DateTime(2025, 7, 15),
    lineItems: [
      InvoiceLineItem(
        item: masterItemList.firstWhere((i) => i.name.contains('Floor')),
        quantity: 1.0,
      ),
    ],
  ),
];