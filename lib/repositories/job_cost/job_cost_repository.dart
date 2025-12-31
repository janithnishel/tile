import '../../models/job_cost_screen/job_cost_document.dart';
import '../../models/job_cost_screen/invoice_item.dart';
import '../../models/job_cost_screen/po_item_cost.dart';
import '../../services/job_cost/api_service.dart';
import '../../data/job_cost_mock_data.dart';
import '../quotation/quotation_repository.dart';
import '../../services/quotation/quotation_api_service.dart';
import '../../models/quotation_Invoice_screen/project/quotation_document.dart';
import '../purchase_order/purchase_order_repository.dart';
import '../../services/purchase_order/api_service.dart';
import '../../models/purchase_order/purchase_order.dart';

class JobCostRepository {
  final JobCostApiService _apiService;
  final String? _token;

  JobCostRepository(this._apiService, [this._token]);

  // GET: Fetch all job costs (from approved quotations)
  Future<List<JobCostDocument>> fetchJobCosts({
    Map<String, String>? queryParams,
    String? token,
  }) async {
    try {
      final currentToken = token ?? _token;
      final quotationRepository = QuotationRepository(QuotationApiService(), currentToken);

      // Fetch all quotations
      final quotations = await quotationRepository.fetchQuotations(token: currentToken);

      // Filter for approved quotations only
      final approvedQuotations = quotations.where((q) => q.isApproved).toList();

      print('✅ JobCostRepository: Found ${approvedQuotations.length} approved quotations');

      // Load all purchase orders to link with quotations
      final poRepository = PurchaseOrderRepository(PurchaseOrderApiService(), currentToken);
      final allPOs = await poRepository.fetchPurchaseOrders(token: currentToken);

      // Convert quotations to JobCostDocuments with linked POs
      final jobCosts = approvedQuotations.map((quotation) {
        final linkedPOs = allPOs.where((po) => po.quotationId == quotation.documentNumber).toList();
        return _quotationToJobCost(quotation, linkedPOs);
      }).toList();

      print('✅ JobCostRepository: Converted to ${jobCosts.length} job costs');
      return jobCosts;
    } catch (e) {
      print('💥 JobCostRepository: Failed to fetch approved quotations: $e');
      // Fallback to mock data if API fails
      print('📦 JobCostRepository: Falling back to mock data');
      return MockData.jobCosts;
    }
  }

  // Helper method to convert QuotationDocument to JobCostDocument
  JobCostDocument _quotationToJobCost(QuotationDocument quotation, List<PurchaseOrder> linkedPOs) {
    // Convert line items to invoice items
    final invoiceItems = quotation.lineItems.map((lineItem) {
      return InvoiceItem(
        name: lineItem.displayName,
        quantity: lineItem.quantity,
        unit: lineItem.item.unit,
        sellingPrice: lineItem.item.sellingPrice,
        costPrice: lineItem.item.sellingPrice * 0.8, // Assume 80% cost price
      );
    }).toList();

    // Convert POs to PO item costs
    final poItemCosts = linkedPOs.expand((po) {
      return po.items.map((poItem) {
        return POItemCost(
          poId: po.poId,
          supplierName: po.supplier.name,
          itemName: poItem.itemName,
          quantity: poItem.quantity,
          unit: poItem.unit,
          unitPrice: poItem.unitPrice,
          orderDate: po.orderDate,
          status: po.status,
        );
      });
    }).toList();

    return JobCostDocument(
      id: quotation.id,
      invoiceId: quotation.documentNumber,
      customerName: quotation.customerName,
      customerPhone: quotation.customerPhone,
      projectTitle: quotation.projectTitle,
      invoiceDate: quotation.invoiceDate,
      invoiceItems: invoiceItems,
      purchaseOrderItems: poItemCosts,
      otherExpenses: [], // Will be loaded separately
    );
  }

  // GET: Fetch single job cost
  Future<JobCostDocument> fetchJobCost(String id, {String? token}) async {
    // Return mock data for the job with matching ID
    final job = MockData.jobCosts.firstWhere(
      (job) => job.id == id || job.invoiceId == id,
      orElse: () => throw Exception('Job cost not found'),
    );
    return job;
  }

  // POST: Create job cost
  Future<JobCostDocument> createJobCost(
    JobCostDocument jobCost, {
    String? token,
  }) async {
    try {
      final jsonData = jobCost.toJson();
      final currentToken = token ?? _token;

      final response = await _apiService.createJobCost(jsonData, token: currentToken);

      // Backend should return the created job cost data
      final data = response['data'];
      if (data == null) {
        throw Exception('No data returned from create job cost API');
      }

      final createdJobCost = JobCostDocument.fromJson(data);
      return createdJobCost;
    } catch (e) {
      print('❌ Failed to create job cost: $e');
      throw Exception('Failed to create job cost: $e');
    }
  }

  // PUT: Update job cost
  Future<JobCostDocument> updateJobCost(
    JobCostDocument jobCost, {
    String? token,
  }) async {
    try {
      final currentToken = token ?? _token;
      final response = await _apiService.updateJobCost(
        jobCost.id ?? '',
        jobCost.toJson(),
        token: currentToken,
      );

      // Backend should return the updated job cost data
      final data = response['data'];
      return JobCostDocument.fromJson(data);
    } catch (e) {
      print('💥 Failed to update job cost: $e');
      throw Exception('Failed to update job cost: $e');
    }
  }

  // DELETE: Delete job cost
  Future<void> deleteJobCost(String id, {String? token}) async {
    try {
      final currentToken = token ?? _token;
      await _apiService.deleteJobCost(id, token: currentToken);
    } catch (e) {
      print('💥 Failed to delete job cost: $e');
      throw Exception('Failed to delete job cost: $e');
    }
  }
}
