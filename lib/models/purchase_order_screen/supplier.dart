class Supplier {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String category;

  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.category = 'General',
  });

  // Get initials for avatar
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : '?';

  // Copy with method
  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? category,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      category: category ?? this.category,
    );
  }
}