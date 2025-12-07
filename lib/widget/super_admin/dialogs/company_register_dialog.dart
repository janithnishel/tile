// // lib/widgets/dialogs/company_register_dialog.dart

// import 'package:flutter/material.dart';
// import 'package:tilework/models/admin_panel/company_model.dart';
// import 'package:tilework/theme/theme.dart';
// import 'package:tilework/widget/admin_panel/app_button.dart';
// import 'package:tilework/widget/admin_panel/app_text_field.dart';
// import 'package:tilework/widget/admin_panel/section_header.dart';

// class CompanyRegisterDialog extends StatefulWidget {
//   final CompanyModel? company; // For edit mode

//   const CompanyRegisterDialog({Key? key, this.company}) : super(key: key);

//   static Future<CompanyModel?> show(BuildContext context, {CompanyModel? company}) {
//     return showDialog<CompanyModel>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => CompanyRegisterDialog(company: company),
//     );
//   }

//   @override
//   State<CompanyRegisterDialog> createState() => _CompanyRegisterDialogState();
// }

// class _CompanyRegisterDialogState extends State<CompanyRegisterDialog> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   // Owner Controllers
//   final _ownerNameController = TextEditingController();
//   final _ownerEmailController = TextEditingController();
//   final _ownerPhoneController = TextEditingController();

//   // Company Controllers
//   final _companyNameController = TextEditingController();
//   final _companyAddressController = TextEditingController();
//   final _companyPhoneController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     if (widget.company != null) {
//       _ownerNameController.text = widget.company!.ownerName;
//       _ownerEmailController.text = widget.company!.ownerEmail;
//       _ownerPhoneController.text = widget.company!.ownerPhone;
//       _companyNameController.text = widget.company!.companyName;
//       _companyAddressController.text = widget.company!.companyAddress;
//       _companyPhoneController.text = widget.company!.companyPhone;
//     }
//   }

//   @override
//   void dispose() {
//     _ownerNameController.dispose();
//     _ownerEmailController.dispose();
//     _ownerPhoneController.dispose();
//     _companyNameController.dispose();
//     _companyAddressController.dispose();
//     _companyPhoneController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.company != null;

//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(AppTheme.radiusLg),
//       ),
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 550, maxHeight: 700),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ═══════════════════════════════════════
//             // 🔝 HEADER
//             // ═══════════════════════════════════════
//             Container(
//               padding: const EdgeInsets.all(AppTheme.spacingLg),
//               decoration: BoxDecoration(
//                 gradient: AppTheme.buttonGradient,
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(AppTheme.radiusLg),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Icon(
//                       isEdit ? Icons.edit_rounded : Icons.add_business_rounded,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           isEdit ? 'Edit Company' : 'Register New Company',
//                           style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         Text(
//                           isEdit
//                               ? 'Update company details'
//                               : 'Add a new company to the system',
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.white.withOpacity(0.8),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.close, color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),

//             // ═══════════════════════════════════════
//             // 📝 FORM
//             // ═══════════════════════════════════════
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(AppTheme.spacingLg),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Owner Details Section
//                       const SectionHeader(
//                         title: 'Owner/Admin Details',
//                         subtitle: 'Primary contact information',
//                         icon: Icons.person_rounded,
//                       ),

//                       AppTextField(
//                         label: 'Name',
//                         hint: 'Enter owner name',
//                         controller: _ownerNameController,
//                         prefixIcon: Icons.person_outline_rounded,
//                         validator: (v) =>
//                             v?.isEmpty ?? true ? 'Name is required' : null,
//                       ),

//                       const SizedBox(height: 16),

//                       AppTextField(
//                         label: 'Email',
//                         hint: 'Enter email address',
//                         controller: _ownerEmailController,
//                         prefixIcon: Icons.email_outlined,
//                         keyboardType: TextInputType.emailAddress,
//                         validator: (v) {
//                           if (v?.isEmpty ?? true) return 'Email is required';
//                           if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                               .hasMatch(v!)) {
//                             return 'Enter valid email';
//                           }
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 16),

//                       AppTextField(
//                         label: 'Phone',
//                         hint: 'Enter phone number',
//                         controller: _ownerPhoneController,
//                         prefixIcon: Icons.phone_outlined,
//                         keyboardType: TextInputType.phone,
//                         validator: (v) =>
//                             v?.isEmpty ?? true ? 'Phone is required' : null,
//                       ),

//                       const SizedBox(height: 24),

