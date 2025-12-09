import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tilework/screens/super_admin/super_admin_dashboard.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../screens/job_cost_section.dart';
import '../screens/quotation_Invoice/quotation_list_screen.dart';
import '../screens/auth/login _screen.dart';
import '../screens/purchase_order_screen.dart';
import '../screens/company_sidebar_screen.dart';

/// Application route names
class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String superAdmin = '/super-admin';
  static const String quotationInvoice = '/quotation-invoice';
  static const String purchaseOrder = '/purchase-order';
  static const String jobCost = '/job-cost';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
}

/// Application router configuration
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  redirect: (context, state) {
    final authState = context.read<AuthCubit>().state;

    final isLoggedIn = authState is AuthAuthenticated;
    final isLoggingIn = state.matchedLocation == AppRoutes.login;

    // If not logged in and not on login page, redirect to login
    if (!isLoggedIn && !isLoggingIn) {
      return AppRoutes.login;
    }

    // If logged in and on login page, redirect to home
    if (isLoggedIn && isLoggingIn) {
      return AppRoutes.home;
    }

    // No redirect needed
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            // Check user role and navigate accordingly
            final user = authState.user;
            if (user.role == 'super-admin') {
              return const SuperAdminDashboard();
            } else {
              return CompanySidebarScreen();
            }
          } else {
            // User not authenticated, this shouldn't happen due to redirect
            return LoginScreen();
          }
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.superAdmin,
      builder: (context, state) => const SuperAdminDashboard(),
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
