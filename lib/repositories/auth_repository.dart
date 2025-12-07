import '../services/api_service.dart';

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

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Register method
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.register(userData);
      return response;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Get current user
  Future<User> getCurrentUser(String token) async {
    try {
      final response = await _apiService.getCurrentUser(token);
      // Backend returns: {success: true, message: "...", data: {...}}
      final userData = response['data'] ?? response;
      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Validate token
  Future<bool> validateToken(String token) async {
    try {
      await getCurrentUser(token);
      return true;
    } catch (e) {
      return false;
    }
  }
}
