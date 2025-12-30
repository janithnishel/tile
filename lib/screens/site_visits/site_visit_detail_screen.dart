// Site Visit Detail Screen
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/site_visits/site_visit_model.dart';
import '../../providers/site_visit_provider.dart';
import '../../utils/site_visits/constants.dart';
import '../../widget/site_visits/status_badge.dart';
import '../../services/site_visits/print_service.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import 'invoice_preview_screen.dart';
import 'create_site_visit_screen.dart';

class SiteVisitDetailScreen extends StatefulWidget {
  final SiteVisitModel visit;

  const SiteVisitDetailScreen({super.key, required this.visit});

  @override
  State<SiteVisitDetailScreen> createState() => _SiteVisitDetailScreenState();
}

class _SiteVisitDetailScreenState extends State<SiteVisitDetailScreen> {
  String? _authToken;

  @override
  void initState() {
    super.initState();
    // Set auth token for API calls - safe way to access context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthAuthenticated) {
          _authToken = authState.token;
          if (mounted) {
            context.read<SiteVisitProvider>().setAuthToken(_authToken);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _navigateToEdit(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () => _showDeleteConfirmation(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.visit.id,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.visit.customerName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(status: widget.visit.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Title Card
                  if (widget.visit.projectTitle.isNotEmpty)
                    _buildProjectCard(),

                  const SizedBox(height: 16),

                  // Contact & Location
                  _buildInfoCard(context, dateFormat),

                  const SizedBox(height: 16),

                  // Site Specifications
                  _buildSpecificationsCard(),

                  const SizedBox(height: 16),

                  // Inspection Summary
                  _buildInspectionCard(),

                  const SizedBox(height: 16),

                  // Charge Summary
                  _buildChargeCard(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildProjectCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryPurpleLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.folder, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.visit.projectTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, DateFormat dateFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact & Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, 'Phone', widget.visit.contactNo, onTap: () {
              // Launch phone
            }),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'Location', widget.visit.location),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, 'Date', dateFormat.format(widget.visit.date)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.business, 'Site Type', widget.visit.siteType),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryPurpleLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primaryPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Site Specifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildSpecItem('Color Code', widget.visit.colorCode)),
                Expanded(child: _buildSpecItem('Thickness', widget.visit.thickness)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTagSection('Floor Condition', widget.visit.floorCondition,
                AppColors.successGreenLight, AppColors.successGreen),
            const SizedBox(height: 12),
            _buildTagSection('Target Areas', widget.visit.targetArea,
                AppColors.infoBlueLight, AppColors.infoBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'N/A' : value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTagSection(String title, List<String> items, Color bgColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: textColor.withOpacity(0.3)),
            ),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildInspectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inspection Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInspectionItem('Skirting', widget.visit.inspection.skirting),
            _buildInspectionItem('Floor Preparation', widget.visit.inspection.floorPreparation),
            _buildInspectionItem('Ground Setting', widget.visit.inspection.groundSetting),
            _buildInspectionItem('Door Clearance', widget.visit.inspection.door),
            _buildInspectionItem('Window', widget.visit.inspection.window),
            _buildInspectionItem('Surface Level', widget.visit.inspection.evenUneven),
            _buildInspectionItem('Overall Condition', widget.visit.inspection.areaCondition, isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionItem(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Site Visit Charge',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'LKR ${NumberFormat('#,###.00').format(widget.visit.charge)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.attach_money,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status-based action buttons
            if (widget.visit.status == SiteVisitStatus.pending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _markAsInvoiced(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.infoBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.receipt, size: 18),
                      label: const Text('Mark Invoiced', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _convertToQuotation(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangeAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.sync, size: 18),
                      label: const Text('Convert', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ] else if (widget.visit.status == SiteVisitStatus.invoiced) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _markAsPaid(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.payment, size: 18),
                      label: const Text('Mark Paid', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _convertToQuotation(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangeAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.sync, size: 18),
                      label: const Text('Convert', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ] else if (widget.visit.status == SiteVisitStatus.paid) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _previewInvoice(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.infoBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Preview', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadInvoice(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _convertToQuotation(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('Convert to Quotation'),
                ),
              ),
            ] else ...[
              // Converted status - show limited options
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _previewInvoice(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.infoBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Preview', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _printInvoice(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('Print', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSiteVisitScreen(
          editVisit: widget.visit,
          onSave: (updatedVisit) => Provider.of<SiteVisitProvider>(context, listen: false).updateSiteVisit(updatedVisit),
        ),
      ),
    );
  }

  void _previewInvoice(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoicePreviewScreen(visit: widget.visit),
      ),
    );
  }

  void _printInvoice(BuildContext context) async {
    await PrintService.printInvoice(widget.visit);
  }

  void _markAsInvoiced(BuildContext context) async {
    final provider = Provider.of<SiteVisitProvider>(context, listen: false);
    final success = await provider.markAsInvoiced(widget.visit.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Site visit marked as invoiced'),
          backgroundColor: AppColors.infoBlue,
        ),
      );
      // Refresh the visit data
      Navigator.pop(context); // Go back and refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to update status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _markAsPaid(BuildContext context) async {
    final provider = Provider.of<SiteVisitProvider>(context, listen: false);
    final success = await provider.markAsPaid(widget.visit.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Site visit marked as paid'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      // Refresh the visit data
      Navigator.pop(context); // Go back and refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to update status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _downloadInvoice(BuildContext context) {
    // TODO: Implement PDF generation and download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF download feature coming soon!'),
        backgroundColor: AppColors.infoBlue,
      ),
    );
  }

  void _convertToQuotation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convert to Quotation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to convert this site visit to a quotation?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer: ${widget.visit.customerName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Phone: ${widget.visit.contactNo}'),
                  Text('Location: ${widget.visit.location}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<SiteVisitProvider>(context, listen: false)
                  .convertToQuotation(widget.visit.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully converted to quotation!'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Convert'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Delete Site Visit'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to permanently delete this site visit?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${widget.visit.id}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Customer: ${widget.visit.customerName}'),
                  Text('Project: ${widget.visit.projectTitle}'),
                  Text('Charge: LKR ${NumberFormat('#,###.00').format(widget.visit.charge)}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              final provider = Provider.of<SiteVisitProvider>(context, listen: false);
              final success = await provider.deleteSiteVisit(widget.visit.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Site visit deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context); // Go back to list
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'Failed to delete site visit'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
