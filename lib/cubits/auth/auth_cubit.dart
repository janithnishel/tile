// import 'package:flutter/foundation.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../repositories/auth/auth_repository.dart';
// import 'auth_state.dart';

// class AuthCubit extends Cubit<AuthState> {
//   final AuthRepository _authRepository;

//   AuthCubit(this._authRepository) : super(AuthInitial());

//   // Login method
//   Future<void> login(String email, String password) async {
//     debugPrint('🚀 AuthCubit: Starting login process');
//     emit(AuthLoading());

//     try {
//       debugPrint('📡 AuthCubit: Calling repository login');
//       final response = await _authRepository.login(email, password);
//       debugPrint('📥 AuthCubit: Received response: $response');

//       // Backend returns: {success: true, message: "...", data: {token: "...", user: {...}}}
//       final data = response['data'];

//       if (data != null && data['token'] != null && data['user'] != null) {
//         final token = data['token'];
//         final userData = data['user'];
//         final user = User.fromJson(userData);
//         debugPrint('✅ AuthCubit: Login successful for user: ${user.name} (${user.role})');
//         emit(AuthAuthenticated(user: user, token: token));
//       } else {
//         debugPrint('❌ AuthCubit: Invalid response format: $data');
//         emit(AuthError(message: 'Invalid response from server'));
//       }
//     } catch (e) {
//       debugPrint('💥 AuthCubit: Login failed with error: $e');
//       emit(AuthError(message: e.toString()));
//     }
//   }

//   // Logout method
//   void logout() {
//     emit(AuthUnauthenticated());
//   }

//   // Check if user is authenticated
//   Future<void> checkAuthStatus() async {
//     if (state is AuthAuthenticated) {
//       final currentState = state as AuthAuthenticated;
//       try {
//         // Validate the current token
//         final isValid = await _authRepository.validateToken(currentState.token);
//         if (!isValid) {
//           emit(AuthUnauthenticated());
//         }
//         // If valid, stay authenticated
//       } catch (e) {
//         emit(AuthUnauthenticated());
//       }
//     } else {
//       emit(AuthUnauthenticated());
//     }
//   }

//   // Get current user
//   Future<void> refreshUser() async {
//     if (state is AuthAuthenticated) {
//       final currentState = state as AuthAuthenticated;
//       try {
//         final user = await _authRepository.getCurrentUser(currentState.token);
//         emit(AuthAuthenticated(user: user, token: currentState.token));
//       } catch (e) {
//         emit(AuthError(message: e.toString()));
//       }
//     }
//   }

//   // Register company (creates a user account with company info)
//   Future<User?> registerCompany({
//     required String ownerName,
//     required String ownerEmail,
//     required String ownerPhone,
//     required String companyName,
//     required String companyAddress,
//     required String companyPhone,
//    required String password // Default password for company accounts
//   }) async {
//     try {
//       final userData = {
//         'name': ownerName,
//         'email': ownerEmail,
//         'password': password,
//         'phone': ownerPhone,
//         'companyName': companyName,
//         'companyAddress': companyAddress,
//         'companyPhone': companyPhone,
//       };

//       final response = await _authRepository.register(userData);
//       // Backend returns: {success: true, message: "...", data: {token: "...", user: {...}}}
//       final data = response['data'];
//       if (data != null && data['user'] != null) {
//         return User.fromJson(data['user']);
//       } else {
//         throw Exception('Invalid response format');
//       }
//     } catch (e) {
//       throw Exception('Company registration failed: $e');
//     }
//   }
// }


import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tilework/models/user_model.dart';
import 'package:tilework/repositories/auth/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  // Login method
  Future<void> login(String email, String password) async {
    debugPrint('🚀 AuthCubit: Starting login process');
    emit(AuthLoading());

    try {
      debugPrint('📡 AuthCubit: Calling repository login');
      final response = await _authRepository.login(email, password);
      debugPrint('📥 AuthCubit: Received response: $response');

      // Backend returns: {success: true, message: "...", data: {token: "...", user: {...}}}
      final data = response['data'];

      if (data != null && data['token'] != null && data['user'] != null) {
        final token = data['token'];
        final userData = data['user'];
        final user = User.fromJson(userData);
        debugPrint('✅ AuthCubit: Login successful for user: ${user.name} (${user.role})');
        emit(AuthAuthenticated(user: user, token: token));
      } else {
        debugPrint('❌ AuthCubit: Invalid response format: $data');
        emit(AuthError(message: 'Invalid response from server'));
      }
    } catch (e) {
      debugPrint('💥 AuthCubit: Login failed with error: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  // Logout method
  void logout() {
    emit(AuthUnauthenticated());
  }

  // Check if user is authenticated
  Future<void> checkAuthStatus() async {
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;
      try {
        // Validate the current token
        final isValid = await _authRepository.validateToken(currentState.token);
        if (!isValid) {
          emit(AuthUnauthenticated());
        }
        // If valid, stay authenticated
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  // Get current user
  Future<void> refreshUser() async {
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;
      try {
        final user = await _authRepository.getCurrentUser(currentState.token);
        emit(AuthAuthenticated(user: user, token: currentState.token));
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    }
  }

  // 🎯 Register company (creates a user account with company info)
  Future<User?> registerCompany({
    required String ownerName,
    required String ownerEmail,
    required String ownerPhone,
    required String companyName,
    required String companyAddress,
    required String companyPhone,
    required String password, // Default password for company accounts
  }) async {
    // Note: We don't change the main AuthState here as this is an admin action, not a login attempt.
    try {
      final userData = {
        'name': ownerName,
        'email': ownerEmail,
        'password': password,
        'phone': ownerPhone,
        'companyName': companyName,
        'companyAddress': companyAddress,
        'companyPhone': companyPhone,
        'role': 'company', // Backend එකට යවන role එක
      };

      final response = await _authRepository.register(userData);
      
      // Backend returns: {success: true, message: "...", data: {token: "...", user: {...}}}
      final data = response['data'];
      if (data != null && data['user'] != null) {
        final user = User.fromJson(data['user']);
        debugPrint('✅ AuthCubit: Company registration successful for user: ${user.email}');
        return user;
      } else {
        throw Exception('Invalid response format or missing user data.');
      }
    } catch (e) {
      debugPrint('💥 AuthCubit: Company registration failed: $e');
      rethrow; // Screen එකට දෝෂය යවන්න
    }
  }
}
