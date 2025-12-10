import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/super_admin/dashboard/dashboard_cubit.dart';
import 'package:tilework/cubits/super_admin/dashboard/dashboard_state.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/theme/theme.dart';
import '../../widget/super_admin/stat_card.dart';
import '../../widget/super_admin/dialogs/company_register_dialog.dart';
import '../super_admin/company_management_screen.dart';
import '../../routes/company_routes.dart';

class DashboardContent extends StatefulWidget {
  final VoidCallback? onNavigateToCompanyManagement;

  const DashboardContent({
    Key? key,
    this.onNavigateToCompanyManagement,
  }) : super(key: key);

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when widget initializes
    final token = _getToken();
    if (token != null) {
      context.read<DashboardCubit>().loadDashboardData(token: token);
    }
  }

  String? _getToken() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      return authState.token;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════
              // 👋 WELCOME HEADER
              // ═══════════════════════════════════════
              _buildWelcomeHeader(state),

              const SizedBox(height: 32),

              // ═══════════════════════════════════════
              // 📊 BEAUTIFUL STAT CARDS
              // ═══════════════════════════════════════
              _buildStatsCards(state),

              const SizedBox(height: 32),

              // ═══════════════════════════════════════
              // 📈 ACTIVITY & ACTIONS
              // ═══════════════════════════════════════
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildRecentActivity(state)),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: _buildQuickActions()),
                ],
              ),

              const SizedBox(height: 32),

              // ═══════════════════════════════════════
              // 🏢 RECENT COMPANIES
              // ═══════════════════════════════════════
              _buildRecentCompanies(state),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════
  // 👋 WELCOME HEADER
  // ═══════════════════════════════════════
  Widget _buildWelcomeHeader(DashboardState state) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.35),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: 50,
            bottom: -80,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Content
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Super Admin Panel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome back, Admin! 👋',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage companies and categories from here.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildWelcomeStat(
                          state.totalCompanies.toString(),
                          'Companies',
                          Icons.business_rounded,
                        ),
                        const SizedBox(width: 32),
                        _buildWelcomeStat(
                          state.activeCompanies.toString(),
                          'Active',
                          Icons.check_circle_rounded,
                        ),
                        const SizedBox(width: 32),
                        _buildWelcomeStat(
                          state.totalCategories.toString(),
                          'Categories',
                          Icons.category_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 80,
                  color: Colors.white24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStat(String value, String label, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // 📊 STAT CARDS
  // ═══════════════════════════════════════
  Widget _buildStatsCards(DashboardState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final useWrap = maxWidth < 900;

        if (useWrap) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: (maxWidth - 16) / 2,
                child: StatCard(
                  title: 'Total Companies',
                  value: state.totalCompanies.toString(),
                  icon: Icons.business_rounded,
                  color: const Color(0xFF3B82F6),
                  trend: '+3',
                  isPositiveTrend: true,
                  subtitle: 'This month',
                  onTap: () {},
                ),
              ),
              SizedBox(
                width: (maxWidth - 16) / 2,
                child: StatCard(
                  title: 'Active Companies',
                  value: state.activeCompanies.toString(),
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                  subtitle: '${((state.activeCompanies / (state.totalCompanies > 0 ? state.totalCompanies : 1)) * 100).toStringAsFixed(0)}% of total',
                  onTap: () {},
                ),
              ),
              SizedBox(
                width: (maxWidth - 16) / 2,
                child: StatCard(
                  title: 'Inactive Companies',
                  value: state.inactiveCompanies.toString(),
                  icon: Icons.pause_circle_rounded,
                  color: const Color(0xFFF59E0B),
                  subtitle: '${((state.inactiveCompanies / (state.totalCompanies > 0 ? state.totalCompanies : 1)) * 100).toStringAsFixed(0)}% of total',
                  onTap: () {},
                ),
              ),
              SizedBox(
                width: (maxWidth - 16) / 2,
                child: StatCard(
                  title: 'Total Categories',
                  value: state.totalCategories.toString(),
                  icon: Icons.category_rounded,
                  color: const Color(0xFF8B5CF6),
                  trend: '+5',
                  isPositiveTrend: true,
                  subtitle: 'Across all companies',
                  onTap: () {},
                ),
              ),
            ],
          );
        } else {
          return SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Companies',
                    value: state.totalCompanies.toString(),
                    icon: Icons.business_rounded,
                    color: const Color(0xFF3B82F6),
                    trend: '+3',
                    isPositiveTrend: true,
                    subtitle: 'This month',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: StatCard(
                    title: 'Active Companies',
                    value: state.activeCompanies.toString(),
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF10B981),
                    subtitle: '${((state.activeCompanies / (state.totalCompanies > 0 ? state.totalCompanies : 1)) * 100).toStringAsFixed(0)}% of total',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: StatCard(
                    title: 'Inactive Companies',
                    value: state.inactiveCompanies.toString(),
                    icon: Icons.pause_circle_rounded,
                    color: const Color(0xFFF59E0B),
                    subtitle: '${((state.inactiveCompanies / (state.totalCompanies > 0 ? state.totalCompanies : 1)) * 100).toStringAsFixed(0)}% of total',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: StatCard(
                    title: 'Total Categories',
                    value: state.totalCategories.toString(),
                    icon: Icons.category_rounded,
                    color: const Color(0xFF8B5CF6),
                    trend: '+5',
                    isPositiveTrend: true,
                    subtitle: 'Across all companies',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // ═══════════════════════════════════════
  // 📋 RECENT ACTIVITY
  // ═══════════════════════════════════════
  Widget _buildRecentActivity(DashboardState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF3B82F6),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Latest actions in the system',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (state.recentActivity.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No recent activity',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...state.recentActivity.take(4).map((activity) => Column(
              children: [
                _buildActivityItem(
                  icon: _getActivityIcon(activity['action'] ?? ''),
                  title: _getActivityTitle(activity['action'] ?? ''),
                  subtitle: activity['description'] ?? '',
                  time: _getTimeAgo(activity['createdAt']),
                  color: _getActivityColor(activity['action'] ?? ''),
                ),
                if (state.recentActivity.last != activity) _buildDivider(),
              ],
            )),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: Colors.grey.shade200, height: 1),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String action) {
    switch (action) {
      case 'CREATE_COMPANY':
        return Icons.add_business_rounded;
      case 'UPDATE_COMPANY':
        return Icons.edit_rounded;
      case 'DELETE_COMPANY':
        return Icons.delete_rounded;
      case 'CREATE_CATEGORY':
        return Icons.category_rounded;
      case 'UPDATE_CATEGORY':
        return Icons.edit_rounded;
      case 'DELETE_CATEGORY':
        return Icons.delete_outline_rounded;
      default:
        return Icons.info_outline;
    }
  }

  String _getActivityTitle(String action) {
    switch (action) {
      case 'CREATE_COMPANY':
        return 'New company registered';
      case 'UPDATE_COMPANY':
        return 'Company updated';
      case 'DELETE_COMPANY':
        return 'Company removed';
      case 'CREATE_CATEGORY':
        return 'Category added';
      case 'UPDATE_CATEGORY':
        return 'Category updated';
      case 'DELETE_CATEGORY':
        return 'Category deleted';
      default:
        return 'Activity';
    }
  }

  Color _getActivityColor(String action) {
    switch (action) {
      case 'CREATE_COMPANY':
        return const Color(0xFF10B981); // Green
      case 'UPDATE_COMPANY':
        return const Color(0xFF3B82F6); // Blue
      case 'DELETE_COMPANY':
        return const Color(0xFFEF4444); // Red
      case 'CREATE_CATEGORY':
        return const Color(0xFF8B5CF6); // Purple
      case 'UPDATE_CATEGORY':
        return const Color(0xFFF59E0B); // Orange
      case 'DELETE_CATEGORY':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _getTimeAgo(String? createdAt) {
    if (createdAt == null) return 'Recently';
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  // ═══════════════════════════════════════
  // ⚡ QUICK ACTIONS
  // ═══════════════════════════════════════
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: Color(0xFFF59E0B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildQuickActionButton(
            icon: Icons.add_business_rounded,
            label: 'Register Company',
            color: const Color(0xFF3B82F6),
            onTap: _registerCompany,
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.business_rounded,
            label: 'Manage Companies',
            color: const Color(0xFF10B981),
            onTap: _manageCompanies,
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.logout_rounded,
            label: 'Logout',
            color: const Color(0xFFEF4444),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // 🎯 QUICK ACTION HANDLERS
  // ═══════════════════════════════════════

  // Register Company - Opens registration dialog
  Future<void> _registerCompany() async {
    try {
      // Import the dialog
      final dialogResult = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const CompanyRegisterDialog(),
      );

      if (dialogResult != null && mounted) {
        // Use AuthCubit to register the company
        final authCubit = context.read<AuthCubit>();
        final token = _getToken();

        await authCubit.registerCompany(
          ownerName: dialogResult['ownerName'],
          ownerEmail: dialogResult['ownerEmail'],
          password: dialogResult['password'],
          ownerPhone: dialogResult['ownerPhone'],
          companyName: dialogResult['companyName'],
          companyAddress: dialogResult['companyAddress'],
          companyPhone: dialogResult['companyPhone'],
        );

        // Refresh dashboard data to show updated counts
        if (token != null) {
          context.read<DashboardCubit>().refreshData(token: token);
        }

        _showSuccessSnackBar('Company registered successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Registration failed: ${e.toString()}');
    }
  }

  // Manage Companies - Switch to company management tab
  void _manageCompanies() {
    // Use the callback to navigate to company management
    widget.onNavigateToCompanyManagement?.call();
  }

  // Logout - Perform logout without confirmation (quick action)
  Future<void> _logout() async {
    try {
      // Perform logout directly using AuthCubit
      context.read<AuthCubit>().logout();

      // Show success message
      _showSuccessSnackBar('Logged out successfully!');
    } catch (e) {
      _showErrorSnackBar('Logout failed: ${e.toString()}');
    }
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: color.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // 🏢 RECENT COMPANIES
  // ═══════════════════════════════════════
  Widget _buildRecentCompanies(DashboardState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.business_center_rounded,
                    color: Color(0xFF10B981),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recently Added Companies',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Latest registered companies',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (state.recentCompanies.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No recent companies',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              itemCount: state.recentCompanies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final company = state.recentCompanies[index];
                return _buildCompanyItem(company);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCompanyItem(Map<String, dynamic> company) {
    final isActive = company['isActive'] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isActive
                    ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)]
                    : [Colors.grey.shade400, Colors.grey.shade500],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: (isActive ? const Color(0xFF3B82F6) : Colors.grey)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                (company['companyName'] as String? ?? 'C')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company['companyName'] as String? ?? 'Unknown Company',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      company['name'] as String? ?? 'Unknown Owner',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _getTimeAgo(company['createdAt']),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // ✅ SUCCESS & ❌ ERROR SNACKBARS
  // ═══════════════════════════════════════
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
