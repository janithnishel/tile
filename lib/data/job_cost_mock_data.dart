import 'package:tilework/models/job_cost_screen/invoice_item.dart';
import 'package:tilework/models/job_cost_screen/job_cost_document.dart';
import 'package:tilework/models/job_cost_screen/other_expense.dart';
import 'package:tilework/models/job_cost_screen/po_item_cost.dart';

class MockData {
  static List<JobCostDocument> jobCosts = [
    JobCostDocument(
      invoiceId: '1499',
      customerName: 'Mr. Suresh Jayathunga',
      customerPhone: '+94 76 553 4844',
      projectTitle: 'Villa LVT Flooring',
      invoiceDate: DateTime(2025, 7, 2),
      invoiceItems: [
        InvoiceItem(
          name: 'LVT Flooring 2mm',
          quantity: 385,
          unit: 'sqft',
          sellingPrice: 365,
          costPrice: 320,
        ),
        InvoiceItem(
          name: 'Skirting 3 inch',
          quantity: 120,
          unit: 'linear ft',
          sellingPrice: 410,
          costPrice: 350,
        ),
        InvoiceItem(
          name: 'Floor Adhesive',
          quantity: 50,
          unit: 'kg',
          sellingPrice: 850,
          costPrice: null,
        ),
        InvoiceItem(
          name: 'Transport',
          quantity: 1,
          unit: 'trip',
          sellingPrice: 6850,
          costPrice: 5000,
        ),
      ],
      purchaseOrderItems: [
        POItemCost(
          poId: 'PO-001',
          supplierName: 'Royal Tiles Gallery',
          itemName: 'LVT Flooring 2mm',
          quantity: 400,
          unit: 'sqft',
          unitPrice: 320,
          orderDate: DateTime(2025, 7, 3),
          status: 'Delivered',
        ),
        POItemCost(
          poId: 'PO-004',
          supplierName: 'Royal Tiles Gallery',
          itemName: 'Skirting 3 inch',
          quantity: 130,
          unit: 'linear ft',
          unitPrice: 340,
          orderDate: DateTime(2025, 7, 4),
          status: 'Ordered',
        ),
      ],
      otherExpenses: [
        OtherExpense(
          category: 'Labour',
          description: 'Installation workers (3 days)',
          amount: 15000,
          date: DateTime(2025, 7, 5),
        ),
        OtherExpense(
          category: 'Transport',
          description: 'Material delivery',
          amount: 3500,
          date: DateTime(2025, 7, 3),
        ),
      ],
    ),
    JobCostDocument(
      invoiceId: '1498',
      customerName: 'Mrs. Kumudu Perera',
      customerPhone: '+94 71 123 4567',
      projectTitle: 'Kitchen Renovation',
      invoiceDate: DateTime(2025, 6, 20),
      invoiceItems: [
        InvoiceItem(
          name: 'Kitchen Tiles',
          quantity: 200,
          unit: 'sqft',
          sellingPrice: 1200,
          costPrice: 1050,
        ),
        InvoiceItem(
          name: 'Cement',
          quantity: 30,
          unit: 'bags',
          sellingPrice: 2500,
          costPrice: 2100,
        ),
        InvoiceItem(
          name: 'Grout',
          quantity: 20,
          unit: 'kg',
          sellingPrice: 450,
          costPrice: 380,
        ),
      ],
      purchaseOrderItems: [
        POItemCost(
          poId: 'PO-002',
          supplierName: 'Royal Tiles Gallery',
          itemName: 'Kitchen Tiles',
          quantity: 220,
          unit: 'sqft',
          unitPrice: 1100,
          orderDate: DateTime(2025, 6, 22),
          status: 'Paid',
        ),
        POItemCost(
          poId: 'PO-003',
          supplierName: 'Lanka Cement',
          itemName: 'Cement',
          quantity: 35,
          unit: 'bags',
          unitPrice: 2100,
          orderDate: DateTime(2025, 6, 22),
          status: 'Paid',
        ),
      ],
      otherExpenses: [
        OtherExpense(
          category: 'Labour',
          description: 'Tile work (5 days)',
          amount: 25000,
          date: DateTime(2025, 6, 25),
        ),
      ],
    ),
    JobCostDocument(
      invoiceId: '1497',
      customerName: 'Mr. Nimal Bandara',
      customerPhone: '+94 77 987 6543',
      projectTitle: 'Beach House Flooring',
      invoiceDate: DateTime(2025, 5, 10),
      invoiceItems: [
        InvoiceItem(
          name: 'LVT Flooring 2mm',
          quantity: 100,
          unit: 'sqft',
          sellingPrice: 365,
          costPrice: 320,
        ),
        InvoiceItem(
          name: 'Transport',
          quantity: 1,
          unit: 'trip',
          sellingPrice: 6850,
          costPrice: 5500,
        ),
      ],
      purchaseOrderItems: [
        POItemCost(
          poId: 'PO-005',
          supplierName: 'Royal Tiles Gallery',
          itemName: 'LVT Flooring 2mm',
          quantity: 110,
          unit: 'sqft',
          unitPrice: 315,
          orderDate: DateTime(2025, 5, 12),
          status: 'Paid',
        ),
      ],
      otherExpenses: [],
    ),
  ];

  // Summary Calculations
  static double get totalRevenue =>
      jobCosts.fold<double>(0, (sum, job) => sum + job.totalRevenue);

  static double get totalCost =>
      jobCosts.fold<double>(0, (sum, job) => sum + job.totalCost);

  static double get totalProfit => totalRevenue - totalCost;

  static double get averageMargin => jobCosts.isNotEmpty
      ? jobCosts.fold<double>(0, (sum, job) => sum + job.profitMargin) /
            jobCosts.length
      : 0;
}
