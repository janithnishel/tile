import 'package:flutter/material.dart';

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Company Profile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _companyNameController = TextEditingController(text: 'ABC Construction Pvt Ltd');
  final _addressLine1Controller = TextEditingController(text: '123 Main Street');
  final _addressLine2Controller = TextEditingController(text: 'Colombo 03');
  final _cityController = TextEditingController(text: 'Colombo');
  final _postalCodeController = TextEditingController(text: '00300');
  final _phoneController = TextEditingController(text: '+94 77 123 4567');
  final _emailController = TextEditingController(text: 'info@abcconstruction.lk');
  final _websiteController = TextEditingController(text: 'www.abcconstruction.lk');
  final _registrationNumberController = TextEditingController(text: 'PV12345');
  final _taxIdController = TextEditingController(text: 'TIN-123456789');

  bool _isEditing = false;
  String? _logoPath;

  @override
  void dispose() {
    _companyNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _registrationNumberController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  void _uploadLogo() {
    // Simulate logo upload
    setState(() {
      _logoPath = 'assets/company_logo.png';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logo uploaded successfully!')),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Company Profile',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!_isEditing)
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Profile Content
                  Center(
                    child: SizedBox(
                      width: 800,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo Section
                            Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Company Logo',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(
                                          color: Colors.blue.shade300,
                                          width: 4,
                                        ),
                                      ),
                                      child: _logoPath != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(100),
                                              child: const Icon(
                                                Icons.business,
                                                size: 100,
                                                color: Colors.blue,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.business,
                                              size: 100,
                                              color: Colors.grey,
                                            ),
                                    ),
                                    const SizedBox(height: 24),
                                    if (_isEditing)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: _uploadLogo,
                                            icon: const Icon(Icons.upload),
                                            label: const Text('Upload Logo'),
                                          ),
                                          const SizedBox(width: 16),
                                          if (_logoPath != null)
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  _logoPath = null;
                                                });
                                              },
                                              icon: const Icon(Icons.delete),
                                              label: const Text('Remove'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Company Details Card
                            Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Company Details',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildTextField(
                                      controller: _companyNameController,
                                      label: 'Company Name',
                                      icon: Icons.business,
                                      enabled: _isEditing,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _addressLine1Controller,
                                      label: 'Address Line 1',
                                      icon: Icons.location_on,
                                      enabled: _isEditing,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _addressLine2Controller,
                                      label: 'Address Line 2',
                                      icon: Icons.location_on,
                                      enabled: _isEditing,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildTextField(
                                            controller: _cityController,
                                            label: 'City',
                                            icon: Icons.location_city,
                                            enabled: _isEditing,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildTextField(
                                            controller: _postalCodeController,
                                            label: 'Postal Code',
                                            icon: Icons.pin_drop,
                                            enabled: _isEditing,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Contact Information Card
                            Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Contact Information',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildTextField(
                                      controller: _phoneController,
                                      label: 'Phone Number',
                                      icon: Icons.phone,
                                      enabled: _isEditing,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _emailController,
                                      label: 'Email Address',
                                      icon: Icons.email,
                                      enabled: _isEditing,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _websiteController,
                                      label: 'Website',
                                      icon: Icons.language,
                                      enabled: _isEditing,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Registration Details Card
                            Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Registration Details',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildTextField(
                                      controller: _registrationNumberController,
                                      label: 'Company Registration Number',
                                      icon: Icons.numbers,
                                      enabled: _isEditing,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _taxIdController,
                                      label: 'Tax Identification Number',
                                      icon: Icons.receipt_long,
                                      enabled: _isEditing,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Action Buttons
                            if (_isEditing)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isEditing = false;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 48,
                                        vertical: 20,
                                      ),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton.icon(
                                    onPressed: _saveProfile,
                                    icon: const Icon(Icons.save),
                                    label: const Text('Save Changes'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 48,
                                        vertical: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Email Address') {
          if (!value.contains('@')) {
            return 'Please enter a valid email';
          }
        }
        return null;
      },
    );
  }
}