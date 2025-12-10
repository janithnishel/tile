// // lib/screens/super_admin/company_management_screen.dart

// import 'package:flutter/material.dart';
// import 'package:tilework/models/super_admin/company_model.dart';
// import 'package:tilework/theme/theme.dart';
// import 'package:tilework/widget/super_admin/app_button.dart';
// import 'package:tilework/widget/super_admin/app_card.dart';
// import 'package:tilework/widget/super_admin/dialogs/company_register_dialog.dart';
// import 'package:tilework/widget/super_admin/dialogs/confirm_dialog.dart'; // 👈 NEW
// import 'company_setup_screen.dart';

// class CompanyManagementScreen extends StatefulWidget {
//   const CompanyManagementScreen({Key? key}) : super(key: key);

//   @override
//   State<CompanyManagementScreen> createState() =>
//       _CompanyManagementScreenState();
// }

// class _CompanyManagementScreenState extends State<CompanyManagementScreen> {
//   final _searchController = TextEditingController();
//   CompanyModel? _selectedCompany;
//   String _searchQuery = ''; // 👈 NEW

//   // Sample data
//   final List<CompanyModel> _companies = [
//     CompanyModel(
//       id: '1',
//       companyName: 'ABC Tiles Ltd',
//       companyAddress: '123 Main Street, Colombo',
//       companyPhone: '011-2345678',
//       ownerName: 'John Smith',
//       ownerEmail: 'john@abctiles.com',
//       ownerPhone: '077-1234567',
//       isActive: true,
//     ),
//     CompanyModel(
//       id: '2',
//       companyName: 'XYZ Flooring',
//       companyAddress: '456 Galle Road, Colombo',
//       companyPhone: '011-8765432',
//       ownerName: 'Jane Doe',
//       ownerEmail: 'jane@xyzflooring.com',
//       ownerPhone: '077-9876543',
//       isActive: true,
//     ),
//     CompanyModel(
//       id: '3',
//       companyName: 'Premium Tiles',
//       companyAddress: '789 Kandy Road, Colombo',
//       companyPhone: '011-5555555',
//       ownerName: 'Mike Wilson',
//       ownerEmail: 'mike@premiumtiles.com',
//       ownerPhone: '077-5555555',
//       isActive: false,
//     ),
//   ];

//   // ═══════════════════════════════════════
//   // 🔍 FILTERED COMPANIES (NEW)
//   // ═══════════════════════════════════════
//   List<CompanyModel> get _filteredCompanies {
//     if (_searchQuery.isEmpty) return _companies;
//     return _companies.where((company) {
//       return company.companyName
//               .toLowerCase()
//               .contains(_searchQuery.toLowerCase()) ||
//           company.ownerName
//               .toLowerCase()
//               .contains(_searchQuery.toLowerCase()) ||
//           company.ownerEmail
//               .toLowerCase()
//               .contains(_searchQuery.toLowerCase());
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_selectedCompany != null) {
//       return CompanySetupScreen(
//         company: _selectedCompany!,
//         onBack: () {
//           setState(() {
//             _selectedCompany = null;
//           });
//         },
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.all(AppTheme.spacingLg),
//       child: Row(
//         children: [
//           // Master View
//           Expanded(
//             flex: 5, // Changed from 4 to 5
//             child: AppCard(
//               padding: EdgeInsets.zero,
//               child: Column(
//                 children: [
//                   _buildListHeader(), // 👈 Extracted method
//                   Expanded(
//                     child: _filteredCompanies.isEmpty
//                         ? _buildEmptyState() // 👈 NEW
//                         : ListView.separated(
//                             padding: const EdgeInsets.all(12),
//                             itemCount: _filteredCompanies.length,
//                             separatorBuilder: (_, __) =>
//                                 const SizedBox(height: 8),
//                             itemBuilder: (context, index) {
//                               final company = _filteredCompanies[index];
//                               return _buildCompanyTile(company);
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: 24),
//           Expanded(
//             flex: 3,
//             child: _buildDetailPanel(), // 👈 Extracted method
//           ),
//         ],
//       ),
//     );
//   }

