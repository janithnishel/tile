import 'package:tilework/models/purchase_order/supplier_item.dart';

class Supplier {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final List<String> categories;
  final List<SupplierItem> availableItems;

  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    List<String>? categories,
    List<SupplierItem>? availableItems,
  }) : categories = categories ?? [],
       availableItems = availableItems ?? [];

  // Factory constructor to create Supplier from JSON
  factory Supplier.fromJson(Map<String, dynamic> json) {
    List<String> categories = [];
    if (json['categories'] != null) {
      categories = List<String>.from(json['categories']);
    } else if (json['category'] != null) {
      categories = [json['category']];
    }

    // Filter out 'General' category (case insensitive) as it's a default that shouldn't be displayed
    categories = categories.where((cat) => !cat.toLowerCase().contains('general')).toList();

    return Supplier(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      categories: categories,
    );
  }

  // Convert Supplier to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'categories': categories,
    };
  }

  // Get initials for avatar
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '?';

  // Copy with method
  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    List<String>? categories,
    List<SupplierItem>? availableItems,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      categories: categories ?? this.categories,
      availableItems: availableItems ?? this.availableItems,
    );
  }

  // Get primary category for backward compatibility
  String get category => categories.isNotEmpty ? categories.first : 'General';

  // Get categories display text
  String get categoriesDisplayText => categories.join(', ');
}
