import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/job_cost_section.dart';
import '../screens/quotation_Invoice/quotation_list_screen.dart';
import '../screens/purchase_order_screen.dart';

/// Application route names
class AppRoutes {
  static const String home = '/';
  static const String quotationInvoice = '/quotation-invoice';
  static const String purchaseOrder = '/purchase-order';
  static const String jobCost = '/job-cost';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
}

/// Application router configuration
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const _HomePlaceholder(),
    ),
    GoRoute(
      path: AppRoutes.quotationInvoice,
      builder: (context, state) => const QuotationListScreen(),
    ),
    GoRoute(
      path: AppRoutes.purchaseOrder,
      builder: (context, state) => const PurchaseOrderScreen(),
    ),
    GoRoute(
      path: AppRoutes.jobCost,
      builder: (context, state) => const JobCostScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const _NotificationsPlaceholder(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const _SettingsPlaceholder(),
    ),
  ],
);

/// Placeholder widgets for routes that haven't been implemented yet
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 80, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Welcome to TileWork Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Select a menu item from the sidebar to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _NotificationsPlaceholder extends StatelessWidget {
  const _NotificationsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications, size: 80, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Notifications',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'No new notifications',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Application settings will be available here',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
