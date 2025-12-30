// Create Site Visit Screen
// lib/screens/create_site_visit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/site_visits/site_visit_model.dart';
import '../../models/site_visits/inspection_model.dart';

class CreateSiteVisitScreen extends StatefulWidget {
  final SiteVisitModel? editVisit;
  final Function(SiteVisitModel) onSave;

  const CreateSiteVisitScreen({
    super.key,
    this.editVisit,
    required this.onSave,
  });

  @override
  State<CreateSiteVisitScreen> createState() => _CreateSiteVisitScreenState();
}

class _CreateSiteVisitScreenState extends State<CreateSiteVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers
  late TextEditingController _customerNameController;
  late TextEditingController _projectTitleController;
  late TextEditingController _contactNoController;
  late TextEditingController _locationController;
  late TextEditingController _colorCodeController;
  late TextEditingController _thicknessController;
  late TextEditingController _chargeController;
  late TextEditingController _otherDetailsController;

  // Inspection Controllers
  late TextEditingController _skirtingController;
  late TextEditingController _floorPrepController;
  late TextEditingController _groundSettingController;
  late TextEditingController _doorController;
  late TextEditingController _windowController;
  late TextEditingController _evenUnevenController;
  late TextEditingController _areaConditionController;

  // Form State
  String _siteType = 'Residential';
  Map<String, bool> _floorConditions = {
    'Cement': false,
    'Tile': false,
    'Terrazzo': false,
    'Titanium': false,
    'Concrete': false,
    'Wood': false,
    'Other': false,
  };
  Map<String, bool> _targetAreas = {
    'Living': false,
    'Hall': false,
    'Room': false,
    'Dinning': false,
    'Passage': false,
    'Kitchen': false,
    'Other': false,
  };

  bool get _isEditing => widget.editVisit != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (_isEditing) {
      _loadEditData();
    }
  }

  void _initializeControllers() {
    _customerNameController = TextEditingController();
    _projectTitleController = TextEditingController();
    _contactNoController = TextEditingController();
    _locationController = TextEditingController();
    _colorCodeController = TextEditingController();
    _thicknessController = TextEditingController();
    _chargeController = TextEditingController();
    _otherDetailsController = TextEditingController();
    _skirtingController = TextEditingController();
    _floorPrepController = TextEditingController();
    _groundSettingController = TextEditingController();
    _doorController = TextEditingController();
    _windowController = TextEditingController();
    _evenUnevenController = TextEditingController();
    _areaConditionController = TextEditingController();
  }

  void _loadEditData() {
    final visit = widget.editVisit!;
    _customerNameController.text = visit.customerName;
    _projectTitleController.text = visit.projectTitle;
    _contactNoController.text = visit.contactNo;
    _locationController.text = visit.location;
    _colorCodeController.text = visit.colorCode;
    _thicknessController.text = visit.thickness;
    _chargeController.text = visit.charge.toString();
    _otherDetailsController.text = visit.otherDetails ?? '';
    _siteType = visit.siteType;

    // Floor Conditions
    for (var condition in visit.floorCondition) {
      if (_floorConditions.containsKey(condition)) {
        _floorConditions[condition] = true;
      }
    }

    // Target Areas
    for (var area in visit.targetArea) {
      if (_targetAreas.containsKey(area)) {
        _targetAreas[area] = true;
      }
    }

    // Inspection
    _skirtingController.text = visit.inspection.skirting;
    _floorPrepController.text = visit.inspection.floorPreparation;
    _groundSettingController.text = visit.inspection.groundSetting;
    _doorController.text = visit.inspection.door;
    _windowController.text = visit.inspection.window;
    _evenUnevenController.text = visit.inspection.evenUneven;
    _areaConditionController.text = visit.inspection.areaCondition;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _projectTitleController.dispose();
    _contactNoController.dispose();
    _locationController.dispose();
    _colorCodeController.dispose();
    _thicknessController.dispose();
    _chargeController.dispose();
    _otherDetailsController.dispose();
    _skirtingController.dispose();
    _floorPrepController.dispose();
    _groundSettingController.dispose();
    _doorController.dispose();
    _windowController.dispose();
    _evenUnevenController.dispose();
    _areaConditionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _saveVisit() {
    if (_formKey.currentState!.validate()) {
      final selectedFloorConditions = _floorConditions.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      final selectedTargetAreas = _targetAreas.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      final inspection = InspectionModel(
        skirting: _skirtingController.text,
        floorPreparation: _floorPrepController.text,
        groundSetting: _groundSettingController.text,
        door: _doorController.text,
        window: _windowController.text,
        evenUneven: _evenUnevenController.text,
        areaCondition: _areaConditionController.text,
      );

      final visit = SiteVisitModel(
        id: _isEditing
            ? widget.editVisit!.id
            : 'SV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        customerName: _customerNameController.text.trim(),
        projectTitle: _projectTitleController.text.trim(),
        contactNo: _contactNoController.text.trim(),
        location: _locationController.text.trim(),
        date: _isEditing ? widget.editVisit!.date : DateTime.now(),
        siteType: _siteType,
        charge: double.tryParse(_chargeController.text) ?? 0,
        status: _isEditing ? widget.editVisit!.status : SiteVisitStatus.pending,
        colorCode: _colorCodeController.text.trim(),
        thickness: _thicknessController.text.trim(),
        floorCondition: selectedFloorConditions,
        targetArea: selectedTargetAreas,
        inspection: inspection,
        otherDetails: _otherDetailsController.text.trim(),
      );

      widget.onSave(visit);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Site visit updated successfully!'
              : 'Site visit created successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildCustomerDetailsSection(),
                      const SizedBox(height: 16),
                      _buildFloorConditionSection(),
                      const SizedBox(height: 16),
                      _buildTargetAreaSection(),
                      const SizedBox(height: 16),
                      _buildInspectionSection(),
                      const SizedBox(height: 16),
                      _buildOtherDetailsSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Save Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: FloatingActionButton.extended(
          onPressed: _saveVisit,
          backgroundColor: Colors.purple.shade700,
          icon: Icon(_isEditing ? Icons.save : Icons.check_circle,color: Colors.green,),
          label: Text(
            _isEditing ? 'Update Site Visit' : 'Save & Generate Invoice',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade700],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Site Visit' : 'Create New Site Visit',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isEditing
                      ? 'Update inspection details'
                      : 'Complete inspection & generate invoice',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsSection() {
    return _buildSection(
      title: 'Customer & Site Details',
      color: Colors.purple,
      icon: Icons.person,
      child: Column(
        children: [
          _buildTextField(
            controller: _customerNameController,
            label: 'Customer Name',
            icon: Icons.person_outline,
            required: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _projectTitleController,
            label: 'Project Title',
            icon: Icons.work_outline,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _contactNoController,
            label: 'Contact Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            required: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _locationController,
            label: 'Site Location',
            icon: Icons.location_on_outlined,
            required: true,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Site Type',
                  value: _siteType,
                  items: ['Residential', 'Commercial', 'Industrial'],
                  onChanged: (value) => setState(() => _siteType = value!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _colorCodeController,
                  label: 'Color Code',
                  icon: Icons.color_lens_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _thicknessController,
                  label: 'Thickness (e.g., 8mm)',
                  icon: Icons.straighten,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _chargeController,
                  label: 'Site Visit Charge (Rs)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  required: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloorConditionSection() {
    return _buildSection(
      title: 'Floor Condition',
      color: Colors.blue,
      icon: Icons.layers,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _floorConditions.keys.map((condition) {
          final isSelected = _floorConditions[condition]!;
          return FilterChip(
            label: Text(condition),
            selected: isSelected,
            onSelected: (selected) {
              setState(() => _floorConditions[condition] = selected);
            },
            selectedColor: Colors.blue.shade100,
            checkmarkColor: Colors.blue.shade700,
            labelStyle: TextStyle(
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTargetAreaSection() {
    return _buildSection(
      title: 'Target Area',
      color: Colors.green,
      icon: Icons.home,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _targetAreas.keys.map((area) {
          final isSelected = _targetAreas[area]!;
          return FilterChip(
            label: Text(area),
            selected: isSelected,
            onSelected: (selected) {
              setState(() => _targetAreas[area] = selected);
            },
            selectedColor: Colors.green.shade100,
            checkmarkColor: Colors.green.shade700,
            labelStyle: TextStyle(
              color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color:
                    isSelected ? Colors.green.shade300 : Colors.grey.shade300,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInspectionSection() {
    return _buildSection(
      title: 'Technical Inspection',
      color: Colors.orange,
      icon: Icons.checklist,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _skirtingController,
                  label: 'Skirting',
                  icon: Icons.format_align_left,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _floorPrepController,
                  label: 'Floor Preparation',
                  icon: Icons.build_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _groundSettingController,
                  label: 'Ground Setting',
                  icon: Icons.foundation,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _doorController,
                  label: 'Door Clearance',
                  icon: Icons.door_front_door_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _windowController,
                  label: 'Window',
                  icon: Icons.window_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _evenUnevenController,
                  label: 'Surface Level',
                  icon: Icons.straighten,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _areaConditionController,
            label: 'Overall Area Condition',
            icon: Icons.assessment_outlined,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildOtherDetailsSection() {
    return _buildSection(
      title: 'Additional Notes',
      color: Colors.grey,
      icon: Icons.note_alt_outlined,
      child: _buildTextField(
        controller: _otherDetailsController,
        label: 'Any other inspection details or observations...',
        icon: Icons.edit_note,
        maxLines: 4,
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Color color,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool required = false,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon, color: Colors.purple.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple.shade500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple.shade500, width: 2),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

extension on Color {
  Color get shade700 => HSLColor.fromColor(this).withLightness(0.3).toColor();
}
