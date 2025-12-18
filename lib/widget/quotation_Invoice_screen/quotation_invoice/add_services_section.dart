import 'package:flutter/material.dart';
import 'package:tilework/models/quotation_Invoice_screen/project/service_item.dart';

class AddServicesSection extends StatelessWidget {
  final List<ServiceItem> serviceItems;
  final bool isAddEnabled;
  final VoidCallback onAddService;
  final Function(int, ServiceItem) onServiceChanged;
  final Function(int, UnitType) onUnitTypeChanged;
  final Function(int, double) onQuantityChanged;
  final Function(int, double) onRateChanged;
  final Function(int, bool) onAlreadyPaidChanged;
  final Function(int) onDeleteService;

  const AddServicesSection({
    Key? key,
    required this.serviceItems,
    required this.isAddEnabled,
    required this.onAddService,
    required this.onServiceChanged,
    required this.onUnitTypeChanged,
    required this.onQuantityChanged,
    required this.onRateChanged,
    required this.onAlreadyPaidChanged,
    required this.onDeleteService,
  }) : super(key: key);

  // Available service options
  static const List<String> serviceOptions = [
    'New Service',
    'Floor Preparation',
    'Site Visit',
    'Transport',
    'Labor',
    'Installation',
    'Custom Service',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Add Services',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (serviceItems.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Text(
                      '${serviceItems.length} service${serviceItems.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            ElevatedButton.icon(
              onPressed: isAddEnabled ? onAddService : null,
              icon: const Icon(Icons.add),
              label: const Text('Add Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isAddEnabled ? Colors.orange.shade700 : Colors.grey.shade300,
                foregroundColor:
                    isAddEnabled ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Empty State
        if (serviceItems.isEmpty)
          _buildEmptyState()
        else ...[
          // Table Header
          _buildTableHeader(),

          // Service Items
          ...serviceItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildServiceRow(index, item);
          }),

          // Services Total
          _buildServicesTotal(),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.build, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No additional services added yet',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Click "Add Service" to start adding services',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 40),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.orange.shade50),
        child: const Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Service Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Text(
                'Unit Type',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Text(
                'Qty',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Text(
                'Rate (LKR)',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Text(
                'Amount (LKR)',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: Text(
                '',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRow(int index, ServiceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Service Description Dropdown (consistent width)
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 48, // Match height with other fields
              child: DropdownButtonFormField<String>(
                value: item.serviceDescription.isNotEmpty ? item.serviceDescription : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
                items: serviceOptions.map((service) {
                  return DropdownMenuItem(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final updatedItem = ServiceItem(
                      serviceDescription: value,
                      unitType: item.unitType,
                      quantity: item.quantity,
                      rate: item.rate,
                      isAlreadyPaid: item.isAlreadyPaid,
                    );
                    onServiceChanged(index, updatedItem);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Paid Status Chip (only for Site Visit, same height as other fields)
          if (item.serviceDescription.toLowerCase().contains('site visit'))
            SizedBox(
              width: 80,
              height: 48, // Match height with other fields
              child: GestureDetector(
                onTap: () {
                  onAlreadyPaidChanged(index, !item.isAlreadyPaid);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: item.isAlreadyPaid
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: item.isAlreadyPaid
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                    ),
                  ),
                  child: Text(
                    item.isAlreadyPaid ? 'PAID' : 'UNPAID',
                    style: TextStyle(
                      color: item.isAlreadyPaid
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 88), // Empty space to maintain alignment

          const SizedBox(width: 8),

          // Unit Type Dropdown
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 48, // Match height with other fields
              child: DropdownButtonFormField<UnitType>(
                value: item.unitType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: UnitType.fixed, child: Text('Fixed')),
                  DropdownMenuItem(value: UnitType.sqft, child: Text('sqft')),
                  DropdownMenuItem(value: UnitType.ft, child: Text('ft')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onUnitTypeChanged(index, value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Quantity Field
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 48, // Match height with other fields
              child: TextFormField(
                initialValue: item.quantity.toString(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  final qty = double.tryParse(value) ?? 1.0;
                  onQuantityChanged(index, qty);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Rate Field
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 48, // Match height with other fields
              child: TextFormField(
                initialValue: item.rate.toString(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  final rate = double.tryParse(value) ?? 0.0;
                  onRateChanged(index, rate);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Amount (Read-only)
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 48, // Match height with other fields
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'Rs ${item.amount.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Action Column: Delete button only
          SizedBox(
            width: 80,
            height: 48, // Match height with other fields
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDeleteService(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTotal() {
    // Calculate total for all services (deduct already paid amounts)
    final total = serviceItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.isAlreadyPaid ? 0.0 : item.amount),
    );

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Services Total',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          Text(
            'Rs ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
