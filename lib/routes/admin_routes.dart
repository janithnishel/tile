import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../screens/super_admin/super_admin_dashboard.dart';
import '../screens/super_admin/dashboard_content.dart';
import '../screens/super_admin/company_management_screen.dart';
import '../screens/super_admin/company_setup_screen.dart';
import '../models/super_admin/company_model.dart';

/// Admin route names
class AdminRoutes {
  static const String adminBase = '/super-admin';
  static const String adminDashboard = '/super-admin/dashboard';
  static const String adminCompanyManagement = '/super-admin/company-management';
  static const String adminCompanySetup = '/super-admin/company-setup';
}

/// Admin router configuration for nested routes within super admin
final GoRouter adminRouter = GoRouter(
  initialLocation: AdminRoutes.adminDashboard,
  routes: [
    GoRoute(
      path: AdminRoutes.adminBase,
      builder: (context, state) => const SuperAdminDashboard(),
    ),
    GoRoute(
      path: AdminRoutes.adminDashboard,
      builder: (context, state) => const DashboardContent(),
    ),
    GoRoute(
      path: AdminRoutes.adminCompanyManagement,
      builder: (context, state) => const CompanyManagementScreen(),
    ),
    GoRoute(
      path: AdminRoutes.adminCompanySetup,
      builder: (context, state) {
        // Extract company data from route parameters
        final companyId = state.pathParameters['companyId'];
        final companyName = state.pathParameters['companyName'];
        final ownerName = state.pathParameters['ownerName'];
        final ownerEmail = state.pathParameters['ownerEmail'];

        if (companyId != null && companyName != null && ownerName != null && ownerEmail != null) {
          // Create a sample company model - in real app, fetch from repository
          final company = CompanyModel(
            id: companyId,
            companyName: companyName,
            companyAddress: 'Address not available', // Would be fetched from API
            companyPhone: 'Phone not available',
            ownerName: ownerName,
            ownerEmail: ownerEmail,
            ownerPhone: 'Phone not available',
            isActive: true,
          );

          return CompanySetupScreen(
            company: company,
            onBack: () => context.go(AdminRoutes.adminCompanyManagement),
          );
        }

        // Fallback
        return const CompanyManagementScreen();
      },
    ),
  ],
);

/// Helper class for admin navigation
class AdminNavigation {
  /// Navigate to admin dashboard
  static void goToDashboard(BuildContext context) {
    context.go(AdminRoutes.adminDashboard);
  }

  /// Navigate to company management
  static void goToCompanyManagement(BuildContext context) {
    context.go(AdminRoutes.adminCompanyManagement);
  }

  /// Navigate to company setup with company data
  static void goToCompanySetup(BuildContext context, CompanyModel company) {
    context.go(
      '${AdminRoutes.adminCompanySetup}?companyId=${company.id}&companyName=${Uri.encodeComponent(company.companyName)}&ownerName=${Uri.encodeComponent(company.ownerName)}&ownerEmail=${Uri.encodeComponent(company.ownerEmail)}',
    );
  }

  /// Go back to previous route
  static void goBack(BuildContext context) {
    context.pop();
  }
}
