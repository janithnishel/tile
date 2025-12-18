// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tilework/cubits/auth/auth_cubit.dart';
// import 'package:tilework/cubits/auth/auth_state.dart';
// import 'package:tilework/cubits/super_admin/category/category_cubit.dart';
// import 'package:tilework/models/category_model.dart';
// import 'package:tilework/models/purchase_order/supplier.dart';

// class AddSupplierDialog extends StatefulWidget {
//   final Function(Supplier) onAdd;

//   const AddSupplierDialog({
//     Key? key,
//     required this.onAdd,
//   }) : super(key: key);

//   @override
//   State<AddSupplierDialog> createState() => _AddSupplierDialogState();
// }

// class _AddSupplierDialogState extends State<AddSupplierDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _addressController = TextEditingController();
//   List<String> _selectedCategories = [];

//   List<String> _availableCategories = [];
//   bool _isLoadingCategories = true;

//   late AuthCubit _authCubit;
//   late CategoryCubit _categoryCubit;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Load categories safely when context is available
//     if (_isLoadingCategories) {
//       _loadCategories();
//     }
//   }

//   Future<void> _loadCategories() async {
//     try {
//       final authState = context.read<AuthCubit>().state;
//       if (authState is AuthAuthenticated) {
//         final categoryCubit = context.read<CategoryCubit>();
//         await categoryCubit.loadCategories(token: authState.token);

//         // 🚨 Check if widget is still mounted before using context
//         if (!mounted) return;

//         // Update categories list
//         setState(() {
//           _availableCategories = categoryCubit.state.categories.map((cat) => cat.name).toList();
//           _isLoadingCategories = false;
//           // Set default category if available and not already selected
//           if (_availableCategories.isNotEmpty && _selectedCategories.isEmpty) {
//             _selectedCategories = [_availableCategories.first];
//           }
//         });
//       }
//     } catch (e) {
//       // 🚨 Check if widget is still mounted before using context
//       if (!mounted) return;

