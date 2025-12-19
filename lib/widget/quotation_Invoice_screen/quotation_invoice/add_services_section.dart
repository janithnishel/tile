// import 'package:flutter/material.dart';
// import 'package:tilework/models/category_model.dart';
// import 'package:tilework/models/quotation_Invoice_screen/project/item_description.dart';
// import 'package:tilework/models/quotation_Invoice_screen/project/service_item.dart';

// class AddServicesSection extends StatelessWidget {
//   final List<ServiceItem> serviceItems;
//   final List<CategoryModel>? categories;
//   final bool isAddEnabled;
//   final VoidCallback onAddService;
//   final Function(int, ServiceItem) onServiceChanged;
//   final Function(int, UnitType) onUnitTypeChanged;
//   final Function(int, double) onQuantityChanged;
//   final Function(int, double) onRateChanged;
//   final Function(int, bool) onAlreadyPaidChanged;
//   final Function(int) onDeleteService;

//   const AddServicesSection({
//     Key? key,
//     required this.serviceItems,
//     required this.categories,
//     required this.isAddEnabled,
//     required this.onAddService,
//     required this.onServiceChanged,
//     required this.onUnitTypeChanged,
//     required this.onQuantityChanged,
//     required this.onRateChanged,
//     required this.onAlreadyPaidChanged,
//     required this.onDeleteService,
//   }) : super(key: key);

//   // Get unique categories that have services
//   List<String> get _availableCategories {
//     final Set<String> categoryNames = {};

//     // Add categories from API-loaded categories that have services
//     for (final category in categories ?? []) {
//       if (category.items.any((ItemModel item) => item.isService)) {
//         categoryNames.add(category.name);
//       }
//     }

//     // Convert to sorted list
//     final sortedCategories = categoryNames.toList()..sort();

//     // Add default option
//     if (sortedCategories.isEmpty) {
//       return ['Select Category'];
//     }

//     return ['Select Category', ...sortedCategories];
//   }

//   // Get services for a specific category
//   List<String> _getServicesForCategory(String categoryName) {
//     if (categoryName == 'Select Category' || categoryName.isEmpty) {
//       return ['Select Service'];
//     }

//     final category = categories?.firstWhere(
//       (cat) => cat.name == categoryName,
//       orElse: () => CategoryModel(id: '', name: '', companyId: '', items: []),
//     );

//     if (category?.id.isEmpty ?? true) {
//       return ['Select Service'];
//     }

//     // Filter for services only
//     final services = category!.items
//         .where((ItemModel item) => item.isService)
//         .map((ItemModel item) => item.itemName)
//         .toSet()
//         .toList()
//       ..sort();

//     if (services.isEmpty) {
//       return ['No Services Available'];
//     }

//     return ['Select Service', ...services];
//   }

//   // Get ItemDescription for a category and service combination
//   ItemDescription? _getServiceDescription(String categoryName, String serviceName) {
//     if (categoryName == 'Select Category' || serviceName == 'Select Service' || serviceName == 'No Services Available') {
//       return null;
//     }

//     final category = categories?.firstWhere(
//       (cat) => cat.name == categoryName,
//       orElse: () => CategoryModel(id: '', name: '', companyId: '', items: []),
//     );

//     if (category?.id.isEmpty ?? true) return null;

//     final item = category!.items.firstWhere(
//       (ItemModel item) => item.itemName == serviceName && item.isService,
//       orElse: () => ItemModel(
//         id: '',
//         itemName: '',
//         baseUnit: '',
//         sqftPerUnit: 0.0,
//         categoryId: '',
//         isService: false,
//       ),
//     );

//     if (item.id.isEmpty) return null;

