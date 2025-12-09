// import '../../services/auth/api_service.dart';

// class User {
//   final String id;
//   final String name;
//   final String email;
//   final String? phone;
//   final String? companyName;
//   final String? companyAddress;
//   final String? companyPhone;
//   final String role;

//   User({
//     required this.id,
//     required this.name,
//     required this.email,
//     this.phone,
//     this.companyName,
//     this.companyAddress,
//     this.companyPhone,
//     required this.role,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['_id'] ?? json['id'],
//       name: json['name'],
//       email: json['email'],
//       phone: json['phone'],
//       companyName: json['companyName'],
//       companyAddress: json['companyAddress'],
//       companyPhone: json['companyPhone'],
//       role: json['role'] ?? 'user',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'companyName': companyName,
//       'companyAddress': companyAddress,
//       'companyPhone': companyPhone,
//       'role': role,
//     };
//   }
// }

// class AuthRepository {
//   final ApiService _apiService;

//   AuthRepository(this._apiService);

//   // Login method
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     try {
//       final response = await _apiService.login(email, password);
//       return response;
//     } catch (e) {
//       throw Exception('Login failed: $e');
//     }
//   }

//   // Register method
//   Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
//     try {
//       final response = await _apiService.register(userData);
//       return response;
//     } catch (e) {
//       throw Exception('Registration failed: $e');
//     }
//   }

//   // Get current user
//   Future<User> getCurrentUser(String token) async {
//     try {
//       final response = await _apiService.getCurrentUser(token);
//       // Backend returns: {success: true, message: "...", data: {...}}
//       final userData = response['data'] ?? response;
//       return User.fromJson(userData);
//     } catch (e) {
//       throw Exception('Failed to get user: $e');
//     }
//   }

//   // Validate token
//   Future<bool> validateToken(String token) async {
//     try {
//       await getCurrentUser(token);
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }


// }


import '../../services/auth/api_service.dart'; // ApiService එකේ path එක නිවැරදි කරගන්න
import '../../models/user_model.dart'; // User model එකේ path එක

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // 🚨 Note: The actual implementation in ApiService handles the API call
      final response = await _apiService.login(email, password);
      return response;
    } catch (e) {
      // We throw a more specific exception that the Cubit can catch
      throw Exception('Login failed: ${e.toString()}'); 
    }
  }

  // Register method (Used by AuthCubit for Company Registration)
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      // 🚨 Note: The actual implementation in ApiService handles the API call
      final response = await _apiService.register(userData);
      return response;
    } catch (e) {
      // We throw a more specific exception that the Cubit can catch
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Get current user (Requires a token for authorization)
  Future<User> getCurrentUser(String token) async {
    try {
      final response = await _apiService.getCurrentUser(token);
      // Backend returns: {success: true, message: "...", data: {...}}
      final userData = response['data'] ?? response;
      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to get user details: ${e.toString()}');
    }
  }

  // Validate token (Often uses the getCurrentUser endpoint for validation)
  Future<bool> validateToken(String token) async {
    try {
      // If getCurrentUser succeeds, the token is valid
      await getCurrentUser(token);
      return true;
    } catch (e) {
      // If getCurrentUser fails (e.g., 401 Unauthorized), the token is invalid
      return false;
    }
  }
}