// lib/widgets/reports/material_sales_report/material_sales_report_tab.dart

import 'package:flutter/material.dart';
import 'package:tilework/widget/reports/material_sales_report/invoice_summary_tab.dart';
import 'package:tilework/widget/reports/material_sales_report/item_wise_profitability_tab.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class MaterialSalesReportTab extends StatefulWidget {
  const MaterialSalesReportTab({Key? key}) : super(key: key);

  @override
  State<MaterialSalesReportTab> createState() => _MaterialSalesReportTabState();
}

class _MaterialSalesReportTabState extends State<MaterialSalesReportTab>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub Tab Bar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _subTabController,
            indicator: BoxDecoration(
              color: ReportTheme.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: Colors.white,
            unselectedLabelColor: ReportTheme.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 18),
                    SizedBox(width: 6),
                    Text('Invoice Summary'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category, size: 18),
                    SizedBox(width: 6),
                    Text('Item-Wise Profit'),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Sub Tab Content
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: const [
              InvoiceSummaryTab(),
              ItemWiseProfitabilityTab(),
            ],
          ),
        ),
      ],
    );
  }
}