//     return ItemDescription(
//       serviceName,
//       sellingPrice: 0.0,
//       unit: item.baseUnit,
//       category: category.name,
//       categoryId: category.id,
//       productName: item.itemName,
//       type: ItemType.service,
//       servicePaymentStatus: item.pricingType == 'fixed'
//           ? ServicePaymentStatus.fixed
//           : ServicePaymentStatus.variable,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header Row
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'Add Services',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 if (serviceItems.isNotEmpty) ...[
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade100,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.orange.shade300),
//                     ),
//                     child: Text(
//                       '${serviceItems.length} service${serviceItems.length == 1 ? '' : 's'}',
//                       style: TextStyle(
//                         color: Colors.orange.shade800,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//             ElevatedButton.icon(
//               onPressed: isAddEnabled ? onAddService : null,
//               icon: const Icon(Icons.add),
//               label: const Text('Add Service'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     isAddEnabled ? Colors.orange.shade700 : Colors.grey.shade300,
//                 foregroundColor:
//                     isAddEnabled ? Colors.white : Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),

//         // Empty State
//         if (serviceItems.isEmpty)
//           _buildEmptyState()
//         else ...[
//           // Table Header
//           _buildTableHeader(),

//           // Service Items
//           ...serviceItems.asMap().entries.map((entry) {
//             final index = entry.key;
//             final item = entry.value;
//             return _buildCustomServiceRow(index, item);
//           }),

//           // Services Total
//           _buildServicesTotal(),
//         ],
//       ],
//     );
//   }

//   Widget _buildEmptyState() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 40),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Center(
//         child: Column(
//           children: [
//             Icon(Icons.build, size: 48, color: Colors.grey.shade400),
//             const SizedBox(height: 16),
//             Text(
//               'No additional services added yet',
//               style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Click "Add Service" to start adding services',
//               style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTableHeader() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0, right: 40),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(color: Colors.orange.shade50),
//         child: const Row(
//           children: [
//             Expanded(
//               flex: 2,
//               child: Text(
//                 'Category',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               flex: 2,
//               child: Text(
//                 'Service Item',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             SizedBox(width: 8),
//             SizedBox(
//               width: 70,
//               child: Text(
//                 'Unit',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               flex: 1,
//               child: Text(
//                 'Qty',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               flex: 1,
//               child: Text(
//                 'Rate (LKR)',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             SizedBox(width: 8),
//             Expanded(
//               flex: 1,
//               child: Text(
//                 'Amount (LKR)',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.right,
//               ),
//             ),
//             SizedBox(width: 8),
//             SizedBox(
//               width: 80,
//               child: Text(
//                 '',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Build a custom Service Row with category and service dropdowns
//   Widget _buildCustomServiceRow(int index, ServiceItem item) {
//     return _CustomServiceRow(
//       key: ValueKey(item),
//       index: index,
//       item: item,
//       categories: _availableCategories,
//       getServicesForCategory: _getServicesForCategory,
//       getServiceDescription: _getServiceDescription,
//       onServiceChanged: (updatedItem) => onServiceChanged(index, updatedItem),
//       onUnitTypeChanged: (unitType) => onUnitTypeChanged(index, unitType),
//       onQuantityChanged: (qty) => onQuantityChanged(index, qty),
//       onRateChanged: (rate) => onRateChanged(index, rate),
//       onAlreadyPaidChanged: (isPaid) => onAlreadyPaidChanged(index, isPaid),
//       onDelete: () => onDeleteService(index),
//     );
//   }

//   Widget _buildServicesTotal() {
//     // Calculate total for all services (deduct already paid amounts)
//     final total = serviceItems.fold<double>(
//       0.0,
//       (sum, item) => sum + (item.isAlreadyPaid ? 0.0 : item.amount),
//     );

//     return Container(
//       margin: const EdgeInsets.only(top: 16),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.orange.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.orange.shade200),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             'Services Total',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.orange,
//             ),
//           ),
//           Text(
//             'Rs ${total.toStringAsFixed(2)}',
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.orange,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Custom Service Row with separate Category and Service dropdowns
// class _CustomServiceRow extends StatefulWidget {
//   final int index;
//   final ServiceItem item;
//   final List<String> categories;
//   final List<String> Function(String) getServicesForCategory;
//   final ItemDescription? Function(String, String) getServiceDescription;
//   final Function(ServiceItem) onServiceChanged;
//   final Function(UnitType) onUnitTypeChanged;
//   final Function(double) onQuantityChanged;
//   final Function(double) onRateChanged;
//   final Function(bool) onAlreadyPaidChanged;
//   final VoidCallback onDelete;

