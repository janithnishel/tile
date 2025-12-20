// lib/widget/quotation_Invoice_screen/quotation_list/material_sale_tab_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/material_sale/material_sale_cubit.dart';
import 'package:tilework/cubits/material_sale/material_sale_state.dart';
import 'package:tilework/models/quotation_Invoice_screen/material_sale/material_sale_document.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_invoice_list/material_sales_tab_view/material_sale_list_tile.dart';

class MaterialSaleTabView extends StatefulWidget {
  final Function(MaterialSaleCubit) onCreateNew;
  final Function(MaterialSaleDocument, MaterialSaleCubit) onDocumentTap;

  const MaterialSaleTabView({
    Key? key,
    required this.onCreateNew,
    required this.onDocumentTap,
  }) : super(key: key);

  @override
  State<MaterialSaleTabView> createState() => _MaterialSaleTabViewState();
}

class _MaterialSaleTabViewState extends State<MaterialSaleTabView> {
  @override
  void initState() {
    super.initState();
    // Load material sales when the tab is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialSaleCubit>().loadMaterialSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MaterialSaleCubit, MaterialSaleState>(
      listener: (context, state) {
        // Listen for errors and show snackbar
        if (state.errorMessage != null && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final filteredDocs = _getFilteredDocuments(state.materialSales.cast<MaterialSaleDocument>());
        final groupedDocs = _groupByCustomer(filteredDocs);
        final customerNames = groupedDocs.keys.toList()..sort();

        return Container(
          color: Colors.grey.shade50,
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.errorMessage != null
                  ? _buildErrorState(state.errorMessage!)
                  : customerNames.isEmpty
                      ? _buildEmptyState(context.read<MaterialSaleCubit>())
                      : _buildDocumentList(customerNames, groupedDocs, context.read<MaterialSaleCubit>()),
        );
      },
    );
  }

  List<MaterialSaleDocument> _getFilteredDocuments(List<MaterialSaleDocument> documents) {
    return documents.where((doc) {
      // Add filtering logic here if needed
      return true;
    }).toList();
  }

  Map<String, List<MaterialSaleDocument>> _groupByCustomer(List<MaterialSaleDocument> documents) {
    final Map<String, List<MaterialSaleDocument>> grouped = {};

    for (var doc in documents) {
      final customerKey = doc.customerName.isNotEmpty ? doc.customerName : 'Unassigned Customer';
      grouped.putIfAbsent(customerKey, () => []).add(doc);
    }

    grouped.forEach((customer, docs) {
      docs.sort((a, b) => b.saleDate.compareTo(a.saleDate));
    });

    return grouped;
  }

  Map<String, dynamic> _getCustomerSummary(List<MaterialSaleDocument> docs) {
    int sales = 0;
    double totalAmount = 0;
    double totalDue = 0;

    for (var doc in docs) {
      sales++;
      totalAmount += doc.totalAmount;
      totalDue += doc.amountDue;
    }

    return {
      'sales': sales,
      'totalAmount': totalAmount,
      'totalDue': totalDue,
    };
  }

  Widget _buildDocumentList(
    List<String> customerNames,
    Map<String, List<MaterialSaleDocument>> groupedDocs,
    MaterialSaleCubit cubit,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customerNames.length,
      itemBuilder: (context, index) {
        final customerName = customerNames[index];
        final customerDocs = groupedDocs[customerName]!;
        final summary = _getCustomerSummary(customerDocs);

        return _buildCustomerExpansionTile(customerName, customerDocs, summary, cubit);
      },
    );
  }

  Widget _buildCustomerExpansionTile(
    String customerName,
    List<MaterialSaleDocument> documents,
    Map<String, dynamic> summary,
    MaterialSaleCubit cubit,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Text(
            customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customerName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: _buildCustomerSubtitle(summary),
        children: documents
            .map((doc) => MaterialSaleListTile(
                  sale: doc,
                  onTap: () => widget.onDocumentTap(doc, cubit),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCustomerSubtitle(Map<String, dynamic> summary) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${summary['sales']} Sale${summary['sales'] > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          if (summary['totalDue'] > 0)
            Text(
              'Due: Rs ${summary['totalDue'].toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Failed to load material sales',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.read<MaterialSaleCubit>().loadMaterialSales(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(MaterialSaleCubit cubit) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No material sales yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first material sale',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => widget.onCreateNew(cubit),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Create New Sale'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
