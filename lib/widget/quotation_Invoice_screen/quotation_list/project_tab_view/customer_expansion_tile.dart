import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/cubits/quotation/quotation_cubit.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';
import 'document_card.dart';


class CustomerExpansionTile extends StatelessWidget {
  final String customerName;
  final List<QuotationDocument> documents;
  final Map<String, dynamic> summary;
  final Function(QuotationDocument, QuotationCubit) onDocumentTap;
  final QuotationCubit cubit;

  const CustomerExpansionTile({
    Key? key,
    required this.customerName,
    required this.documents,
    required this.summary,
    required this.onDocumentTap,
    required this.cubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: _buildLeadingAvatar(),
        title: Text(
          customerName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: _buildSubtitle(),
        children: documents
            .map((doc) => DocumentCard(
                  document: doc,
                  onTap: () => onDocumentTap(doc, cubit),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildLeadingAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.purple.shade100,
      child: Text(
        customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.purple.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          // Quotation Count Badge
          if (summary['quotations'] > 0) ...[
            _buildCountBadge(
              '${summary['quotations']} Quo',
              Colors.orange.shade100,
              Colors.orange.shade800,
            ),
            const SizedBox(width: 6),
          ],
          // Invoice Count Badge
          if (summary['invoices'] > 0)
            _buildCountBadge(
              '${summary['invoices']} Inv',
              Colors.blue.shade100,
              Colors.blue.shade800,
            ),
          const Spacer(),
          // Total Due Amount
          if (summary['totalDue'] > 0)
            Text(
              'Due: Rs ${NumberFormat('#,##0').format(summary['totalDue'])}',
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

  Widget _buildCountBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
