// lib/core/errors/auth_exception.dart
class AppAuthException implements Exception {
  final String message;
  
  AppAuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}