//   // ═══════════════════════════════════════
//   // 🔝 LIST HEADER (NEW - Extracted)
//   // ═══════════════════════════════════════
//   Widget _buildListHeader() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: AppTheme.border),
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: AppTheme.primaryAccent.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(
//                   Icons.business_center_rounded,
//                   color: AppTheme.primaryAccent,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Companies', style: AppTheme.heading3),
//                   Text(
//                     '${_companies.length} total companies',
//                     style: AppTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               AppButton(
//                 text: 'Register New',
//                 icon: Icons.add_rounded,
//                 onPressed: _showRegisterDialog,
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           // 🔍 Search with clear button
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppTheme.border),
//             ),
//             child: TextField(
//               controller: _searchController,
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Search companies...',
//                 hintStyle: TextStyle(color: Colors.grey.shade400),
//                 prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
//                 suffixIcon: _searchQuery.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear, size: 20),
//                         onPressed: () {
//                           _searchController.clear();
//                           setState(() {
//                             _searchQuery = '';
//                           });
//                         },
//                       )
//                     : null,
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ═══════════════════════════════════════
//   // 🏢 COMPANY TILE (UPDATED - Edit/Delete added)
//   // ═══════════════════════════════════════
//   Widget _buildCompanyTile(CompanyModel company) {
//     return AppCard(
//       padding: const EdgeInsets.all(16),
//       onTap: () {
//         setState(() {
//           _selectedCompany = company;
//         });
//       },
//       child: Row(
//         children: [
//           // Avatar
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               gradient: AppTheme.cardGradient(
//                 company.isActive ? AppTheme.primaryAccent : Colors.grey,
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Center(
//               child: Text(
//                 company.companyName[0].toUpperCase(),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
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
//                   company.companyName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.person_outline,
//                       size: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       company.ownerName,
//                       style: AppTheme.bodyMedium,
//                     ),
//                     const SizedBox(width: 12),
//                     Icon(
//                       Icons.email_outlined,
//                       size: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                     const SizedBox(width: 4),
//                     Flexible(
//                       child: Text(
//                         company.ownerEmail,
//                         style: AppTheme.bodyMedium,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Status Badge
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: company.isActive
//                   ? AppTheme.success.withOpacity(0.1)
//                   : AppTheme.warning.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   company.isActive
//                       ? Icons.check_circle_rounded
//                       : Icons.pause_circle_rounded,
//                   size: 14,
//                   color: company.isActive ? AppTheme.success : AppTheme.warning,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   company.isActive ? 'Active' : 'Inactive',
//                   style: TextStyle(
//                     color:
//                         company.isActive ? AppTheme.success : AppTheme.warning,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(width: 8),

//           // ═══════════════════════════════════════
//           // ✏️ EDIT BUTTON (NEW)
//           // ═══════════════════════════════════════
//           _buildActionButton(
//             icon: Icons.edit_outlined,
//             color: AppTheme.primaryAccent,
//             tooltip: 'Edit Company',
//             onTap: () => _showEditDialog(company),
//           ),

//           const SizedBox(width: 4),

//           // ═══════════════════════════════════════
//           // 🗑️ DELETE BUTTON (NEW)
//           // ═══════════════════════════════════════
//           _buildActionButton(
//             icon: Icons.delete_outline_rounded,
//             color: AppTheme.error,
//             tooltip: 'Delete Company',
//             onTap: () => _showDeleteConfirmation(company),
//           ),

//           const SizedBox(width: 8),

//           Icon(
//             Icons.chevron_right_rounded,
//             color: Colors.grey.shade400,
//           ),
//         ],
//       ),
//     );
//   }

//   // ═══════════════════════════════════════
//   // 🔘 ACTION BUTTON (NEW)
//   // ═══════════════════════════════════════
//   Widget _buildActionButton({
//     required IconData icon,
//     required Color color,
//     required String tooltip,
//     required VoidCallback onTap,
//   }) {
//     return Tooltip(
//       message: tooltip,
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(8),
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 18,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ═══════════════════════════════════════
//   // 📄 DETAIL PANEL (NEW - Extracted with Quick Actions)
//   // ═══════════════════════════════════════
//   Widget _buildDetailPanel() {
//     return AppCard(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppTheme.primaryAccent.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.touch_app_rounded,
//               size: 48,
//               color: AppTheme.primaryAccent.withOpacity(0.5),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Select a Company',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Click on a company from the list\nto view details and setup options',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.grey.shade500,
//               height: 1.5,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppTheme.border),
//             ),
//             child: Column(
//               children: [
//                 _buildQuickAction(
//                   Icons.add_business_rounded,
//                   'Register New Company',
//                   _showRegisterDialog,
//                 ),
//                 const Divider(height: 24),
//                 _buildQuickAction(
//                   Icons.search_rounded,
//                   'Search Companies',
//                   () {
//                     // Focus search field
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Row(
//         children: [
//           Icon(icon, color: AppTheme.primaryAccent, size: 20),
//           const SizedBox(width: 12),
//           Text(
//             label,
//             style: TextStyle(
//               color: AppTheme.primaryAccent,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const Spacer(),
//           Icon(
//             Icons.arrow_forward_ios_rounded,
//             size: 14,
//             color: Colors.grey.shade400,
//           ),
//         ],
//       ),
//     );
//   }

//   // ═══════════════════════════════════════
//   // 🔲 EMPTY STATE (NEW)
//   // ═══════════════════════════════════════
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             _searchQuery.isNotEmpty
//                 ? Icons.search_off_rounded
//                 : Icons.business_outlined,
//             size: 64,
//             color: Colors.grey.shade300,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             _searchQuery.isNotEmpty ? 'No companies found' : 'No companies yet',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _searchQuery.isNotEmpty
//                 ? 'Try different search terms'
//                 : 'Register your first company',
//             style: TextStyle(
//               color: Colors.grey.shade500,
//             ),
//           ),
//           if (_searchQuery.isEmpty) ...[
//             const SizedBox(height: 20),
//             AppButton(
//               text: 'Register Company',
//               icon: Icons.add_rounded,
//               onPressed: _showRegisterDialog,
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   // ═══════════════════════════════════════
//   // ➕ REGISTER DIALOG
//   // ═══════════════════════════════════════
//   Future<void> _showRegisterDialog() async {
//     final result = await CompanyRegisterDialog.show(context);

//     if (result != null) {
//       setState(() {
//         _companies.add(result);
//       });
//       _showSuccessSnackBar('Company registered successfully!'); // 👈 NEW
//     }
//   }

//   // ═══════════════════════════════════════
//   // ✏️ EDIT DIALOG (NEW)
//   // ═══════════════════════════════════════
//   Future<void> _showEditDialog(CompanyModel company) async {
//     final result = await CompanyRegisterDialog.show(
//       context,
//       company: company,
//     );

//     if (result != null) {
//       setState(() {
//         final index = _companies.indexWhere((c) => c.id == company.id);
//         if (index != -1) {
//           _companies[index] = result;
//         }
//       });
//       _showSuccessSnackBar('Company updated successfully!');
//     }
//   }

//   // ═══════════════════════════════════════
//   // 🗑️ DELETE CONFIRMATION (NEW)
//   // ═══════════════════════════════════════
//   Future<void> _showDeleteConfirmation(CompanyModel company) async {
//     final result = await ConfirmDialog.show(
//       context: context,
//       title: 'Delete Company',
//       message:
//           'Are you sure you want to delete "${company.companyName}"?\n\nThis action cannot be undone.',
//       confirmText: 'Delete',
//       cancelText: 'Cancel',
//       icon: Icons.delete_forever_rounded,
//       isDanger: true,
//     );

//     if (result == true) {
//       setState(() {
//         _companies.removeWhere((c) => c.id == company.id);
//       });
//       _showSuccessSnackBar('Company deleted successfully!');
//     }
//   }

//   // ═══════════════════════════════════════
//   // ✅ SUCCESS SNACKBAR (NEW)
//   // ═══════════════════════════════════════
//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.check_circle_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               message,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.success,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
// }


//--------------------------------------------------------------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tilework/cubits/auth/auth_cubit.dart';
// import 'package:tilework/cubits/company/company_cubit.dart';
// import 'package:tilework/cubits/company/company_state.dart';
// import 'package:tilework/models/super_admin/company_model.dart';
// import 'package:tilework/theme/theme.dart';
// import 'package:tilework/widget/super_admin/app_button.dart';
// import 'package:tilework/widget/super_admin/app_card.dart';
// import 'package:tilework/widget/super_admin/dialogs/company_register_dialog.dart';
// import 'package:tilework/widget/super_admin/dialogs/confirm_dialog.dart';
// import 'company_setup_screen.dart';

// class CompanyManagementScreen extends StatefulWidget {
//   const CompanyManagementScreen({Key? key}) : super(key: key);

//   @override
//   State<CompanyManagementScreen> createState() => _CompanyManagementScreenState();
// }

// class _CompanyManagementScreenState extends State<CompanyManagementScreen> {
//   final _searchController = TextEditingController();
//   CompanyModel? _selectedCompany;
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     // 🚀 Start: Load companies when the screen opens
//     context.read<CompanyCubit>().loadCompanies();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     setState(() {
//       _searchQuery = _searchController.text;
//     });
//   }
  
//   // 🔍 FILTERED COMPANIES (Cubit state මත පදනම්ව)
//   List<CompanyModel> _getFilteredCompanies(List<CompanyModel> companies) {
//     if (_searchQuery.isEmpty) return companies;
//     return companies.where((company) {
//       final query = _searchQuery.toLowerCase();
//       return company.companyName.toLowerCase().contains(query) ||
//           company.ownerName.toLowerCase().contains(query) ||
//           company.ownerEmail.toLowerCase().contains(query);
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_selectedCompany != null) {
//       return CompanySetupScreen(
//         company: _selectedCompany!,
//         onBack: () {
//           setState(() {
//             _selectedCompany = null;
//           });
//         },
//       );
//     }

//     return BlocBuilder<CompanyCubit, CompanyState>(
//       builder: (context, state) {
//         final List<CompanyModel> companies = state.companies;
//         final List<CompanyModel> filteredCompanies = _getFilteredCompanies(companies);
        
//         return Padding(
//           padding: const EdgeInsets.all(AppTheme.spacingLg),
//           child: Row(
//             children: [
//               Expanded(
//                 flex: 5,
//                 child: AppCard(
//                   padding: EdgeInsets.zero,
//                   child: Column(
//                     children: [
//                       _buildListHeader(companies.length, state.isLoading),
//                       Expanded(
//                         child: state.isLoading 
//                             ? const Center(child: CircularProgressIndicator())
//                             : filteredCompanies.isEmpty
//                                 ? _buildEmptyState(
//                                     companies.isEmpty, 
//                                     _searchQuery.isNotEmpty,
//                                   )
//                                 : ListView.separated(
//                                     padding: const EdgeInsets.all(12),
//                                     itemCount: filteredCompanies.length,
//                                     separatorBuilder: (_, __) => const SizedBox(height: 8),
//                                     itemBuilder: (context, index) {
//                                       final company = filteredCompanies[index];
//                                       return _buildCompanyTile(company);
//                                     },
//                                   ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 24),
//               Expanded(
//                 flex: 3,
//                 child: _buildDetailPanel(),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
  
//   // ═══════════════════════════════════════
//   // 🔝 LIST HEADER
//   // ═══════════════════════════════════════
//   Widget _buildListHeader(int companyCount, bool isLoading) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: AppTheme.border),
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: AppTheme.primaryAccent.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(
//                   Icons.business_center_rounded,
//                   color: AppTheme.primaryAccent,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Companies', style: AppTheme.heading3),
//                   Text(
//                     '$companyCount total companies',
//                     style: AppTheme.bodyMedium,
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               AppButton(
//                 text: 'Register New',
//                 icon: Icons.add_rounded,
//                 onPressed: _showRegisterDialog,
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           // 🔍 Search with clear button
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppTheme.border),
//             ),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search companies...',
//                 hintStyle: TextStyle(color: Colors.grey.shade400),
//                 prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
//                 suffixIcon: _searchQuery.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear, size: 20),
//                         onPressed: () {
//                           _searchController.clear();
//                           setState(() {
//                             _searchQuery = '';
//                           });
//                         },
//                       )
//                     : null,
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // ═══════════════════════════════════════
//   // 🏢 COMPANY TILE
//   // ═══════════════════════════════════════
//   Widget _buildCompanyTile(CompanyModel company) {
//     return AppCard(
//       padding: const EdgeInsets.all(16),
//       onTap: () {
//         setState(() {
//           _selectedCompany = company;
//         });
//       },
//       child: Row(
//         children: [
//           // Avatar
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               gradient: AppTheme.cardGradient(
//                 company.isActive ? AppTheme.primaryAccent : Colors.grey,
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Center(
//               child: Text(
//                 company.companyName[0].toUpperCase(),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
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
//                   company.companyName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.person_outline,
//                       size: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       company.ownerName,
//                       style: AppTheme.bodyMedium,
//                     ),
//                     const SizedBox(width: 12),
//                     Icon(
//                       Icons.email_outlined,
//                       size: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                     const SizedBox(width: 4),
//                     Flexible(
//                       child: Text(
//                         company.ownerEmail,
//                         style: AppTheme.bodyMedium,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Status Badge
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: company.isActive
//                   ? AppTheme.success.withOpacity(0.1)
//                   : AppTheme.warning.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   company.isActive
//                       ? Icons.check_circle_rounded
//                       : Icons.pause_circle_rounded,
//                   size: 14,
//                   color: company.isActive ? AppTheme.success : AppTheme.warning,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   company.isActive ? 'Active' : 'Inactive',
//                   style: TextStyle(
//                     color:
//                         company.isActive ? AppTheme.success : AppTheme.warning,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(width: 8),

//           // ═══════════════════════════════════════
//           // ✏️ EDIT BUTTON (NEW)
//           // ═══════════════════════════════════════
//           _buildActionButton(
//             icon: Icons.edit_outlined,
//             color: AppTheme.primaryAccent,
//             tooltip: 'Edit Company',
//             onTap: () => _showEditDialog(company),
//           ),

//           const SizedBox(width: 4),

//           // ═══════════════════════════════════════
//           // 🗑️ DELETE BUTTON (NEW)
//           // ═══════════════════════════════════════
//           _buildActionButton(
//             icon: Icons.delete_outline_rounded,
//             color: AppTheme.error,
//             tooltip: 'Delete Company',
//             onTap: () => _showDeleteConfirmation(company),
//           ),

//           const SizedBox(width: 8),

//           Icon(
//             Icons.chevron_right_rounded,
//             color: Colors.grey.shade400,
//           ),
//         ],
//       ),
//     );
//   }

//   // ═══════════════════════════════════════
//   // 🔲 EMPTY STATE
//   // ═══════════════════════════════════════
//   Widget _buildEmptyState(bool isListEmpty, bool isSearching) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             isSearching
//                 ? Icons.search_off_rounded
//                 : Icons.business_outlined,
//             size: 64,
//             color: Colors.grey.shade300,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             isSearching ? 'No companies found' : 'No companies yet',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             isSearching
//                 ? 'Try different search terms'
//                 : 'Register your first company',
//             style: TextStyle(
//               color: Colors.grey.shade500,
//             ),
//           ),
//           if (!isSearching) ...[
//             const SizedBox(height: 20),
//             AppButton(
//               text: 'Register Company',
//               icon: Icons.add_rounded,
//               onPressed: _showRegisterDialog,
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   // ═══════════════════════════════════════
//   // ➕ REGISTER DIALOG (API CALL IMPLEMENTED)
//   // ═══════════════════════════════════════
//   Future<void> _showRegisterDialog() async {
//     final Map<String, dynamic>? result = await CompanyRegisterDialog.show(context);

//     if (result != null) {
//       try {
//         final AuthCubit authCubit = context.read<AuthCubit>();
        
//         // 🎯 1. Register the company/user via AuthCubit
//         await authCubit.registerCompany(
//           ownerName: result['ownerName'],
//           ownerEmail: result['ownerEmail'],
//           password: result['password'], 
//           ownerPhone: result['ownerPhone'],
//           companyName: result['companyName'],
//           companyAddress: result['companyAddress'],
//           companyPhone: result['companyPhone'],
//         );
        
//         // 2. Refresh company list from the server to get the newly registered company
//         await context.read<CompanyCubit>().loadCompanies();
//         _showSuccessSnackBar('Company registered and user created successfully!');

//       } catch (e) {
//         _showErrorSnackBar('Registration Failed: ${e.toString().split(':').last}'); 
//       }
//     }
//   }

//   // ═══════════════════════════════════════
//   // ✏️ EDIT DIALOG (Cubit API CALL IMPLEMENTED)
//   // ═══════════════════════════════════════
//   Future<void> _showEditDialog(CompanyModel company) async {
//     final Map<String, dynamic>? result = await CompanyRegisterDialog.show(
//       context,
//       company: company,
//     );

//     if (result != null) {
//       try {
//         // Create an updated model by merging old and new data
//         final updatedCompany = CompanyModel.fromJson({
//           ...company.toJson(), // Keep existing data (like ID)
//           ...result, // Override with new data
//         });

//         // 🎯 1. Use CompanyCubit to update the company
//         await context.read<CompanyCubit>().updateCompany(updatedCompany);
        
//         // 2. Update the selected company state to reflect changes immediately
//         if (_selectedCompany?.id == updatedCompany.id) {
//           setState(() {
//             _selectedCompany = updatedCompany;
//           });
//         }
//         _showSuccessSnackBar('Company updated successfully!');

//       } catch (e) {
//         _showErrorSnackBar('Update Failed: ${e.toString().split(':').last}');
//       }
//     }
//   }

//   // ═══════════════════════════════════════
//   // 🗑️ DELETE CONFIRMATION (Cubit API CALL IMPLEMENTED)
//   // ═══════════════════════════════════════
//   Future<void> _showDeleteConfirmation(CompanyModel company) async {
//     final bool? result = await ConfirmDialog.show(
//       context: context,
//       title: 'Delete Company',
//       message:
//           'Are you sure you want to delete "${company.companyName}"?\n\nThis action cannot be undone.',
//       confirmText: 'Delete',
//       cancelText: 'Cancel',
//       icon: Icons.delete_forever_rounded,
//       isDanger: true,
//     );

//     if (result == true) {
//       try {
//         // 🎯 1. Use CompanyCubit to delete the company
//         await context.read<CompanyCubit>().deleteCompany(company.id);

//         // 2. Clear selected company if it was the one deleted
//         if (_selectedCompany?.id == company.id) {
//           setState(() {
//             _selectedCompany = null;
//           });
//         }
//         _showSuccessSnackBar('Company deleted successfully!');
//       } catch (e) {
//         _showErrorSnackBar('Deletion Failed: ${e.toString().split(':').last}');
//       }
//     }
//   }
  
//   // ═══════════════════════════════════════
//   // 🔘 ACTION BUTTON
//   // ═══════════════════════════════════════
//   Widget _buildActionButton({
//     required IconData icon,
//     required Color color,
//     required String tooltip,
//     required VoidCallback onTap,
//   }) {
//     return Tooltip(
//       message: tooltip,
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(8),
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 18,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ═══════════════════════════════════════
//   // 📄 DETAIL PANEL
//   // ═══════════════════════════════════════
//   Widget _buildDetailPanel() {
//     return AppCard(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppTheme.primaryAccent.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.touch_app_rounded,
//               size: 48,
//               color: AppTheme.primaryAccent.withOpacity(0.5),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Select a Company',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Click on a company from the list\nto view details and setup options',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.grey.shade500,
//               height: 1.5,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppTheme.border),
//             ),
//             child: Column(
//               children: [
//                 _buildQuickAction(
//                   Icons.add_business_rounded,
//                   'Register New Company',
//                   _showRegisterDialog,
//                 ),
//                 const Divider(height: 24),
//                 _buildQuickAction(
//                   Icons.search_rounded,
//                   'Search Companies',
//                   () {
//                     // Focus search field
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Row(
//         children: [
//           Icon(icon, color: AppTheme.primaryAccent, size: 20),
//           const SizedBox(width: 12),
//           Text(
//             label,
//             style: TextStyle(
//               color: AppTheme.primaryAccent,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const Spacer(),
//           Icon(
//             Icons.arrow_forward_ios_rounded,
//             size: 14,
//             color: Colors.grey.shade400,
//           ),
//         ],
//       ),
//     );
//   }

//   // ═══════════════════════════════════════
//   // ✅ SUCCESS & ❌ ERROR SNACKBARS
//   // ═══════════════════════════════════════
//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.check_circle_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               message,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.success,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.error_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               message,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppTheme.error,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 4),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/super_admin/company/company_cubit.dart';
import 'package:tilework/cubits/super_admin/company/company_state.dart';
import 'package:tilework/models/super_admin/company_model.dart';
import 'package:tilework/theme/theme.dart';
import 'package:tilework/widget/super_admin/app_button.dart';
import 'package:tilework/widget/super_admin/app_card.dart';
import 'package:tilework/widget/super_admin/dialogs/company_register_dialog.dart';
import 'package:tilework/widget/super_admin/dialogs/confirm_dialog.dart';
import 'company_setup_screen.dart'; // Setup screen එකේ path එක නිවැරදි කරගන්න

class CompanyManagementScreen extends StatefulWidget {
  const CompanyManagementScreen({Key? key}) : super(key: key);

  @override
  State<CompanyManagementScreen> createState() => _CompanyManagementScreenState();
}

class _CompanyManagementScreenState extends State<CompanyManagementScreen> {
  final _searchController = TextEditingController();
  CompanyModel? _selectedCompany;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 🚀 Start: තිරය විවෘත වන විට companies load කිරීම.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = _getToken();
      context.read<CompanyCubit>().loadCompanies(token: token);
    });
    _searchController.addListener(_onSearchChanged);
  }

  // Helper method to get token from AuthCubit
  String? _getToken() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      return authState.token;
    }
    return null;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }
  
  // 🔍 FILTERED COMPANIES (Cubit state මත පදනම්ව filter කිරීම)
  List<CompanyModel> _getFilteredCompanies(List<CompanyModel> companies) {
    if (_searchQuery.isEmpty) return companies;
    return companies.where((company) {
      final query = _searchQuery.toLowerCase();
      return company.companyName.toLowerCase().contains(query) ||
          company.ownerName.toLowerCase().contains(query) ||
          company.ownerEmail.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedCompany != null) {
      return CompanySetupScreen(
        company: _selectedCompany!,
        onBack: () {
          setState(() {
            _selectedCompany = null;
            // Back වූ පසු company list එක refresh කරන්න
            final token = _getToken();
            context.read<CompanyCubit>().loadCompanies(token: token);
          });
        },
      );
    }

    // 🎯 BlocBuilder මඟින් CompanyState එකට සවන් දීම
    return BlocConsumer<CompanyCubit, CompanyState>(
      listener: (context, state) {
        // දෝෂයක් (Error) ඇති වුවහොත් පෙන්වීමට
        if (state.errorMessage != null && !state.isLoading) {
          _showErrorSnackBar(state.errorMessage!);
        }
      },
      builder: (context, state) {
        final List<CompanyModel> companies = state.companies;
        final List<CompanyModel> filteredCompanies = _getFilteredCompanies(companies);
        
        return Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Row(
            children: [
              // Master View
              Expanded(
                flex: 5,
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildListHeader(companies.length, state.isLoading),
                      Expanded(
                        child: state.isLoading && companies.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : _buildListBody(filteredCompanies, state.isLoading),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Detail Panel
              Expanded(
                flex: 3,
                child: _buildDetailPanel(),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // ═══════════════════════════════════════
  // 🔝 LIST HEADER
  // ═══════════════════════════════════════
  Widget _buildListHeader(int companyCount, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  color: AppTheme.primaryAccent,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Companies', style: AppTheme.heading3),
                  Text(
                    // Loading නම් 'Loading...' නැතිනම් Count එක පෙන්වයි
                    isLoading && companyCount == 0 ? 'Loading companies...' : '${companyCount} total companies',
                    style: AppTheme.bodyMedium.copyWith(
                      color: isLoading ? AppTheme.warning : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AppButton(
                text: 'Register New',
                icon: Icons.add_rounded,
                onPressed: isLoading ? null : _showRegisterDialog, // Loading නම් Disable කරයි
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 🔍 Search with clear button
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search companies...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // 📜 LIST BODY (List/Empty state logic)
  // ═══════════════════════════════════════
  Widget _buildListBody(List<CompanyModel> filteredCompanies, bool isLoading) {
    if (filteredCompanies.isEmpty) {
      final isListEmpty = context.read<CompanyCubit>().state.companies.isEmpty;
      return _buildEmptyState(isListEmpty, _searchQuery.isNotEmpty);
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: filteredCompanies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final company = filteredCompanies[index];
        return _buildCompanyTile(company);
      },
    );
  }
  
  // ═══════════════════════════════════════
  // 🏢 COMPANY TILE
  // ═══════════════════════════════════════
  Widget _buildCompanyTile(CompanyModel company) {
    // ... Tile UI Logic (ඔබ කලින් දුන් කේතය) ...
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        setState(() {
          _selectedCompany = company;
        });
      },
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient(
                company.isActive ? AppTheme.primaryAccent : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                company.companyName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.companyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      company.ownerName,
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        company.ownerEmail,
                        style: AppTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: company.isActive
                  ? AppTheme.success.withOpacity(0.1)
                  : AppTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  company.isActive
                      ? Icons.check_circle_rounded
                      : Icons.pause_circle_rounded,
                  size: 14,
                  color: company.isActive ? AppTheme.success : AppTheme.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  company.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: company.isActive ? AppTheme.success : AppTheme.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ✏️ EDIT BUTTON
          _buildActionButton(
            icon: Icons.edit_outlined,
            color: AppTheme.primaryAccent,
            tooltip: 'Edit Company',
            onTap: () => _showEditDialog(company),
          ),

          const SizedBox(width: 4),

          // 🗑️ DELETE BUTTON
          _buildActionButton(
            icon: Icons.delete_outline_rounded,
            color: AppTheme.error,
            tooltip: 'Delete Company',
            onTap: () => _showDeleteConfirmation(company),
          ),

          const SizedBox(width: 8),

          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
  
  // ═══════════════════════════════════════
  // 🔲 EMPTY STATE
  // ═══════════════════════════════════════
  Widget _buildEmptyState(bool isListEmpty, bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching
                ? Icons.search_off_rounded
                : Icons.business_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No companies found' : 'No companies yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try different search terms'
                : 'Register your first company',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          if (isListEmpty && !isSearching) ...[
            const SizedBox(height: 20),
            AppButton(
              text: 'Register Company',
              icon: Icons.add_rounded,
              onPressed: _showRegisterDialog,
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // ➕ REGISTER DIALOG (Cubit Implemented)
  // ═══════════════════════════════════════
  Future<void> _showRegisterDialog() async {
    final Map<String, dynamic>? result = await CompanyRegisterDialog.show(context);

    if (result != null) {
      debugPrint('🔄 Starting company registration process...');
      debugPrint('📝 Registration data: $result');

      try {
        final AuthCubit authCubit = context.read<AuthCubit>();

        debugPrint('🚀 Calling AuthCubit.registerCompany()...');

        // 1. AuthCubit මඟින් Register කිරීම (API Call)
        final user = await authCubit.registerCompany(
          ownerName: result['ownerName'],
          ownerEmail: result['ownerEmail'],
          password: result['password'],
          ownerPhone: result['ownerPhone'],
          companyName: result['companyName'],
          companyAddress: result['companyAddress'],
          companyPhone: result['companyPhone'],
        );

        debugPrint('✅ Registration successful!');
        debugPrint('👤 Created user: ${user?.email}');
        debugPrint('🏢 Company: ${user?.companyName}');

        // 2. සාර්ථක නම්, CompanyCubit මඟින් list එක refresh කිරීම
        debugPrint('🔄 Refreshing company list...');
        final token = _getToken();
        await context.read<CompanyCubit>().loadCompanies(token: token);
        _showSuccessSnackBar('Company registered and user created successfully!');

        debugPrint('🎉 Company registration process completed successfully!');

      } catch (e) {
        // AuthCubit එකේ error එක catch කිරීම
        debugPrint('❌ Registration failed!');
        debugPrint('💥 Error details: $e');
        debugPrint('🔍 Error type: ${e.runtimeType}');
        debugPrint('📄 Error message: ${e.toString()}');

        // Show full error details in snackbar
        _showErrorSnackBar('Registration Failed: ${e.toString()}');
      }
    } else {
      debugPrint('⚠️ Registration cancelled - no data provided');
    }
  }

  // ═══════════════════════════════════════
  // ✏️ EDIT DIALOG (Cubit Implemented)
  // ═══════════════════════════════════════
  Future<void> _showEditDialog(CompanyModel company) async {
    final Map<String, dynamic>? result = await CompanyRegisterDialog.show(
      context,
      company: company,
    );

    if (result != null) {
      try {
        // යාවත්කාලීන කළ Model එක නිර්මාණය කිරීම
        final updatedCompany = CompanyModel.fromJson({
          ...company.toJson(), // Keep existing data (like ID)
          ...result, // Override with new data
          'id': company.id, // ID එක ආරක්ෂා කරගැනීම
        });

        // 1. CompanyCubit මඟින් Update කිරීම (API Call)
        final token = _getToken();
        await context.read<CompanyCubit>().updateCompany(updatedCompany, token: token);
        
        // 2. Local UI එකේ selected company එක update කිරීම
        if (_selectedCompany?.id == updatedCompany.id) {
          setState(() {
            _selectedCompany = updatedCompany;
          });
        }
        _showSuccessSnackBar('Company updated successfully!');

      } catch (e) {
        _showErrorSnackBar('Update Failed: ${e.toString().split(':').last}');
      }
    }
  }

  // ═══════════════════════════════════════
  // 🗑️ DELETE CONFIRMATION (Cubit Implemented)
  // ═══════════════════════════════════════
  Future<void> _showDeleteConfirmation(CompanyModel company) async {
    final bool? result = await ConfirmDialog.show(
      context: context,
      title: 'Delete Company',
      message:
          'Are you sure you want to delete "${company.companyName}"?\n\nThis action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_forever_rounded,
      isDanger: true,
    );

    if (result == true) {
      try {
        // 1. CompanyCubit මඟින් Delete කිරීම (API Call)
        final token = _getToken();
        await context.read<CompanyCubit>().deleteCompany(company.id, token: token);

        // 2. සාර්ථක නම්, selected company එක ඉවත් කිරීම
        if (_selectedCompany?.id == company.id) {
          setState(() {
            _selectedCompany = null;
          });
        }
        _showSuccessSnackBar('Company deleted successfully!');
      } catch (e) {
        _showErrorSnackBar('Deletion Failed: ${e.toString().split(':').last}');
      }
    }
  }

  // ═══════════════════════════════════════
  // 📄 DETAIL PANEL
  // ═══════════════════════════════════════
  Widget _buildDetailPanel() {
    // ... Detail Panel UI Logic (ඔබ කලින් දුන් කේතය) ...
    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.touch_app_rounded,
              size: 48,
              color: AppTheme.primaryAccent.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select a Company',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click on a company from the list\nto view details and setup options',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _buildQuickAction(
                  Icons.add_business_rounded,
                  'Register New Company',
                  _showRegisterDialog,
                ),
                const Divider(height: 24),
                _buildQuickAction(
                  Icons.search_rounded,
                  'Search Companies',
                  () {
                    // Search field එකට focus කරන්න
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // ═══════════════════════════════════════
  // 🔘 HELPER WIDGETS (ActionButton, QuickAction)
  // ═══════════════════════════════════════
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryAccent, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primaryAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // ✅ SNACKBARS
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
        backgroundColor: AppTheme.success,
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
            Flexible( // දෝෂ පණිවිඩය දිගු නම් එයට ඉඩ දීමට
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
        backgroundColor: AppTheme.error,
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