//                       // Company Details Section
//                       const SectionHeader(
//                         title: 'Company Details',
//                         subtitle: 'Business information',
//                         icon: Icons.business_rounded,
//                       ),

//                       AppTextField(
//                         label: 'Company Name',
//                         hint: 'Enter company name',
//                         controller: _companyNameController,
//                         prefixIcon: Icons.store_rounded,
//                         validator: (v) => v?.isEmpty ?? true
//                             ? 'Company name is required'
//                             : null,
//                       ),

//                       const SizedBox(height: 16),

//                       AppTextField(
//                         label: 'Company Address',
//                         hint: 'Enter company address',
//                         controller: _companyAddressController,
//                         prefixIcon: Icons.location_on_outlined,
//                         maxLines: 2,
//                         validator: (v) =>
//                             v?.isEmpty ?? true ? 'Address is required' : null,
//                       ),

//                       const SizedBox(height: 16),

//                       AppTextField(
//                         label: 'Company Phone',
//                         hint: 'Enter company phone',
//                         controller: _companyPhoneController,
//                         prefixIcon: Icons.phone_rounded,
//                         keyboardType: TextInputType.phone,
//                         validator: (v) =>
//                             v?.isEmpty ?? true ? 'Phone is required' : null,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // ═══════════════════════════════════════
//             // 🔘 ACTIONS
//             // ═══════════════════════════════════════
//             Container(
//               padding: const EdgeInsets.all(AppTheme.spacingLg),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius: const BorderRadius.vertical(
//                   bottom: Radius.circular(AppTheme.radiusLg),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: AppButton(
//                       text: 'Cancel',
//                       type: AppButtonType.outlined,
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     flex: 2,
//                     child: AppButton(
//                       text: isEdit ? 'Update Company' : 'Register Company',
//                       icon: isEdit ? Icons.check_rounded : Icons.add_rounded,
//                       isLoading: _isLoading,
//                       onPressed: _handleSubmit,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _handleSubmit() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);

//       try {
//         await Future.delayed(const Duration(seconds: 1)); // Simulate API call

//         final company = CompanyModel(
//           id: widget.company?.id ?? DateTime.now().toString(),
//           companyName: _companyNameController.text.trim(),
//           companyAddress: _companyAddressController.text.trim(),
//           companyPhone: _companyPhoneController.text.trim(),
//           ownerName: _ownerNameController.text.trim(),
//           ownerEmail: _ownerEmailController.text.trim(),
//           ownerPhone: _ownerPhoneController.text.trim(),
//         );

//         Navigator.pop(context, company);
//       } catch (e) {
//         // Handle error
//       }

//       setState(() => _isLoading = false);
//     }
//   }
// }

// lib/widgets/dialogs/company_register_dialog.dart

import 'package:flutter/material.dart';
import 'package:tilework/models/super_admin/company_model.dart';
import 'package:tilework/theme/theme.dart';
import 'package:tilework/widget/super_admin/app_button.dart';
import 'package:tilework/widget/super_admin/app_text_field.dart';
import 'package:tilework/widget/super_admin/section_header.dart';

class CompanyRegisterDialog extends StatefulWidget {
  final CompanyModel? company; // For edit mode

  const CompanyRegisterDialog({Key? key, this.company}) : super(key: key);

  static Future<CompanyModel?> show(BuildContext context, {CompanyModel? company}) {
    return showDialog<CompanyModel>(
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

  // Owner Controllers
  late final TextEditingController _ownerNameController;
  late final TextEditingController _ownerEmailController;
  late final TextEditingController _ownerPhoneController;

  // Company Controllers
  late final TextEditingController _companyNameController;
  late final TextEditingController _companyAddressController;
  late final TextEditingController _companyPhoneController;

  // Status
  late bool _isActive;

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
                        colors: [Colors.orange.shade500, Colors.orange.shade700],
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
                      _isEditMode ? Icons.edit_rounded : Icons.add_business_rounded,
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
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(v!)) {
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
                      icon: _isEditMode ? Icons.check_rounded : Icons.add_rounded,
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
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call

        final company = CompanyModel(
          id: widget.company?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          companyName: _companyNameController.text.trim(),
          companyAddress: _companyAddressController.text.trim(),
          companyPhone: _companyPhoneController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          ownerEmail: _ownerEmailController.text.trim(),
          ownerPhone: _ownerPhoneController.text.trim(),
          isActive: _isActive,
          createdAt: widget.company?.createdAt ?? DateTime.now(),
        );

        Navigator.pop(context, company);
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
}