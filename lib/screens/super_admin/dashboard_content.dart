// // lib/screens/super_admin/dashboard_content.dart

// import 'package:flutter/material.dart';
// import 'package:tilework/theme/theme.dart';
// import 'package:tilework/widget/shared/stat_card.dart';

// class DashboardContent extends StatelessWidget {
//   const DashboardContent({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(AppTheme.spacingLg),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ═══════════════════════════════════════
//           // 👋 WELCOME HEADER
//           // ═══════════════════════════════════════
//           _buildWelcomeHeader(),

//           const SizedBox(height: 28),

//           // ═══════════════════════════════════════
//           // 📊 STAT CARDS - Only Relevant Stats
//           // ═══════════════════════════════════════
//           SizedBox(
//             height: 180,
//             child: Row(
//               children: [
//                 // Total Companies
//                 Expanded(
//                   child: StatCard(
//                     title: 'Total Companies',
//                     value: '24',
//                     icon: Icons.business_rounded,
//                     color: const Color(0xFF3B82F6),
//                     subtitle: 'This month',
//                   ),
//                 ),
//                 const SizedBox(width: 20),

//                 // Active Companies
//                 Expanded(
//                   child: StatCard(
//                     title: 'Active Companies',
//                     value: '18',
//                     icon: Icons.check_circle_rounded,
//                     color: const Color(0xFF10B981),
//                     subtitle: '75% of total',
//                   ),
//                 ),
//                 const SizedBox(width: 20),

//                 // Inactive Companies
//                 Expanded(
//                   child: StatCard(
//                     title: 'Inactive Companies',
//                     value: '6',
//                     icon: Icons.pause_circle_rounded,
//                     color: const Color(0xFFF59E0B),
//                     subtitle: '25% of total',
//                   ),
//                 ),
//                 const SizedBox(width: 20),

//                 // Total Categories
//                 Expanded(
//                   child: StatCard(
//                     title: 'Total Categories',
//                     value: '48',
//                     icon: Icons.category_rounded,
//                     color: const Color(0xFF8B5CF6),
//                     subtitle: 'Across all companies',
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 32),

//           // ═══════════════════════════════════════
//           // 📈 ACTIVITY & ACTIONS
//           // ═══════════════════════════════════════
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Recent Activity
//               Expanded(
//                 flex: 3,
//                 child: _buildRecentActivity(),
//               ),
//               const SizedBox(width: 24),
//               // Quick Actions
//               Expanded(
//                 flex: 2,
//                 child: _buildQuickActions(),
//               ),
//             ],
//           ),

//           const SizedBox(height: 32),

//           // ═══════════════════════════════════════
//           // 🏢 RECENT COMPANIES
//           // ═══════════════════════════════════════
//           _buildRecentCompanies(),
//         ],
//       ),
//     );
//   }

//   // ═══════════════════════════════════════
//   // 👋 WELCOME HEADER
//   // ═══════════════════════════════════════
//   Widget _buildWelcomeHeader() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppTheme.primaryDark,
//             AppTheme.primaryLight,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppTheme.primaryAccent.withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Welcome back, Super Admin! 👋',
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Manage companies and categories from here.',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.white.withOpacity(0.85),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   children: [
//                     _buildWelcomeStat('24', 'Companies'),
//                     const SizedBox(width: 32),
//                     _buildWelcomeStat('18', 'Active'),
//                     const SizedBox(width: 32),
//                     _buildWelcomeStat('48', 'Categories'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: const Icon(
//               Icons.admin_panel_settings_rounded,
//               size: 80,
//               color: Colors.white24,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWelcomeStat(String value, String label) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 13,
//             color: Colors.white.withOpacity(0.7),
//           ),
//         ),
//       ],
//     );
//   }

