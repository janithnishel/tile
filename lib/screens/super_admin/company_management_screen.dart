import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/super_admin/category/category_cubit.dart';
import 'package:tilework/cubits/super_admin/company/company_cubit.dart';
import 'package:tilework/cubits/super_admin/company/company_state.dart';
import 'package:tilework/models/company_model.dart';
import 'package:tilework/theme/theme.dart';
import 'package:tilework/widget/super_admin/app_button.dart';
import 'package:tilework/widget/super_admin/app_card.dart';
import 'package:tilework/widget/super_admin/dialogs/company_register_dialog.dart';
import 'package:tilework/widget/super_admin/dialogs/confirm_dialog.dart';
import 'company_setup_screen.dart'; // Setup screen එකේ path එක නිවැරදි කරගන්න

class CompanyManagementScreen extends StatefulWidget {
  const CompanyManagementScreen({Key? key}) : super(key: key);

  @override
  State<CompanyManagementScreen> createState() =>
      _CompanyManagementScreenState();
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
        if (state.errorMessage != null && !state.isLoading && mounted) {
          _showErrorSnackBar(state.errorMessage!);
        }
      },
      builder: (context, state) {
        final List<CompanyModel> companies = state.companies;
        final List<CompanyModel> filteredCompanies = _getFilteredCompanies(
          companies,
        );

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
                            : _buildListBody(
                                filteredCompanies,
                                state.isLoading,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Detail Panel
              Expanded(flex: 3, child: _buildDetailPanel()),
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
        border: Border(bottom: BorderSide(color: AppTheme.border)),
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
                    isLoading && companyCount == 0
                        ? 'Loading companies...'
                        : '${companyCount} total companies',
                    style: AppTheme.bodyMedium.copyWith(
                      color: isLoading
                          ? AppTheme.warning
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AppButton(
                text: 'Register New',
                icon: Icons.add_rounded,
                onPressed: isLoading
                    ? null
                    : _showRegisterDialog, // Loading නම් Disable කරයි
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
                    Text(company.ownerName, style: AppTheme.bodyMedium),
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
                    color: company.isActive
                        ? AppTheme.success
                        : AppTheme.warning,
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

          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
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
            isSearching ? Icons.search_off_rounded : Icons.business_outlined,
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
            style: TextStyle(color: Colors.grey.shade500),
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
    final Map<String, dynamic>? result = await CompanyRegisterDialog.show(
      context,
    );

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

        // 2. Create initial categories if provided
        final initialCategories = result['initialCategories'] as List<dynamic>?;
        if (initialCategories != null && initialCategories.isNotEmpty) {
          debugPrint(
            '📦 Creating ${initialCategories.length} initial categories...',
          );

          final token = _getToken();
          final categoryCubit = context.read<CategoryCubit>();

          for (final categoryData in initialCategories) {
            try {
              await categoryCubit.createCategory(
                categoryData['name'],
                token: token,
                companyId: user!.id, // Use the newly created company's ID
              );
              debugPrint('✅ Created category: ${categoryData['name']}');
            } catch (categoryError) {
              debugPrint(
                '❌ Failed to create category ${categoryData['name']}: $categoryError',
              );
              // Continue with other categories even if one fails
            }
          }
        }

        // 3. සාර්ථක නම්, CompanyCubit මඟින් list එක refresh කිරීම
        debugPrint('🔄 Refreshing company list...');
        final token = _getToken();
        await context.read<CompanyCubit>().loadCompanies(token: token);

        if (mounted) {
          final successMessage =
              initialCategories != null && initialCategories.isNotEmpty
              ? 'Company registered with ${initialCategories.length} categories successfully!'
              : 'Company registered and user created successfully!';

          _showSuccessSnackBar(successMessage);
        }

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
        await context.read<CompanyCubit>().updateCompany(
          updatedCompany,
          token: token,
        );

        // 2. Local UI එකේ selected company එක update කිරීම
        if (mounted && _selectedCompany?.id == updatedCompany.id) {
          setState(() {
            _selectedCompany = updatedCompany;
          });
        }
        if (mounted) {
          _showSuccessSnackBar('Company updated successfully!');
        }
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
        await context.read<CompanyCubit>().deleteCompany(
          company.id,
          token: token,
        );

        // 2. සාර්ථක නම්, selected company එක ඉවත් කිරීම
        if (mounted && _selectedCompany?.id == company.id) {
          setState(() {
            _selectedCompany = null;
          });
        }
        if (mounted) {
          _showSuccessSnackBar('Company deleted successfully!');
        }
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
            style: TextStyle(color: Colors.grey.shade500, height: 1.5),
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
                _buildQuickAction(Icons.search_rounded, 'Search Companies', () {
                  // Search field එකට focus කරන්න
                }),
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
            child: Icon(icon, color: color, size: 18),
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
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              // දෝෂ පණිවිඩය දිගු නම් එයට ඉඩ දීමට
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
