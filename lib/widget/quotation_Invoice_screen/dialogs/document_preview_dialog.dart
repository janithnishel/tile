import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/document_enums.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/quotation_document.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_list/project_tab_view/info_row.dart';
import 'package:tilework/widget/quotation_Invoice_screen/quotation_list/project_tab_view/total_row.dart';

class DocumentPreviewDialog extends StatelessWidget {
  final QuotationDocument document;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String projectTitle;

  const DocumentPreviewDialog({
    Key? key,
    required this.document,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.projectTitle,
  }) : super(key: key);

  String get _title =>
      document.type == DocumentType.quotation ? 'QUOTATION' : 'INVOICE';

  Color get _statusColor => document.type == DocumentType.quotation
      ? Colors.blue.shade700
      : Colors.red.shade700;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('$_title Preview'),
      content: SingleChildScrollView(
        child: _buildPreviewContent(),
      ),
    );
  }

  Widget _buildPreviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const Divider(height: 32, thickness: 2),
        _buildBillToSection(),
        const SizedBox(height: 32),
        _buildItemsTable(),
        const SizedBox(height: 24),
        _buildTotalSection(),
        const SizedBox(height: 32),
        _buildPaymentInstructions(),
        const SizedBox(height: 32),
        _buildSignatureSection(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IMMENSE HOME PRIVATE LIMITED',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '157/1 OLD KOTTAWA ROAD, MIRIHANA, NUGEGODA',
                style: TextStyle(fontSize: 11),
              ),
              Text('Colombo 81300', style: TextStyle(fontSize: 11)),
              Text(
                'Website-www.immensehome.lk | 077 586 70 80',
                style: TextStyle(fontSize: 11),
              ),
              Text(
                'immensehomeprivatelimited@gmail.com',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _statusColor,
              ),
            ),
            Text(
              'STATUS: ${document.status.name.toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _statusColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBillToSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BILL TO',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(customerName.isEmpty ? 'N/A' : customerName),
            if (projectTitle.isNotEmpty)
              Text(
                'Project: $projectTitle',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            Text(customerPhone.isEmpty ? 'N/A' : customerPhone),
            Text(customerAddress.isEmpty ? 'N/A' : customerAddress),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRowWidget(
              label: '$_title #',
              value: document.displayDocumentNumber,
            ),
            InfoRowWidget(
              label: 'Date',
              value: DateFormat('d MMM yyyy').format(document.invoiceDate),
            ),
            InfoRowWidget(
              label: 'Due Date',
              value: DateFormat('d MMM yyyy').format(document.dueDate),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade400),
      columnWidths: const {
        0: FlexColumnWidth(4.5),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Activity/Item',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child:
                  Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Amount',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        ...document.lineItems.map((item) {
          final description = item.displayName;
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('$description (${item.item.unit})'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item.quantity.toStringAsFixed(1)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Rs ${item.item.sellingPrice.toStringAsFixed(2)}'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Rs ${item.amount.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTotalSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 300,
          child: Column(
            children: [
              TotalRowWidget(label: 'Subtotal', amount: document.subtotal),
              TotalRowWidget(
                  label: 'Total', amount: document.subtotal, isBold: true),
              if (document.type == DocumentType.invoice &&
                  document.paymentHistory.isNotEmpty)
                ...document.paymentHistory.map(
                  (p) => TotalRowWidget(
                    label:
                        'Paid (${p.description}) on ${DateFormat('d MMM yyyy').format(p.date)}',
                    amount: -p.amount,
                    color: Colors.green.shade700,
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: document.status == DocumentStatus.paid
                    ? TotalRowWidget(
                        label: 'Paid in Full',
                        amount: 0.0,
                        isBold: true,
                        fontSize: 18,
                        color: Colors.green.shade700,
                      )
                    : TotalRowWidget(
                        label: document.type == DocumentType.quotation
                            ? 'Estimated Total'
                            : 'Amount Due',
                        amount: document.amountDue,
                        isBold: true,
                        fontSize: 18,
                        color: Colors.red.shade700,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Instruction',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (document.type == DocumentType.quotation ||
            (document.type == DocumentType.invoice &&
                document.status != DocumentStatus.paid))
          const Text(
            '• If you agreed, work commencement will proceed soon after receiving 75% of the quotation amount.',
            style: TextStyle(fontSize: 13),
          ),
        const Text(
          '• It is essential to pay the amount remaining, after the completion of work.',
          style: TextStyle(fontSize: 13),
        ),
        const Text(
          '• Please deposit cash/ fund transfer/ cheque payments to the following account.',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 16),
        const Text(
          'Banking details: Immense home (pvt) Ltd Hatton National Bank, A/C No. 200010008304',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'By signing this document, the customer agrees to the services and conditions described in this document.',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 16),
        const Text('_______________________'),
        Text(customerName.isEmpty
            ? 'Customer Signature'
            : '$customerName (Signature)'),
      ],
    );
  }
}