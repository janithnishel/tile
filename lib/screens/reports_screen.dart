// lib/screens/reports/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:tilework/widget/reports/material_sales_report/material_sales_report_tab.dart';
import 'package:tilework/widget/reports/project_report/project_report_tab.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReportTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Tab 1: Material Sales Reports
          MaterialSalesReportTab(),
          
          // Tab 2: Project Reports
          ProjectReportTab(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.analytics, size: 22),
          ),
          const SizedBox(width: 12),
          const Text('Reports'),
        ],
      ),
      backgroundColor: ReportTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.file_download_outlined),
          onPressed: _exportReport,
          tooltip: 'Export Report',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => setState(() {}),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: ReportTheme.primaryColor,
            unselectedLabelColor: Colors.white,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Material Sales'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Projects'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportReport() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ExportOptionsSheet(),
    );
  }
}

class _ExportOptionsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.file_download, color: ReportTheme.primaryColor),
              const SizedBox(width: 12),
              Text('Export Report', style: ReportTheme.headingMedium),
            ],
          ),
          const SizedBox(height: 24),
          _ExportOption(
            icon: Icons.picture_as_pdf,
            title: 'Export as PDF',
            subtitle: 'Generate a printable PDF report',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              // Implement PDF export
            },
          ),
          const SizedBox(height: 12),
          _ExportOption(
            icon: Icons.table_chart,
            title: 'Export as Excel',
            subtitle: 'Download data as spreadsheet',
            color: Colors.green,
            onTap: () {
              Navigator.pop(context);
              // Implement Excel export
            },
          ),
          const SizedBox(height: 12),
          _ExportOption(
            icon: Icons.print,
            title: 'Print Report',
            subtitle: 'Send directly to printer',
            color: ReportTheme.primaryColor,
            onTap: () {
              Navigator.pop(context);
              // Implement print
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ReportTheme.headingSmall),
                    const SizedBox(height: 2),
                    Text(subtitle, style: ReportTheme.caption),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}