//   // ═══════════════════════════════════════
//   // 📋 RECENT ACTIVITY
//   // ═══════════════════════════════════════
//   Widget _buildRecentActivity() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: AppTheme.primaryAccent.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.history_rounded,
//                   color: AppTheme.primaryAccent,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Recent Activity',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       'Latest actions in the system',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           _buildActivityItem(
//             icon: Icons.add_business_rounded,
//             title: 'New company registered',
//             subtitle: 'ABC Tiles Ltd was added',
//             time: '2 hours ago',
//             color: AppTheme.success,
//           ),
//           const Divider(height: 24),
//           _buildActivityItem(
//             icon: Icons.edit_rounded,
//             title: 'Company updated',
//             subtitle: 'XYZ Flooring info was updated',
//             time: '5 hours ago',
//             color: AppTheme.primaryAccent,
//           ),
//           const Divider(height: 24),
//           _buildActivityItem(
//             icon: Icons.category_rounded,
//             title: 'Category added',
//             subtitle: '"Vinyl" added to Premium Tiles',
//             time: '1 day ago',
//             color: const Color(0xFF8B5CF6),
//           ),
//           const Divider(height: 24),
//           _buildActivityItem(
//             icon: Icons.delete_rounded,
//             title: 'Company removed',
//             subtitle: 'Test Company was deleted',
//             time: '2 days ago',
//             color: AppTheme.error,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActivityItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required String time,
//     required Color color,
//   }) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: color, size: 20),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             time,
//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontSize: 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ═══════════════════════════════════════
//   // ⚡ QUICK ACTIONS
//   // ═══════════════════════════════════════
//   Widget _buildQuickActions() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: AppTheme.warning.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.flash_on_rounded,
//                   color: AppTheme.warning,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'Quick Actions',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           _buildQuickActionButton(
//             icon: Icons.add_business_rounded,
//             label: 'Register Company',
//             color: AppTheme.primaryAccent,
//             onTap: () {},
//           ),
//           const SizedBox(height: 12),
//           _buildQuickActionButton(
//             icon: Icons.business_rounded,
//             label: 'Manage Companies',
//             color: AppTheme.success,
//             onTap: () {},
//           ),
//           const SizedBox(height: 12),
//           _buildQuickActionButton(
//             icon: Icons.logout_rounded,
//             label: 'Logout',
//             color: AppTheme.error,
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActionButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.08),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: color.withOpacity(0.2),
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: color, size: 22),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   label,
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: color,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 size: 14,
//                 color: color.withOpacity(0.5),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ═══════════════════════════════════════
//   // 🏢 RECENT COMPANIES
//   // ═══════════════════════════════════════
//   Widget _buildRecentCompanies() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(24),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: AppTheme.success.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.business_center_rounded,
//                     color: AppTheme.success,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Recently Added Companies',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         'Latest registered companies',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Company List
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
//             itemCount: 3,
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (context, index) {
//               final companies = [
//                 {'name': 'ABC Tiles Ltd', 'owner': 'John Smith', 'active': true, 'date': 'Jan 15'},
//                 {'name': 'XYZ Flooring', 'owner': 'Jane Doe', 'active': true, 'date': 'Jan 12'},
//                 {'name': 'Premium Tiles', 'owner': 'Mike Wilson', 'active': false, 'date': 'Jan 10'},
//               ];
//               final company = companies[index];
//               return _buildCompanyItem(company);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompanyItem(Map<String, dynamic> company) {
//     final isActive = company['active'] as bool;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           // Avatar
//           Container(
//             width: 46,
//             height: 46,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: isActive
//                     ? [AppTheme.primaryAccent, AppTheme.primaryAccent.withOpacity(0.7)]
//                     : [Colors.grey, Colors.grey.shade400],
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Center(
//               child: Text(
//                 (company['name'] as String)[0],
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),

//           // Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   company['name'] as String,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 15,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   'Owner: ${company['owner']}',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Date
//           Text(
//             company['date'] as String,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade500,
//             ),
//           ),

//           const SizedBox(width: 16),

//           // Status
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: isActive
//                   ? AppTheme.success.withOpacity(0.1)
//                   : AppTheme.warning.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 6,
//                   height: 6,
//                   decoration: BoxDecoration(
//                     color: isActive ? AppTheme.success : AppTheme.warning,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   isActive ? 'Active' : 'Inactive',
//                   style: TextStyle(
//                     color: isActive ? AppTheme.success : AppTheme.warning,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/super_admin/dashboard_content.dart

import 'package:flutter/material.dart';
import 'package:tilework/theme/theme.dart';
import '../../widget/super_admin/stat_card.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════
          // 👋 WELCOME HEADER
          // ═══════════════════════════════════════
          _buildWelcomeHeader(),

          const SizedBox(height: 32),

          // ═══════════════════════════════════════
          // 📊 BEAUTIFUL STAT CARDS
          // ═══════════════════════════════════════
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout: use Wrap for smaller screens, Row for larger screens
              final maxWidth = constraints.maxWidth;
              final useWrap = maxWidth < 900; // Breakpoint for responsive layout

              if (useWrap) {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: (maxWidth - 16) / 2, // 2 cards per row with spacing
                      child: StatCard(
                        title: 'Total Companies',
                        value: '24',
                        icon: Icons.business_rounded,
                        color: const Color(0xFF3B82F6), // Blue
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
                        value: '18',
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF10B981), // Green
                        subtitle: '75% of total',
                        onTap: () {},
                      ),
                    ),
                    SizedBox(
                      width: (maxWidth - 16) / 2,
                      child: StatCard(
                        title: 'Inactive Companies',
                        value: '6',
                        icon: Icons.pause_circle_rounded,
                        color: const Color(0xFFF59E0B), // Yellow/Orange
                        subtitle: '25% of total',
                        onTap: () {},
                      ),
                    ),
                    SizedBox(
                      width: (maxWidth - 16) / 2,
                      child: StatCard(
                        title: 'Total Categories',
                        value: '48',
                        icon: Icons.category_rounded,
                        color: const Color(0xFF8B5CF6), // Purple
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
                      // 🔵 Total Companies
                      Expanded(
                        child: StatCard(
                          title: 'Total Companies',
                          value: '24',
                          icon: Icons.business_rounded,
                          color: const Color(0xFF3B82F6), // Blue
                          trend: '+3',
                          isPositiveTrend: true,
                          subtitle: 'This month',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 20),

                      // 🟢 Active Companies
                      Expanded(
                        child: StatCard(
                          title: 'Active Companies',
                          value: '18',
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF10B981), // Green
                          subtitle: '75% of total',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 20),

                      // 🟡 Inactive Companies
                      Expanded(
                        child: StatCard(
                          title: 'Inactive Companies',
                          value: '6',
                          icon: Icons.pause_circle_rounded,
                          color: const Color(0xFFF59E0B), // Yellow/Orange
                          subtitle: '25% of total',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 20),

                      // 💜 Total Categories
                      Expanded(
                        child: StatCard(
                          title: 'Total Categories',
                          value: '48',
                          icon: Icons.category_rounded,
                          color: const Color(0xFF8B5CF6), // Purple
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
          ),

          const SizedBox(height: 32),

          // ═══════════════════════════════════════
          // 📈 ACTIVITY & ACTIONS
          // ═══════════════════════════════════════
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildRecentActivity()),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildQuickActions()),
            ],
          ),

          const SizedBox(height: 32),

          // ═══════════════════════════════════════
          // 🏢 RECENT COMPANIES
          // ═══════════════════════════════════════
          _buildRecentCompanies(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // 👋 WELCOME HEADER
  // ═══════════════════════════════════════
  Widget _buildWelcomeHeader() {
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
                          '24',
                          'Companies',
                          Icons.business_rounded,
                        ),
                        const SizedBox(width: 32),
                        _buildWelcomeStat(
                          '18',
                          'Active',
                          Icons.check_circle_rounded,
                        ),
                        const SizedBox(width: 32),
                        _buildWelcomeStat(
                          '48',
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
  // 📋 RECENT ACTIVITY
  // ═══════════════════════════════════════
  Widget _buildRecentActivity() {
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
          _buildActivityItem(
            icon: Icons.add_business_rounded,
            title: 'New company registered',
            subtitle: 'ABC Tiles Ltd was added',
            time: '2 hours ago',
            color: const Color(0xFF10B981),
          ),
          _buildDivider(),
          _buildActivityItem(
            icon: Icons.edit_rounded,
            title: 'Company updated',
            subtitle: 'XYZ Flooring info was updated',
            time: '5 hours ago',
            color: const Color(0xFF3B82F6),
          ),
          _buildDivider(),
          _buildActivityItem(
            icon: Icons.category_rounded,
            title: 'Category added',
            subtitle: '"Vinyl" added to Premium Tiles',
            time: '1 day ago',
            color: const Color(0xFF8B5CF6),
          ),
          _buildDivider(),
          _buildActivityItem(
            icon: Icons.delete_rounded,
            title: 'Company removed',
            subtitle: 'Test Company was deleted',
            time: '2 days ago',
            color: const Color(0xFFEF4444),
          ),
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
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.business_rounded,
            label: 'Manage Companies',
            color: const Color(0xFF10B981),
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildQuickActionButton(
            icon: Icons.logout_rounded,
            label: 'Logout',
            color: const Color(0xFFEF4444),
            onTap: () {},
          ),
        ],
      ),
    );
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
  Widget _buildRecentCompanies() {
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final companies = [
                {
                  'name': 'ABC Tiles Ltd',
                  'owner': 'John Smith',
                  'active': true,
                  'date': 'Jan 15',
                },
                {
                  'name': 'XYZ Flooring',
                  'owner': 'Jane Doe',
                  'active': true,
                  'date': 'Jan 12',
                },
                {
                  'name': 'Premium Tiles',
                  'owner': 'Mike Wilson',
                  'active': false,
                  'date': 'Jan 10',
                },
              ];
              return _buildCompanyItem(companies[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyItem(Map<String, dynamic> company) {
    final isActive = company['active'] as bool;

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
                (company['name'] as String)[0],
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
                  company['name'] as String,
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
                      company['owner'] as String,
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
                company['date'] as String,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
