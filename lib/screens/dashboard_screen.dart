// // lib/screens/dashboard_screen.dart

// import 'package:flutter/material.dart';
// import 'package:tilework/models/dashboard/dashboard_models.dart';
// import 'package:tilework/widget/dashboard/dashboard_period_selector.dart';
// import 'package:tilework/widget/dashboard/material_sales/material_sales_dashboard_tab.dart';
// import 'package:tilework/widget/dashboard/projects/projects_dashboard_tab.dart';
// import 'package:tilework/widget/reports/report_theme.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({Key? key}) : super(key: key);

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   // Dashboard State
//   DashboardPeriod _selectedPeriod = DashboardPeriod.last30Days;
//   DateTimeRange? _customDateRange;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ReportTheme.backgroundColor,
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           // Period Selector
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: DashboardPeriodSelector(
//               selectedPeriod: _selectedPeriod,
//               customDateRange: _customDateRange,
//               onPeriodChanged: _onPeriodChanged,
//               onCustomDateRangeSelected: _onCustomDateRangeSelected,
//             ),
//           ),

//           // Tab Bar
//           _buildTabBar(),

//           // Tab Content
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 // Material Sales Tab
//                 MaterialSalesDashboardTab(
//                   selectedPeriod: _selectedPeriod,
//                   customDateRange: _customDateRange,
//                   onNavigateToReports: _navigateToReports,
//                 ),

//                 // Projects Tab
//                 ProjectsDashboardTab(
//                   selectedPeriod: _selectedPeriod,
//                   customDateRange: _customDateRange,
//                   onNavigateToReports: _navigateToReports,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       title: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.dashboard, size: 22),
//           ),
//           const SizedBox(width: 12),
//           const Text('Dashboard'),
//         ],
//       ),
//       backgroundColor: ReportTheme.primaryColor,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.refresh),
//           onPressed: _refreshDashboard,
//           tooltip: 'Refresh Dashboard',
//         ),
//         IconButton(
//           icon: const Icon(Icons.notifications_outlined),
//           onPressed: _showNotifications,
//           tooltip: 'Notifications',
//         ),
//         const SizedBox(width: 8),
//       ],
//     );
//   }

//   Widget _buildTabBar() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: TabBar(
//         controller: _tabController,
//         indicator: BoxDecoration(
//           color: ReportTheme.primaryColor,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         indicatorSize: TabBarIndicatorSize.tab,
//         indicatorPadding: const EdgeInsets.all(4),
//         labelColor: Colors.white,
//         unselectedLabelColor: ReportTheme.primaryColor,
//         labelStyle: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 14,
//         ),
//         unselectedLabelStyle: const TextStyle(
//           fontWeight: FontWeight.w500,
//           fontSize: 14,
//         ),
//         tabs: const [
//           Tab(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.store_outlined, size: 20),
//                 SizedBox(width: 8),
//                 Text('Material Sales'),
//               ],
//             ),
//           ),
//           Tab(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.work_outline, size: 20),
//                 SizedBox(width: 8),
//                 Text('Projects'),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _onPeriodChanged(DashboardPeriod period) {
//     setState(() {
//       _selectedPeriod = period;
//       if (period != DashboardPeriod.custom) {
//         _customDateRange = null;
//       }
//     });
//     // Here you would typically refresh data for the new period
//     _refreshDashboard();
//   }

//   void _onCustomDateRangeSelected(DateTimeRange dateRange) {
//     setState(() {
//       _customDateRange = dateRange;
//     });
//     // Refresh data with custom date range
//     _refreshDashboard();
//   }

//   void _navigateToReports() {
//     // Navigate to reports screen
//     // TODO: Add reports route to AppRoutes and navigation
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Navigate to Reports - Feature coming soon!'),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   void _refreshDashboard() {
//     // Implement dashboard refresh logic
//     // This would typically fetch new data from APIs
//     setState(() {
//       // Trigger rebuild to refresh data
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Dashboard refreshed'),
//         behavior: SnackBarBehavior.floating,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showNotifications() {
//     // Show notifications panel
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => _buildNotificationsSheet(),
//     );
//   }

//   Widget _buildNotificationsSheet() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.notifications, color: ReportTheme.primaryColor),
//               const SizedBox(width: 12),
//               Text(
//                 'Notifications',
//                 style: ReportTheme.headingMedium,
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),

//           // Sample notifications - replace with actual notifications
//           _buildNotificationItem(
//             icon: Icons.warning_amber,
//             title: 'Project Overdue',
//             subtitle: 'Villa Renovation project is 5 days overdue',
//             time: '2 hours ago',
//             color: ReportTheme.warningColor,
//           ),
//           const SizedBox(height: 16),