//   const _CustomServiceRow({
//     Key? key,
//     required this.index,
//     required this.item,
//     required this.categories,
//     required this.getServicesForCategory,
//     required this.getServiceDescription,
//     required this.onServiceChanged,
//     required this.onUnitTypeChanged,
//     required this.onQuantityChanged,
//     required this.onRateChanged,
//     required this.onAlreadyPaidChanged,
//     required this.onDelete,
//   }) : super(key: key);

//   @override
//   State<_CustomServiceRow> createState() => _CustomServiceRowState();
// }

// class _CustomServiceRowState extends State<_CustomServiceRow> {
//   late TextEditingController _quantityController;
//   late TextEditingController _rateController;
//   String? _selectedCategory;
//   String? _selectedService;

//   @override
//   void initState() {
//     super.initState();
//     _initControllers();
//     _initSelections();
//   }

//   void _initControllers() {
//     _quantityController = TextEditingController(
//       text: widget.item.quantity > 0
//           ? widget.item.quantity.toStringAsFixed(1)
//           : '',
//     );
//     _rateController = TextEditingController(
//       text: widget.item.rate > 0
//           ? widget.item.rate.toStringAsFixed(2)
//           : '',
//     );
//   }

//   void _initSelections() {
//     // Try to match existing service description to category and service
//     // This is a simple approach - in a real app you might store category/service separately
//     _selectedCategory = 'Select Category';
//     _selectedService = 'Select Service';

//     // For existing items, we need to find which category and service matches
//     // For now, we'll set defaults and let user select
//   }

//   @override
//   void didUpdateWidget(_CustomServiceRow oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.item != widget.item) {
//       _updateControllers();
//     }
//   }

//   void _updateControllers() {
//     final newQty = widget.item.quantity > 0
//         ? widget.item.quantity.toStringAsFixed(1)
//         : '';
//     final newRate = widget.item.rate > 0
//         ? widget.item.rate.toStringAsFixed(2)
//         : '';

//     if (_quantityController.text != newQty) {
//       _quantityController.text = newQty;
//     }
//     if (_rateController.text != newRate) {
//       _rateController.text = newRate;
//     }
//   }

//   @override
//   void dispose() {
//     _quantityController.dispose();
//     _rateController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Category Dropdown
//           Expanded(
//             flex: 2,
//             child: _buildCategoryDropdown(),
//           ),
//           const SizedBox(width: 8),

//           // Service Dropdown
//           Expanded(
//             flex: 2,
//             child: _buildServiceDropdown(),
//           ),
//           const SizedBox(width: 8),

//           // Unit Display
//           _buildUnitDisplay(),
//           const SizedBox(width: 8),

//           // Quantity
//           Expanded(
//             flex: 1,
//             child: _buildQuantityField(),
//           ),
//           const SizedBox(width: 8),

//           // Rate
//           Expanded(
//             flex: 1,
//             child: _buildRateField(),
//           ),
//           const SizedBox(width: 8),

//           // Amount
//           Expanded(
//             flex: 1,
//             child: _buildAmountDisplay(),
//           ),

//           // Paid Status and Delete
//           _buildStatusAndDelete(),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryDropdown() {
//     return DropdownButtonFormField<String>(
//       value: _selectedCategory,
//       decoration: InputDecoration(
//         border: const OutlineInputBorder(),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//         hintText: 'Select Category',
//       ),
//       isExpanded: true,
//       items: widget.categories
//           .map(
//             (category) => DropdownMenuItem(
//               value: category,
//               child: Text(category),
//             ),
//           )
//           .toList(),
//       onChanged: (value) {
//         setState(() {
//           _selectedCategory = value;
//           _selectedService = null; // Reset service when category changes
//         });
//       },
//     );
//   }

