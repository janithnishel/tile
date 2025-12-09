// lib/screens/super_admin/super_admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/routes/company_routes.dart';
import 'package:tilework/screens/super_admin/app_theme.dart';
import 'package:tilework/widget/super_admin/dialogs/confirm_dialog.dart';
import 'dashboard_content.dart';
import 'company_management_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({Key? key}) : super(key: key);

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  bool isExpanded = true;
  int selectedIndex = 0;

  final List<_MenuItem> menuItems = [
    _MenuItem(
      icon: Icons.dashboard_rounded,
      title: 'Dashboard',
    ),
    _MenuItem(
      icon: Icons.business_rounded,
      title: 'Company Management',
    ),
    _MenuItem(
      icon: Icons.logout_rounded,
      title: 'Logout',
      isLogout: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ═══════════════════════════════════════
          // 📌 SIDEBAR
          // ═══════════════════════════════════════
          _buildSidebar(),

          // ═══════════════════════════════════════
          // 📄 MAIN CONTENT
          // ═══════════════════════════════════════
          Expanded(
            child: Container(
              color: AppTheme.background,
              child: Column(
                children: [
                  // App Bar
                  _buildAppBar(),

                  // Content
                  Expanded(
                    child: _getPage(selectedIndex),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 260 : 80,
      decoration: BoxDecoration(
        gradient: AppTheme.sidebarGradient,
      ),
      child: Column(
        children: [
          // Header
          _buildSidebarHeader(),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleMenuTap(index),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: isExpanded ? 16 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: isExpanded
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.7),
                              size: 24,
                            ),
                            if (isExpanded) ...[
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.8),
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // User Info
          if (isExpanded) _buildUserInfo(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          if (isExpanded) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.admin_panel_settings_rounded,
                color: AppTheme.primaryDark,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Super Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          IconButton(
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            icon: Icon(
              isExpanded ? Icons.chevron_left : Icons.chevron_right,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'admin@example.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Icon(
            menuItems[selectedIndex].icon,
            color: AppTheme.primaryAccent,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            menuItems[selectedIndex].title,
            style: AppTheme.heading1,
          ),
          const Spacer(),
          // Notifications
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey.shade600,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Settings
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const DashboardContent();
      case 1:
        return const CompanyManagementScreen();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  void _handleMenuTap(int index) {
    if (menuItems[index].isLogout) {
      _showLogoutConfirmation();
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  }



  Future<void> _showLogoutConfirmation() async {
    final result = await ConfirmDialog.show(
      context: context,
      title: 'Logout Confirmation',
      message: 'Are you sure you want to logout from your account?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      icon: Icons.logout_rounded,
      isDanger: true,
    );

    if (result == true) {
      _performLogout();
    }
  }

  Future<void> _performLogout() async {
    try {
      // Clear authentication state
      context.read<AuthCubit>().logout();

      // Navigate to login screen
      context.go(AppRoutes.login);
    } catch (e) {
      // Show error if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final bool isLogout;

  _MenuItem({
    required this.icon,
    required this.title,
    this.isLogout = false,
  });
}