//           _buildNotificationItem(
//             icon: Icons.payment,
//             title: 'Payment Received',
//             subtitle: 'Rs. 125,000 received from ABC Company',
//             time: '4 hours ago',
//             color: ReportTheme.successColor,
//           ),
//           const SizedBox(height: 16),

//           _buildNotificationItem(
//             icon: Icons.inventory,
//             title: 'Low Stock Alert',
//             subtitle: 'Floor tiles inventory below threshold',
//             time: '1 day ago',
//             color: ReportTheme.errorColor,
//           ),

//           const SizedBox(height: 24),
//           Center(
//             child: TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('View All Notifications'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNotificationItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required String time,
//     required Color color,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: ReportTheme.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   color: ReportTheme.textSecondary,
//                   fontSize: 13,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 time,
//                 style: TextStyle(
//                   color: ReportTheme.textHint,
//                   fontSize: 11,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// lib/screens/dashboard_screen.dart
// lib/screens/dashboard_screen.dart
// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/material_sale/material_sale_cubit.dart';

import 'package:tilework/models/dashboard/dashboard_models.dart';
import 'package:tilework/widget/dashboard/dashboard_period_selector.dart';
import 'package:tilework/widget/dashboard/material_sales/material_sales_dashboard_tab.dart';
import 'package:tilework/widget/dashboard/projects/projects_dashboard_tab.dart';

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

  // Get real user data from authentication
  String get _companyName {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      // Use real company name from user data
      return user.companyName ?? 'ABC Tiles Ltd';
    }
    return 'ABC Tiles Ltd'; // Fallback
  }

  String get _userName {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      // Use real user name from user data
      return user.name;
    }
    return 'John Smith'; // Fallback
  }

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

  bool get mounted => _tabController != null && super.mounted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Custom App Bar
          _buildCustomAppBar(),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  _buildWelcomeHeader(),

                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════
                  // 📊 BEAUTIFUL STAT CARDS
                  // ═══════════════════════════════════════
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Sales',
                          value: 'Rs. 2.5M',
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFF3B82F6),
                          trend: '+12%',
                          isPositiveTrend: true,
                          subtitle: 'This month',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Total Orders',
                          value: '156',
                          icon: Icons.shopping_cart_rounded,
                          color: const Color(0xFF10B981),
                          trend: '+8%',
                          isPositiveTrend: true,
                          subtitle: 'This month',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Active Projects',
                          value: '24',
                          icon: Icons.work_rounded,
                          color: const Color(0xFF8B5CF6),
                          trend: '+3',
                          isPositiveTrend: true,
                          subtitle: 'In progress',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Pending Payments',
                          value: 'Rs. 450K',
                          icon: Icons.pending_actions_rounded,
                          color: const Color(0xFFF59E0B),
                          subtitle: 'From 18 invoices',
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Period Selector
                  DashboardPeriodSelector(
                    selectedPeriod: _selectedPeriod,
                    customDateRange: _customDateRange,
                    onPeriodChanged: _onPeriodChanged,
                    onCustomDateRangeSelected: _onCustomDateRangeSelected,
                  ),

                  const SizedBox(height: 20),

                  // Tab Bar
                  _buildTabBar(),

                  const SizedBox(height: 16),

                  // Tab Content
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        MaterialSalesDashboardTab(
                          selectedPeriod: _selectedPeriod,
                          customDateRange: _customDateRange,
                          onNavigateToReports: _navigateToReports,
                        ),
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
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // 🔝 CUSTOM APP BAR
  // ═══════════════════════════════════════
  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF1E40AF),
            Color(0xFF2563EB),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Company Logo
          _buildCompanyLogo(),
          const SizedBox(width: 14),

          // Company Name & User
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _companyName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Welcome, $_userName',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          _buildAppBarAction(
            icon: Icons.refresh_rounded,
            onTap: _refreshDashboard,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          _buildAppBarAction(
            icon: Icons.notifications_outlined,
            onTap: _showNotifications,
            tooltip: 'Notifications',
            badgeCount: 3,
          ),
          const SizedBox(width: 8),
          _buildAppBarAction(
            icon: Icons.person_outline_rounded,
            onTap: _showProfile,
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyLogo() {
    final List<List<Color>> logoGradients = [
      [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
      [const Color(0xFF10B981), const Color(0xFF059669)],
      [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      [const Color(0xFFEC4899), const Color(0xFFBE185D)],
    ];

    final colorIndex = _companyName.length % logoGradients.length;
    final gradientColors = logoGradients[colorIndex];

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          _companyName.isNotEmpty ? _companyName[0].toUpperCase() : 'C',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    int badgeCount = 0,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // 👋 WELCOME HEADER
  // ═══════════════════════════════════════
  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF1E40AF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Patterns
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -60,
            child: Container(
              width: 120,
              height: 120,
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
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('👋', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            _getGreeting(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to $_companyName',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here\'s your business overview for today.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  size: 60,
                  color: Colors.white24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }



  // ═══════════════════════════════════════
  // 📑 TAB BAR
  // ═══════════════════════════════════════
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.store_rounded, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('Material Sales'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.work_rounded, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('Projects'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // 🔧 METHODS
  // ═══════════════════════════════════════

  void _onPeriodChanged(DashboardPeriod period) {
    if (mounted) {
      setState(() {
        _selectedPeriod = period;
        if (period != DashboardPeriod.custom) {
          _customDateRange = null;
        }
      });
      _refreshDashboard();
    }
  }

  void _onCustomDateRangeSelected(DateTimeRange dateRange) {
    if (mounted) {
      setState(() {
        _customDateRange = dateRange;
      });
      _refreshDashboard();
    }
  }

  void _navigateToReports() {
    _showSnackBar('Navigate to Reports - Coming soon!', const Color(0xFF3B82F6));
  }

  void _refreshDashboard() {
    setState(() {});
    _showSnackBar('Dashboard refreshed', const Color(0xFF10B981));
  }

  void _showSnackBar(String message, Color color) {
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
              child: Icon(
                color == const Color(0xFF10B981)
                    ? Icons.check_circle_rounded
                    : Icons.info_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showProfile() {
    // Navigate to Profile section in sidebar
    // Assuming we're in a sidebar context, we need to find the parent sidebar
    // and navigate to the profile index
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Profile section'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildProfileSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Profile Header
          Row(
            children: [
              _buildCompanyLogo(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _companyName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF10B981),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Options
          _buildProfileOption(
            icon: Icons.person_outline_rounded,
            label: 'Edit Profile',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            onTap: () {},
          ),
          _buildProfileOption(
            icon: Icons.logout_rounded,
            label: 'Logout',
            color: const Color(0xFFEF4444),
            onTap: () {
              Navigator.pop(context);
              // Handle logout
            },
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFF64748B),
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: color == const Color(0xFFEF4444)
                        ? color
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNotificationsSheet(),
    );
  }

  Widget _buildNotificationsSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Mark all read'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Notifications List
          _buildNotificationItem(
            icon: Icons.warning_amber_rounded,
            title: 'Project Overdue',
            subtitle: 'Villa Renovation project is 5 days overdue',
            time: '2 hours ago',
            color: const Color(0xFFF59E0B),
            isUnread: true,
          ),
          const SizedBox(height: 12),

          _buildNotificationItem(
            icon: Icons.payments_rounded,
            title: 'Payment Received',
            subtitle: 'Rs. 125,000 received from ABC Company',
            time: '4 hours ago',
            color: const Color(0xFF10B981),
            isUnread: true,
          ),
          const SizedBox(height: 12),

          _buildNotificationItem(
            icon: Icons.inventory_rounded,
            title: 'Low Stock Alert',
            subtitle: 'Floor tiles inventory below threshold',
            time: '1 day ago',
            color: const Color(0xFFEF4444),
            isUnread: false,
          ),

          const SizedBox(height: 24),

          // View All Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('View All Notifications'),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
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
    bool isUnread = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? color.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? color.withOpacity(0.2) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey.shade500,
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
}

// ═══════════════════════════════════════════════════════════════
// 📊 STAT CARD WIDGET - FIXED (NO OVERFLOW)
// ═══════════════════════════════════════════════════════════════

class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final String? trend;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trend,
    this.isPositiveTrend = true,
    this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_isHovered ? 0.4 : 0.25),
                blurRadius: _isHovered ? 25 : 15,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color,
                      Color.lerp(widget.color, Colors.black, 0.15)!,
                    ],
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // ═══════════════════════════════════════
                    // 🎨 BACKGROUND DECORATIONS
                    // ═══════════════════════════════════════
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: -20,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),

                    // ═══════════════════════════════════════
                    // 📝 CONTENT
                    // ═══════════════════════════════════════
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 🔝 TOP ROW - Icon & Trend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Icon Container
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                widget.icon,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),

                            // Trend Badge
                            if (widget.trend != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.isPositiveTrend
                                          ? Icons.trending_up_rounded
                                          : Icons.trending_down_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.trend!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        // 🔢 BOTTOM SECTION - Value, Title, Subtitle
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Value
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.value,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Title
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Subtitle
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.subtitle!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    // ✨ Shine Effect on Hover
                    if (_isHovered)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.12),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
