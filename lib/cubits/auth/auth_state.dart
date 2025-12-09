// import '../../repositories/auth/auth_repository.dart';

// abstract class AuthState {}

// class AuthInitial extends AuthState {}

// class AuthLoading extends AuthState {}

// class AuthAuthenticated extends AuthState {
//   final User user;
//   final String token;

//   AuthAuthenticated({required this.user, required this.token});

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is AuthAuthenticated &&
//         other.user.id == user.id &&
//         other.token == token;
//   }

//   @override
//   int get hashCode => user.id.hashCode ^ token.hashCode;
// }

// class AuthUnauthenticated extends AuthState {}

// class AuthError extends AuthState {
//   final String message;

//   AuthError({required this.message});

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is AuthError && other.message == message;
//   }

//   @override
//   int get hashCode => message.hashCode;
// }

// import '../../repositories/auth/auth_repository.dart'; // This import is not needed here

import 'package:tilework/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final String token;

  AuthAuthenticated({required this.user, required this.token});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthAuthenticated &&
        other.user.id == user.id &&
        other.token == token;
  }

  @override
  int get hashCode => user.id.hashCode ^ token.hashCode;
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}