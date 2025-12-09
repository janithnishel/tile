// import '../../services/auth/api_service.dart'; // This import is not needed in the Model file itself

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? companyName;
  final String? companyAddress;
  final String? companyPhone;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.companyName,
    this.companyAddress,
    this.companyPhone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      companyName: json['companyName'],
      companyAddress: json['companyAddress'],
      companyPhone: json['companyPhone'],
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyPhone': companyPhone,
      'role': role,
    };
  }
}