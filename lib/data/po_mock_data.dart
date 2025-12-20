import 'package:tilework/models/purchase_order/approved_quotation.dart';
import 'package:tilework/models/purchase_order/po_item.dart';
import 'package:tilework/models/purchase_order/purchase_order.dart';
import 'package:tilework/models/purchase_order/quotation_item.dart';
import 'package:tilework/models/purchase_order/supplier.dart';


// Pre-defined Suppliers
List<Supplier> mockSuppliers = [
  Supplier(
    id: 'SUP001',
    name: 'ABC Hardware',
    phone: '+94 77 123 4567',
    email: 'abc@hardware.lk',
    address: 'Colombo 10',
    categories: ['Hardware'],
  ),
  Supplier(
    id: 'SUP002',
    name: 'Lanka Cement Distributors',
    phone: '+94 71 234 5678',
    email: 'cement@lanka.lk',
    address: 'Kelaniya',
    categories: ['Cement & Sand'],
  ),
  Supplier(
    id: 'SUP003',
    name: 'Royal Tiles Gallery',
    phone: '+94 76 345 6789',
    email: 'tiles@royal.lk',
    address: 'Nugegoda',
    categories: ['Tiles & Flooring'],
  ),
  Supplier(
    id: 'SUP004',
    name: 'Steel Masters',
    phone: '+94 72 456 7890',
    email: 'steel@masters.lk',
    address: 'Peliyagoda',
    categories: ['Steel & Metal'],
  ),
  Supplier(
    id: 'SUP005',
    name: 'Paint World',
    phone: '+94 78 567 8901',
    email: 'paint@world.lk',
    address: 'Maharagama',
    categories: ['Paints'],
  ),
];

// Approved Quotations
List<ApprovedQuotation> mockApprovedQuotations = [
  ApprovedQuotation(
    quotationId: '1499',
    customerName: 'Mr. Suresh Jayathunga',
    projectTitle: 'Villa LVT Flooring',
    approvedDate: DateTime(2025, 7, 2),
    totalAmount: 206825,
    items: [
      QuotationItem(
        id: 'QI001',
        name: 'LVT Flooring 2mm',
        category: 'Flooring',
        quantity: 385,
        unit: 'sqft',
        estimatedPrice: 365,
      ),
      QuotationItem(
        id: 'QI002',
        name: 'Skirting 3 inch',
        category: 'Flooring',
        quantity: 120,
        unit: 'linear ft',
        estimatedPrice: 410,
      ),
      QuotationItem(
        id: 'QI003',
        name: 'Floor Adhesive',
        category: 'Adhesive',
        quantity: 50,
        unit: 'kg',
        estimatedPrice: 850,
      ),
      QuotationItem(
        id: 'QI004',
        name: 'Transport',
        category: 'Service',
        quantity: 1,
        unit: 'trip',
        estimatedPrice: 6850,
        isOrdered: true,
      ),
    ],
  ),
  ApprovedQuotation(
    quotationId: '1496',
    customerName: 'Mrs. Kumudu Perera',
    projectTitle: 'Kitchen Renovation',
    approvedDate: DateTime(2025, 7, 1),
    totalAmount: 450000,
    items: [
      QuotationItem(
        id: 'QI005',
        name: 'Kitchen Tiles',
        category: 'Tiles',
        quantity: 200,
        unit: 'sqft',
        estimatedPrice: 1200,
      ),
      QuotationItem(
        id: 'QI006',
        name: 'Cement',
        category: 'Cement',
        quantity: 30,
        unit: 'bags',
        estimatedPrice: 2200,
      ),
      QuotationItem(
        id: 'QI007',
        name: 'Sand',
        category: 'Sand',
        quantity: 2,
        unit: 'cubes',
        estimatedPrice: 15000,
      ),
      QuotationItem(
        id: 'QI008',
        name: 'Grout',
        category: 'Grout',
        quantity: 20,
        unit: 'kg',
        estimatedPrice: 450,
      ),
    ],
  ),
  ApprovedQuotation(
    quotationId: '1500',
    customerName: 'ABC Company Ltd',
    projectTitle: 'Office Flooring',
    approvedDate: DateTime(2025, 7, 5),
    totalAmount: 680000,
    items: [
      QuotationItem(
        id: 'QI009',
        name: 'Carpet Tiles',
        category: 'Flooring',
        quantity: 500,
        unit: 'sqft',
        estimatedPrice: 850,
      ),
      QuotationItem(
        id: 'QI010',
        name: 'Underlay',
        category: 'Flooring',
        quantity: 500,
        unit: 'sqft',
        estimatedPrice: 150,
      ),
      QuotationItem(
        id: 'QI011',
        name: 'Installation Materials',
        category: 'Materials',
        quantity: 1,
        unit: 'set',
        estimatedPrice: 25000,
      ),
    ],
  ),
];

// Existing Purchase Orders
List<PurchaseOrder> mockPurchaseOrders = [
  PurchaseOrder(
    poId: 'PO-001',
    quotationId: '1499',
    customerName: 'Mr. Suresh Jayathunga',
    supplier: mockSuppliers[2],
    orderDate: DateTime(2025, 7, 3),
    expectedDelivery: DateTime(2025, 7, 10),
    status: 'Delivered',
    items: [
      POItem(
        itemName: 'LVT Flooring 2mm',
        quantity: 400,
        unit: 'sqft',
        unitPrice: 320,
      ),
    ],
  ),
  PurchaseOrder(
    poId: 'PO-002',
    quotationId: '1496',
    customerName: 'Mrs. Kumudu Perera',
    supplier: mockSuppliers[2],
    orderDate: DateTime(2025, 7, 2),
    expectedDelivery: DateTime(2025, 7, 8),
    status: 'Ordered',
    items: [
      POItem(
        itemName: 'Kitchen Tiles',
        quantity: 220,
        unit: 'sqft',
        unitPrice: 1100,
      ),
    ],
  ),
  PurchaseOrder(
    poId: 'PO-003',
    quotationId: '1496',
    customerName: 'Mrs. Kumudu Perera',
    supplier: mockSuppliers[1],
    orderDate: DateTime(2025, 7, 2),
    status: 'Paid',
    items: [
      POItem(itemName: 'Cement', quantity: 35, unit: 'bags', unitPrice: 2100),
      POItem(itemName: 'Sand', quantity: 2, unit: 'cubes', unitPrice: 14500),
    ],
  ),
];