//       // On error, use default categories
//       setState(() {
//         _availableCategories = [
//           'Hardware',
//           'Cement & Sand',
//           'Tiles & Flooring',
//           'Steel & Metal',
//           'Paints',
//           'Electrical',
//           'Plumbing',
//           'Tools & Equipment',
//         ];
//         _isLoadingCategories = false;
//         // Set default category if available and not already selected
//         if (_availableCategories.isNotEmpty && _selectedCategories.isEmpty) {
//           _selectedCategories = [_availableCategories.first];
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   String _generateSupplierId(List<Supplier> existingSuppliers) {
//     if (existingSuppliers.isEmpty) return 'SUP001';

//     final ids = existingSuppliers.map((s) => s.id).toList();
//     ids.sort();

//     final lastId = ids.last;
//     final number = int.tryParse(lastId.substring(3)) ?? 0;
//     final nextNumber = number + 1;

//     return 'SUP${nextNumber.toString().padLeft(3, '0')}';
//   }

//   void _submit() {
//     if (_formKey.currentState!.validate()) {
//       // For now, we'll pass an empty list and generate ID in the parent
//       // In a real app, this would be handled by a service/repository
//       final newSupplier = Supplier(
//         id: '', // Will be set by parent
//         name: _nameController.text.trim(),
//         phone: _phoneController.text.trim(),
//         email: _emailController.text.trim(),
//         address: _addressController.text.trim(),
//         categories: _selectedCategories,
//       );

//       widget.onAdd(newSupplier);
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Add New Supplier'),
//         backgroundColor: Colors.teal,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(child: _buildContent()),
//           _buildFooter(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.teal.shade600, Colors.teal.shade800],
//         ),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.business,
//             color: Colors.white,
//             size: 28,
//           ),
//           const SizedBox(width: 12),
//           const Text(
//             'Add New Supplier',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const Spacer(),
//           IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(Icons.close, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Name Field
//             TextFormField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Supplier Name *',
//                 prefixIcon: const Icon(Icons.business),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               validator: (value) {
//                 if (value == null || value.trim().isEmpty) {
//                   return 'Supplier name is required';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),

//             // Phone Field
//             TextFormField(
//               controller: _phoneController,
//               decoration: InputDecoration(
//                 labelText: 'Phone Number *',
//                 prefixIcon: const Icon(Icons.phone),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               keyboardType: TextInputType.phone,
//               validator: (value) {
//                 if (value == null || value.trim().isEmpty) {
//                   return 'Phone number is required';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),

//             // Email Field
//             TextFormField(
//               controller: _emailController,
//               decoration: InputDecoration(
//                 labelText: 'Email Address',
//                 prefixIcon: const Icon(Icons.email),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 16),

//             // Address Field
//             TextFormField(
//               controller: _addressController,
//               decoration: InputDecoration(
//                 labelText: 'Address',
//                 prefixIcon: const Icon(Icons.location_on),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               maxLines: 2,
//             ),
//             const SizedBox(height: 16),

//             // Categories Multi-Select
//             if (_isLoadingCategories)
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 child: const Row(
//                   children: [
//                     SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                     SizedBox(width: 12),
//                     Text('Loading categories...'),
//                   ],
//                 ),
//               )
//             else
//               FormField<List<String>>(
//                 initialValue: _selectedCategories,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select at least one category';
//                   }
//                   return null;
//                 },
//                 builder: (FormFieldState<List<String>> state) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Categories *',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: _availableCategories.map((category) {
//                           final isSelected = _selectedCategories.contains(category);
//                           return FilterChip(
//                             label: Text(category),
//                             selected: isSelected,
//                             onSelected: (selected) {
//                               setState(() {
//                                 if (selected) {
//                                   _selectedCategories.add(category);
//                                 } else {
//                                   _selectedCategories.remove(category);
//                                 }
//                               });
//                               state.didChange(_selectedCategories);
//                             },
//                             backgroundColor: Colors.grey.shade100,
//                             selectedColor: Colors.teal.shade100,
//                             checkmarkColor: Colors.teal,
//                           );
//                         }).toList(),
//                       ),
//                       if (state.hasError)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8),
//                           child: Text(
//                             state.errorText!,
//                             style: TextStyle(
//                               color: Theme.of(context).colorScheme.error,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                     ],
//                   );
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFooter() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           const SizedBox(width: 12),
//           ElevatedButton.icon(
//             onPressed: _submit,
//             icon: const Icon(Icons.add),
//             label: const Text('Add Supplier'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.teal,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 24,
//                 vertical: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/cubits/auth/auth_cubit.dart';
import 'package:tilework/cubits/auth/auth_state.dart';
import 'package:tilework/cubits/super_admin/category/category_cubit.dart';
import 'package:tilework/models/purchase_order/supplier.dart';

class AddSupplierScreen extends StatefulWidget {
  final Function(Supplier) onAdd;

  const AddSupplierScreen({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  
  List<String> _selectedCategories = [];
  List<String> _availableCategories = [];
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Focus nodes for better UX
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _addressFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoadingCategories) {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final categoryCubit = context.read<CategoryCubit>();
        await categoryCubit.loadCategories(token: authState.token);

        if (!mounted) return;

        // Use only API-loaded categories
        final apiCategories = categoryCubit.state.categories
            .map((cat) => cat.name)
            .toList();

        setState(() {
          _availableCategories = apiCategories;
          _isLoadingCategories = false;
        });
      } else {
        // If not authenticated, show empty categories
        setState(() {
          _availableCategories = [];
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      // On error, show empty categories
      setState(() {
        _availableCategories = [];
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select at least one category'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final newSupplier = Supplier(
        id: '',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        categories: _selectedCategories,
      );

      widget.onAdd(newSupplier);
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildForm(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: Colors.teal,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.teal.shade400,
                Colors.teal.shade600,
                Colors.teal.shade800,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Supplier',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Enter supplier details below',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
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

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Basic Information Card
            _buildCard(
              title: 'Basic Information',
              icon: Icons.info_outline,
              children: [
                _buildTextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  label: 'Supplier Name',
                  hint: 'Enter supplier name',
                  icon: Icons.business,
                  required: true,
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => _phoneFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  label: 'Phone Number',
                  hint: 'Enter phone number',
                  icon: Icons.phone,
                  required: true,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                  ],
                  onSubmitted: (_) => _emailFocus.requestFocus(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Contact Information Card
            _buildCard(
              title: 'Contact Information',
              icon: Icons.contact_mail_outlined,
              children: [
                _buildTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  label: 'Email Address',
                  hint: 'supplier@example.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) => _addressFocus.requestFocus(),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  focusNode: _addressFocus,
                  label: 'Address',
                  hint: 'Enter supplier address',
                  icon: Icons.location_on,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Categories Card
            _buildCard(
              title: 'Categories',
              icon: Icons.category_outlined,
              children: [
                if (_isLoadingCategories)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.teal,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Loading categories...'),
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select the categories this supplier provides *',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _availableCategories.map((category) {
                          final isSelected = _selectedCategories.contains(category);
                          return _buildCategoryChip(category, isSelected);
                        }).toList(),
                      ),
                      if (_selectedCategories.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.teal.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.teal.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${_selectedCategories.length} categor${_selectedCategories.length > 1 ? 'ies' : 'y'} selected',
                                style: TextStyle(
                                  color: Colors.teal.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
            
            // Add some bottom padding for scrolling
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.teal.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.teal, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator ?? (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedCategories.remove(category);
              } else {
                _selectedCategories.add(category);
              }
            });
          },
          borderRadius: BorderRadius.circular(25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? Colors.teal : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Preview
          if (_nameController.text.isNotEmpty)
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade300, Colors.teal.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(_nameController.text),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _nameController.text,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _selectedCategories.isEmpty 
                              ? 'No categories' 
                              : _selectedCategories.join(', '),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            const Spacer(),
          
          const SizedBox(width: 16),
          
          // Cancel Button
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          
          const SizedBox(width: 12),
          
          // Submit Button
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(_isSubmitting ? 'Adding...' : 'Add Supplier'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
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

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