//   Widget _buildServiceDropdown() {
//     final services = _selectedCategory != null
//         ? widget.getServicesForCategory(_selectedCategory!)
//         : ['Select Category First'];

//     return DropdownButtonFormField<String>(
//       value: _selectedService,
//       decoration: InputDecoration(
//         border: const OutlineInputBorder(),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//         hintText: 'Select Service',
//       ),
//       isExpanded: true,
//       items: services
//           .map(
//             (service) => DropdownMenuItem(
//               value: service,
//               child: Text(service),
//             ),
//           )
//           .toList(),
//       onChanged: (_selectedCategory != null && _selectedCategory != 'Select Category')
//           ? (value) {
//               if (value != null && value != 'Select Service' && value != 'No Services Available') {
//                 setState(() {
//                   _selectedService = value;
//                 });

//                 final serviceDesc = widget.getServiceDescription(_selectedCategory!, value);
//                 if (serviceDesc != null) {
//                   final updatedItem = ServiceItem(
//                     serviceDescription: serviceDesc.name,
//                     unitType: widget.item.unitType,
//                     quantity: widget.item.quantity,
//                     rate: widget.item.rate,
//                     isAlreadyPaid: widget.item.isAlreadyPaid,
//                   );
//                   widget.onServiceChanged(updatedItem);
//                 }
//               }
//             }
//           : null,
//     );
//   }

//   Widget _buildUnitDisplay() {
//     return SizedBox(
//       width: 70,
//       child: Container(
//         alignment: Alignment.center,
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Text(widget.item.unitType.name),
//       ),
//     );
//   }

//   Widget _buildQuantityField() {
//     return TextField(
//       controller: _quantityController,
//       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//       decoration: InputDecoration(
//         border: const OutlineInputBorder(),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//         hintText: '0',
//       ),
//       onChanged: (value) {
//         widget.onQuantityChanged(double.tryParse(value) ?? 0.0);
//       },
//     );
//   }

//   Widget _buildRateField() {
//     return TextField(
//       controller: _rateController,
//       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//       decoration: InputDecoration(
//         border: const OutlineInputBorder(),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//         hintText: '0.00',
//       ),
//       onChanged: (value) {
//         widget.onRateChanged(double.tryParse(value) ?? 0.0);
//       },
//     );
//   }

//   Widget _buildAmountDisplay() {
//     return Container(
//       alignment: Alignment.centerRight,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         widget.item.amount > 0 ? widget.item.amount.toStringAsFixed(2) : '-',
//         style: const TextStyle(fontWeight: FontWeight.w500),
//       ),
//     );
//   }

//   Widget _buildStatusAndDelete() {
//     return SizedBox(
//       width: 80,
//       child: Row(
//         children: [
//           // Paid Status (only show for site visit)
//           if (widget.item.serviceDescription.toLowerCase().contains('site visit'))
//             Expanded(
//               child: GestureDetector(
//                 onTap: () {
//                   widget.onAlreadyPaidChanged(!widget.item.isAlreadyPaid);
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.only(right: 4),
//                   padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: widget.item.isAlreadyPaid
//                         ? Colors.green.shade100
//                         : Colors.red.shade100,
//                     borderRadius: BorderRadius.circular(4),
//                     border: Border.all(
//                       color: widget.item.isAlreadyPaid
//                           ? Colors.green.shade300
//                           : Colors.red.shade300,
//                     ),
//                   ),
//                   child: Text(
//                     widget.item.isAlreadyPaid ? 'PAID' : 'UNPAID',
//                     style: TextStyle(
//                       color: widget.item.isAlreadyPaid
//                           ? Colors.green.shade800
//                           : Colors.red.shade800,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 8,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),

//           // Delete Button
//           IconButton(
//             icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
//             onPressed: widget.onDelete,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//         ],
//       ),
//     );
//   }
// }
