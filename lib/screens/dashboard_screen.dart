// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tilework/models/dashboard/dashboard_models.dart';
import 'package:tilework/routes/company_routes.dart';
import 'package:tilework/widget/dashboard/dashboard_period_selector.dart';
import 'package:tilework/widget/dashboard/material_sales/material_sales_dashboard_tab.dart';
import 'package:tilework/widget/dashboard/projects/projects_dashboard_tab.dart';
import 'package:tilework/widget/reports/report_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dashboard State
  DashboardPeriod _selectedPeriod = DashboardPeriod.last30Days;
  DateTimeRange? _customDateRange;

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
      body: Column(
        children: [
          // Period Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: DashboardPeriodSelector(
              selectedPeriod: _selectedPeriod,
              customDateRange: _customDateRange,
              onPeriodChanged: _onPeriodChanged,
              onCustomDateRangeSelected: _onCustomDateRangeSelected,
            ),
          ),

          // Tab Bar
          _buildTabBar(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Material Sales Tab
                MaterialSalesDashboardTab(
                  selectedPeriod: _selectedPeriod,
                  customDateRange: _customDateRange,
                  onNavigateToReports: _navigateToReports,
                ),

                // Projects Tab
                ProjectsDashboardTab(
                  selectedPeriod: _selectedPeriod,
                  customDateRange: _customDateRange,
                  onNavigateToReports: _navigateToReports,
                ),
              ],
            ),
          ),
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
            child: const Icon(Icons.dashboard, size: 22),
          ),
          const SizedBox(width: 12),
          const Text('Dashboard'),
        ],
      ),
      backgroundColor: ReportTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshDashboard,
          tooltip: 'Refresh Dashboard',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: _showNotifications,
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: ReportTheme.primaryColor,
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
        labelColor: Colors.white,
        unselectedLabelColor: ReportTheme.primaryColor,
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
    );
  }

  void _onPeriodChanged(DashboardPeriod period) {
    setState(() {
      _selectedPeriod = period;
      if (period != DashboardPeriod.custom) {
        _customDateRange = null;
      }
    });
    // Here you would typically refresh data for the new period
    _refreshDashboard();
  }

  void _onCustomDateRangeSelected(DateTimeRange dateRange) {
    setState(() {
      _customDateRange = dateRange;
    });
    // Refresh data with custom date range
    _refreshDashboard();
  }

  void _navigateToReports() {
    // Navigate to reports screen
    // TODO: Add reports route to AppRoutes and navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Reports - Feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _refreshDashboard() {
    // Implement dashboard refresh logic
    // This would typically fetch new data from APIs
    setState(() {
      // Trigger rebuild to refresh data
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dashboard refreshed'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showNotifications() {
    // Show notifications panel
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildNotificationsSheet(),
    );
  }

  Widget _buildNotificationsSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications, color: ReportTheme.primaryColor),
              const SizedBox(width: 12),
              Text(
                'Notifications',
                style: ReportTheme.headingMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sample notifications - replace with actual notifications
          _buildNotificationItem(
            icon: Icons.warning_amber,
            title: 'Project Overdue',
            subtitle: 'Villa Renovation project is 5 days overdue',
            time: '2 hours ago',
            color: ReportTheme.warningColor,
          ),
          const SizedBox(height: 16),

          _buildNotificationItem(
            icon: Icons.payment,
            title: 'Payment Received',
            subtitle: 'Rs. 125,000 received from ABC Company',
            time: '4 hours ago',
            color: ReportTheme.successColor,
          ),
          const SizedBox(height: 16),

          _buildNotificationItem(
            icon: Icons.inventory,
            title: 'Low Stock Alert',
            subtitle: 'Floor tiles inventory below threshold',
            time: '1 day ago',
            color: ReportTheme.errorColor,
          ),

          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('View All Notifications'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ReportTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: ReportTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: ReportTheme.textHint,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
