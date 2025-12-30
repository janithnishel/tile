// // Site Visit List Screen
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/site_visit_provider.dart';
// import '../../models/site_visits/site_visit_model.dart';
// import '../../utils/site_visits/constants.dart';
// import '../../widget/site_visits/customer_expansion_tile.dart';
// import '../../widget/site_visits/statistics_card.dart';
// import 'create_site_visit_screen.dart';
// import 'site_visit_detail_screen.dart';

// class SiteVisitListScreen extends StatefulWidget {
//   const SiteVisitListScreen({super.key, this.useScaffold = true});

//   final bool useScaffold;

//   @override
//   State<SiteVisitListScreen> createState() => _SiteVisitListScreenState();
// }

// class _SiteVisitListScreenState extends State<SiteVisitListScreen> {
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context, bool isFromDate) async {
//     final provider = Provider.of<SiteVisitProvider>(context, listen: false);
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primaryPurple,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       if (isFromDate) {
//         provider.setFromDate(picked);
//       } else {
//         provider.setToDate(picked);
//       }
//     }
//   }

//   void _navigateToDetail(SiteVisitModel visit) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => SiteVisitDetailScreen(visit: visit),
//       ),
//     );
//   }

//   void _navigateToCreate() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CreateSiteVisitScreen(
//           onSave: (SiteVisitModel visit) {
//             Provider.of<SiteVisitProvider>(context, listen: false).addSiteVisitModel(visit);
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final body = Consumer<SiteVisitProvider>(
//       builder: (context, provider, child) {
//         return CustomScrollView(
//           slivers: [
//             // App Bar
//             if (widget.useScaffold) _buildAppBar(provider),

//             // Search and Filters
//             SliverToBoxAdapter(
//               child: _buildSearchAndFilters(provider),
//             ),

//             // Statistics
//             SliverToBoxAdapter(
//               child: _buildStatistics(provider),
//             ),

//             // Customer List Header
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
//                 child: Row(
//                   children: [
//                     const Text(
//                       'Customers',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       '${provider.visitsByCustomer.length} Customers',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Customer Expansion Tiles
//             provider.visitsByCustomer.isEmpty
//                 ? SliverFillRemaining(
//                     child: _buildEmptyState(),
//                   )
//                 : SliverList(
//                     delegate: SliverChildBuilderDelegate(
//                       (context, index) {
//                         final customerName = provider.visitsByCustomer.keys.toList()[index];
//                         final visits = provider.visitsByCustomer[customerName]!;
//                         return CustomerExpansionTile(
//                           customerName: customerName,
//                           visits: visits,
//                           onVisitTap: _navigateToDetail,
//                         );
//                       },
//                       childCount: provider.visitsByCustomer.length,
//                     ),
//                   ),

//             // Bottom Padding
//             const SliverToBoxAdapter(
//               child: SizedBox(height: 100),
//             ),
//           ],
//         );
//       },
//     );

//     if (widget.useScaffold) {
//       return Scaffold(
//         body: body,
//         bottomNavigationBar: _buildBottomActionBar(),
//       );
//     } else {
//       return body;
//     }
//   }

//   Widget _buildAppBar(SiteVisitProvider provider) {
//     return SliverAppBar(
//       title: const Text('Site Visit List'),
//       backgroundColor: AppColors.primaryPurple,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       floating: false,
//       pinned: true,
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.refresh),
//           onPressed: () {
//             // Refresh functionality - reload site visits from backend
//             provider.refreshSiteVisits();
//           },
//           tooltip: 'Refresh',
//         ),
//       ],
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(60),
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             children: [
//               const Text(
//                 'Site Visit List',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const Spacer(),
//               ElevatedButton.icon(
//                 onPressed: _navigateToCreate,
//                 icon: const Icon(Icons.add, color: AppColors.primaryPurple, size: 20),
//                 label: const Text(
//                   '+ New Site Visit',
//                   style: TextStyle(
//                     color: AppColors.primaryPurple,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: AppColors.primaryPurple,
//                   elevation: 2,
//                   shadowColor: Colors.black.withOpacity(0.2),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchAndFilters(SiteVisitProvider provider) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Search Bar
//           TextField(
//             controller: _searchController,
//             onChanged: provider.setSearchTerm,
//             decoration: InputDecoration(
//               hintText: 'Search by Customer Name, ID, or Project...',
//               prefixIcon: const Icon(Icons.search, color: AppColors.primaryPurple),
//               suffixIcon: _searchController.text.isNotEmpty
//                   ? IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () {
//                         _searchController.clear();
//                         provider.setSearchTerm('');
//                       },
//                     )
//                   : null,
//             ),
//           ),
//           const SizedBox(height: 12),
          
//           // Date Filters
//           Row(
//             children: [
//               Expanded(
//                 child: InkWell(
//                   onTap: () => _selectDate(context, true),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryPurple),
//                         const SizedBox(width: 8),
//                         Text(
//                           provider.fromDate != null
//                               ? '${provider.fromDate!.day}/${provider.fromDate!.month}/${provider.fromDate!.year}'
//                               : 'From Date',
//                           style: TextStyle(
//                             color: provider.fromDate != null ? Colors.black : Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: InkWell(
//                   onTap: () => _selectDate(context, false),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryPurple),
//                         const SizedBox(width: 8),
//                         Text(
//                           provider.toDate != null
//                               ? '${provider.toDate!.day}/${provider.toDate!.month}/${provider.toDate!.year}'
//                               : 'To Date',
//                           style: TextStyle(
//                             color: provider.toDate != null ? Colors.black : Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               if (provider.fromDate != null || provider.toDate != null) ...[
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: provider.clearFilters,
//                   icon: const Icon(Icons.clear_all, color: AppColors.primaryPurple),
//                   tooltip: 'Clear Filters',
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatistics(SiteVisitProvider provider) {
//     return SizedBox(
//       height: 130,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         children: [
//           SizedBox(
//             width: 140,
//             child: StatisticsCard(
//               title: 'Total Visits',
//               value: provider.totalVisits.toString(),
//               icon: Icons.description,
//               color: AppColors.primaryPurple,
//               backgroundColor: AppColors.primaryPurpleLight,
//             ),
//           ),
//           const SizedBox(width: 12),
//           SizedBox(
//             width: 140,
//             child: StatisticsCard(
//               title: 'Converted',
//               value: provider.convertedCount.toString(),
//               icon: Icons.check_circle,
//               color: AppColors.successGreen,
//               backgroundColor: AppColors.successGreenLight,
//             ),
//           ),
//           const SizedBox(width: 12),
//           SizedBox(
//             width: 140,
//             child: StatisticsCard(
//               title: 'Invoiced',
//               value: provider.invoicedCount.toString(),
//               icon: Icons.receipt,
//               color: AppColors.infoBlue,
//               backgroundColor: AppColors.infoBlueLight,
//             ),
//           ),
//           const SizedBox(width: 12),
//           SizedBox(
//             width: 140,
//             child: StatisticsCard(
//               title: 'Pending',
//               value: provider.pendingCount.toString(),
//               icon: Icons.schedule,
//               color: Colors.amber.shade700,
//               backgroundColor: AppColors.warningYellowLight,
//             ),
//           ),
//           const SizedBox(width: 12),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.description_outlined,
//             size: 80,
//             color: Colors.grey.shade300,
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'No site visits found',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Create your first site visit to get started',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade500,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: _navigateToCreate,
//             icon: const Icon(Icons.add),
//             label: const Text('Create Site Visit'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomActionBar() {
//     return Container(
//       height: 80,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           top: BorderSide(color: Colors.grey.shade200, width: 1),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: ElevatedButton.icon(
//           onPressed: _navigateToCreate,
//           icon: const Icon(Icons.add, color: Colors.white, size: 24),
//           label: const Text(
//             'New Site Visit',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primaryPurple,
//             foregroundColor: Colors.white,
//             elevation: 0,
//             shadowColor: Colors.transparent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             minimumSize: const Size(double.infinity, 56),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/services/site_visits/print_service.dart';
import '../../providers/site_visit_provider.dart';
import '../../models/site_visits/site_visit_model.dart';
import '../../utils/site_visits/constants.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import 'create_site_visit_screen.dart';
import 'site_visit_detail_screen.dart';

class SiteVisitListScreen extends StatefulWidget {
  const SiteVisitListScreen({super.key, this.useScaffold = true});

  final bool useScaffold;

  @override
  State<SiteVisitListScreen> createState() => _SiteVisitListScreenState();
}

class _SiteVisitListScreenState extends State<SiteVisitListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set auth token for API calls - safe way to access context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthAuthenticated) {
          if (mounted) {
            context.read<SiteVisitProvider>().setAuthToken(authState.token);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final provider = Provider.of<SiteVisitProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isFromDate) {
        provider.setFromDate(picked);
      } else {
        provider.setToDate(picked);
      }
    }
  }

  void _navigateToDetail(SiteVisitModel visit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SiteVisitDetailScreen(visit: visit),
      ),
    );
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSiteVisitScreen(
          onSave: (SiteVisitModel visit) {
            Provider.of<SiteVisitProvider>(context, listen: false).addSiteVisitModel(visit);
          },
        ),
      ),
    );
  }

  void _navigateToEdit(SiteVisitModel visit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSiteVisitScreen(
          editVisit: visit,
          onSave: (SiteVisitModel updatedVisit) {
            Provider.of<SiteVisitProvider>(context, listen: false).updateSiteVisit(updatedVisit);
          },
        ),
      ),
    );
  }

  void _handlePrint(SiteVisitModel visit) {
    PrintService.printInvoice(visit);
  }

  void _handleConvertToQuotation(SiteVisitModel visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.infoBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.transform, color: AppColors.infoBlue),
            ),
            const SizedBox(width: 12),
            const Text('Convert to Quotation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will convert the site visit to a quotation.'),
            const SizedBox(height: 16),
            _buildInfoRow('Customer', visit.customerName),
            _buildInfoRow('Phone', visit.contactNo),
            _buildInfoRow('Location', visit.location),
            const SizedBox(height: 16),
            const Text(
              'You can add items and finalize the quotation after conversion.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update status to CONVERTED
              final updatedVisit = visit.copyWith(status: SiteVisitStatus.converted);
              Provider.of<SiteVisitProvider>(context, listen: false)
                  .updateSiteVisit(updatedVisit);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully converted to quotation!'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.infoBlue,
            ),
            child: const Text('Convert'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Consumer<SiteVisitProvider>(
      builder: (context, provider, child) {
        return CustomScrollView(
          slivers: [
            // App Bar with Title
            _buildAppBar(provider),

            // Search and Filters
            SliverToBoxAdapter(
              child: _buildSearchAndFilters(provider),
            ),

            // Statistics
            SliverToBoxAdapter(
              child: _buildStatistics(provider),
            ),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.people,
                        color: AppColors.primaryPurple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Site Visits by Customer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${provider.visitsByCustomer.length} Customers',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Customer Expansion Tiles
            provider.visitsByCustomer.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final customerName = provider.visitsByCustomer.keys.toList()[index];
                        final visits = provider.visitsByCustomer[customerName]!;
                        return _buildCustomerExpansionTile(customerName, visits);
                      },
                      childCount: provider.visitsByCustomer.length,
                    ),
                  ),

            // Bottom Padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        );
      },
    );

    if (widget.useScaffold) {
      return Scaffold(
        body: body,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _navigateToCreate,
          backgroundColor: AppColors.primaryPurple,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'New Site Visit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return body;
    }
  }

  Widget _buildAppBar(SiteVisitProvider provider) {
    return SliverAppBar(
      expandedHeight: 140,
      backgroundColor: AppColors.primaryPurple,
      foregroundColor: Colors.white,
      elevation: 0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryPurple, Color(0xFF9333EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Site Visit Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track inspections, generate invoices & convert to quotations',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => provider.refreshSiteVisits(),
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: _navigateToCreate,
          tooltip: 'New Site Visit',
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(SiteVisitProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: provider.setSearchTerm,
            decoration: InputDecoration(
              hintText: 'Search by Customer Name, ID, or Project...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primaryPurple),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        provider.setSearchTerm('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          
          // Date Filters
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryPurple),
                        const SizedBox(width: 8),
                        Text(
                          provider.fromDate != null
                              ? '${provider.fromDate!.day}/${provider.fromDate!.month}/${provider.fromDate!.year}'
                              : 'From Date',
                          style: TextStyle(
                            color: provider.fromDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryPurple),
                        const SizedBox(width: 8),
                        Text(
                          provider.toDate != null
                              ? '${provider.toDate!.day}/${provider.toDate!.month}/${provider.toDate!.year}'
                              : 'To Date',
                          style: TextStyle(
                            color: provider.toDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (provider.fromDate != null || provider.toDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: provider.clearFilters,
                  icon: const Icon(Icons.clear_all, color: AppColors.primaryPurple),
                  tooltip: 'Clear Filters',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(SiteVisitProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Visits',
                  value: provider.totalVisits.toString(),
                  icon: Icons.description,
                  color: AppColors.primaryPurple,
                  subtitle: 'All time',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Paid',
                  value: provider.paidCount.toString(),
                  icon: Icons.payment,
                  color: AppColors.successGreen,
                  trend: '+${provider.paidCount}',
                  isPositiveTrend: true,
                  subtitle: 'Completed',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Invoiced',
                  value: provider.invoicedCount.toString(),
                  icon: Icons.receipt,
                  color: AppColors.infoBlue,
                  subtitle: 'Sent to customer',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Pending',
                  value: provider.pendingCount.toString(),
                  icon: Icons.schedule,
                  color: Colors.amber.shade700,
                  subtitle: 'Awaiting action',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerExpansionTile(String customerName, List<SiteVisitModel> visits) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryPurple, Color(0xFF9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            customerName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${visits.length} ${visits.length == 1 ? 'visit' : 'visits'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (visits.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, size: 10, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        visits.first.contactNo,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          children: visits.map((visit) {
            return _buildVisitMiniCard(visit);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildVisitMiniCard(SiteVisitModel visit) {
    return InkWell(
      onTap: () => _navigateToDetail(visit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor(visit.status),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        visit.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(visit.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          visit.status.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(visit.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visit.projectTitle.isNotEmpty ? visit.projectTitle : 'Site Visit',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${visit.date.day}/${visit.date.month}/${visit.date.year}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Rs ${visit.charge.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SiteVisitStatus status) {
    switch (status) {
      case SiteVisitStatus.converted:
        return AppColors.successGreen;
      case SiteVisitStatus.pending:
        return AppColors.warningYellow;
      case SiteVisitStatus.invoiced:
        return AppColors.infoBlue;
      case SiteVisitStatus.paid:
        return AppColors.successGreen;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No site visits found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first site visit to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create Site Visit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 📊 STAT CARD WIDGET - DASHBOARD STYLE
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
