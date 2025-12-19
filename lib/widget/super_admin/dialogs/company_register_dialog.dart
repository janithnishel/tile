import 'package:flutter/material.dart';
import 'package:tilework/models/category_model.dart';
import 'package:tilework/models/company_model.dart';
import 'package:tilework/theme/theme.dart';
import 'package:tilework/widget/super_admin/app_button.dart';
import 'package:tilework/widget/super_admin/app_text_field.dart';
import 'package:tilework/widget/super_admin/section_header.dart';

class CompanyRegisterDialog extends StatefulWidget {
  final CompanyModel? company; // For edit mode

  const CompanyRegisterDialog({Key? key, this.company}) : super(key: key);

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    CompanyModel? company,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompanyRegisterDialog(company: company),
    );
  }

  @override
  State<CompanyRegisterDialog> createState() => _CompanyRegisterDialogState();
}

class _CompanyRegisterDialogState extends State<CompanyRegisterDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Owner Controllers
  late final TextEditingController _ownerNameController;
  late final TextEditingController _ownerEmailController;
  late final TextEditingController _ownerPhoneController;
  late final TextEditingController _ownerPasswordController;
  late final TextEditingController _ownerConfirmPasswordController;

  // Company Controllers
  late final TextEditingController _companyNameController;
  late final TextEditingController _companyAddressController;
  late final TextEditingController _companyPhoneController;

  // Status
  late bool _isActive;

  // Categories for new company registration
  List<Map<String, dynamic>> _initialCategories = [];

  bool get _isEditMode => widget.company != null;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if edit mode
    _ownerNameController = TextEditingController(
      text: widget.company?.ownerName ?? '',
    );
    _ownerEmailController = TextEditingController(
      text: widget.company?.ownerEmail ?? '',
    );
    _ownerPhoneController = TextEditingController(
      text: widget.company?.ownerPhone ?? '',
    );
    _ownerPasswordController = TextEditingController();
    _ownerConfirmPasswordController = TextEditingController();
    _companyNameController = TextEditingController(
      text: widget.company?.companyName ?? '',
    );
    _companyAddressController = TextEditingController(
      text: widget.company?.companyAddress ?? '',
    );
    _companyPhoneController = TextEditingController(
      text: widget.company?.companyPhone ?? '',
    );
    _isActive = widget.company?.isActive ?? true;
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPhoneController.dispose();
    _ownerPasswordController.dispose();
    _ownerConfirmPasswordController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 750),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ═══════════════════════════════════════
            // 🔝 HEADER
            // ═══════════════════════════════════════
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: _isEditMode
                    ? LinearGradient(
                        colors: [
                          Colors.orange.shade500,
                          Colors.orange.shade700,
                        ],
                      )
                    : AppTheme.buttonGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusLg),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isEditMode
                          ? Icons.edit_rounded
                          : Icons.add_business_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditMode ? 'Edit Company' : 'Register New Company',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _isEditMode
                              ? 'Update company information'
                              : 'Add a new company to the system',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // 📝 FORM
            // ═══════════════════════════════════════
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Owner Details Section
                      const SectionHeader(
                        title: 'Owner/Admin Details',
                        subtitle: 'Primary contact information',
                        icon: Icons.person_rounded,
                      ),

                      AppTextField(
                        label: 'Name',
                        hint: 'Enter owner name',
                        controller: _ownerNameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Name is required' : null,
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Email',
                        hint: 'Enter email address',
                        controller: _ownerEmailController,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Email is required';
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(v!)) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Phone',
                        hint: 'Enter phone number',
                        controller: _ownerPhoneController,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Phone is required' : null,
                      ),

                      const SizedBox(height: 16),

                      // Password Field with visibility toggle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextFormField(
                              controller: _ownerPasswordController,
                              obscureText: !_isPasswordVisible,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter password for account',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.normal,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.lock_outline,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey.shade500,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                              ),
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Password is required';
                                if (v!.length < 6) return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confirm Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextFormField(
                              controller: _ownerConfirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Re-enter password to confirm',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.normal,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.lock_reset,
                                    color: Colors.green.shade600,
                                    size: 20,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey.shade500,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                              ),
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Confirm password is required';
                                if (v != _ownerPasswordController.text) return 'Passwords do not match';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Company Details Section
                      const SectionHeader(
                        title: 'Company Details',
                        subtitle: 'Business information',
                        icon: Icons.business_rounded,
                      ),

                      AppTextField(
                        label: 'Company Name',
                        hint: 'Enter company name',
                        controller: _companyNameController,
                        prefixIcon: Icons.store_rounded,
                        validator: (v) => v?.isEmpty ?? true
                            ? 'Company name is required'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Company Address',
                        hint: 'Enter company address',
                        controller: _companyAddressController,
                        prefixIcon: Icons.location_on_outlined,
                        maxLines: 2,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Address is required' : null,
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Company Phone',
                        hint: 'Enter company phone',
                        controller: _companyPhoneController,
                        prefixIcon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Phone is required' : null,
                      ),

                      // ═══════════════════════════════════════
                      // 🔄 STATUS TOGGLE (Edit Mode Only)
                      // ═══════════════════════════════════════
                      if (_isEditMode) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isActive
                                ? AppTheme.success.withOpacity(0.1)
                                : AppTheme.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isActive
                                  ? AppTheme.success.withOpacity(0.3)
                                  : AppTheme.warning.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isActive
                                    ? Icons.check_circle_rounded
                                    : Icons.pause_circle_rounded,
                                color: _isActive
                                    ? AppTheme.success
                                    : AppTheme.warning,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Company Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _isActive
                                          ? 'Company is currently active'
                                          : 'Company is currently inactive',
                                      style: AppTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() {
                                    _isActive = value;
                                  });
                                },
                                activeColor: AppTheme.success,
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ═══════════════════════════════════════
                      // 📦 INITIAL CATEGORIES (New Company Registration Only)
                      // ═══════════════════════════════════════
                      if (!_isEditMode) ...[
                        const SizedBox(height: 24),
                        const SectionHeader(
                          title: 'Initial Categories',
                          subtitle: 'Setup product categories for this company',
                          icon: Icons.category_rounded,
                        ),

                        // Add Category Button
                        AppButton(
                          text: 'Add Category',
                          icon: Icons.add_rounded,
                          type: AppButtonType.secondary,
                          onPressed: _showAddCategoryDialog,
                        ),

                        const SizedBox(height: 16),

                        // Categories List
                        if (_initialCategories.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.category_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No categories added yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Click "Add Category" to get started',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._initialCategories.map((category) => _buildCategoryTile(category)),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ═══════════════════════════════════════
            // 🔘 ACTIONS
            // ═══════════════════════════════════════
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppTheme.radiusLg),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      type: AppButtonType.outlined,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: _isEditMode ? 'Update Company' : 'Register Company',
                      icon: _isEditMode
                          ? Icons.check_rounded
                          : Icons.add_rounded,
                      isLoading: _isLoading,
                      onPressed: _handleSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (_isEditMode) {
          // Return the updated company data as JSON
          final updatedCompany = CompanyModel(
            id: widget.company!.id,
            companyName: _companyNameController.text.trim(),
            companyAddress: _companyAddressController.text.trim(),
            companyPhone: _companyPhoneController.text.trim(),
            ownerName: _ownerNameController.text.trim(),
            ownerEmail: _ownerEmailController.text.trim(),
            ownerPhone: _ownerPhoneController.text.trim(),
            isActive: _isActive,
          );
          Navigator.pop(context, updatedCompany.toJson());
        } else {
          // Return the registration data as a map
          Navigator.pop(context, {
            'ownerName': _ownerNameController.text.trim(),
            'ownerEmail': _ownerEmailController.text.trim(),
            'ownerPhone': _ownerPhoneController.text.trim(),
            'password': _ownerPasswordController.text.trim(),
            'companyName': _companyNameController.text.trim(),
            'companyAddress': _companyAddressController.text.trim(),
            'companyPhone': _companyPhoneController.text.trim(),
            'initialCategories': _initialCategories,
          });
        }
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  // ═══════════════════════════════════════
  // ➕ ADD CATEGORY DIALOG
  // ═══════════════════════════════════════
  Future<void> _showAddCategoryDialog() async {
    final categoryNameController = TextEditingController();
    final categoryFormKey = GlobalKey<FormState>();
    bool isCategoryLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (categoryDialogContext) => StatefulBuilder(
        builder: (categoryDialogContext, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: categoryFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Add Category', style: AppTheme.heading3),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Category Name',
                    hint: 'Enter category name',
                    controller: categoryNameController,
                    prefixIcon: Icons.category_outlined,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Category name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancel',
                          type: AppButtonType.outlined,
                          onPressed: () => Navigator.pop(categoryDialogContext),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Add',
                          icon: Icons.add_rounded,
                          isLoading: isCategoryLoading,
                          onPressed: () async {
                            if (categoryFormKey.currentState!.validate()) {
                              setState(() => isCategoryLoading = true);
                              try {
                                // Add category to the list
                                final newCategory = {
                                  'name': categoryNameController.text.trim(),
                                  'items': <Map<String, dynamic>>[],
                                };
                                this.setState(() {
                                  _initialCategories.add(newCategory);
                                });
                                Navigator.pop(categoryDialogContext);
                              } catch (e) {
                                // Handle error
                              }
                              setState(() => isCategoryLoading = false);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // 📦 CATEGORY TILE
  // ═══════════════════════════════════════
  Widget _buildCategoryTile(Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.category_rounded,
              color: AppTheme.primaryAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Will be created for this company',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _initialCategories.remove(category);
              });
            },
            icon: const Icon(Icons.delete_outline),
            color: AppTheme.error,
          ),
        ],
      ),
    );
  }
}
