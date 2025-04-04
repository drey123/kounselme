// lib/data/remote/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:kounselme/core/errors/auth_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// AuthException is already available from the main Supabase import

class AuthService {
  final _supabase = Supabase.instance.client;
  
  // Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentUser != null;
  
  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
  
  // Get auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Create user profile in database
        await _createUserProfile(response.user!.id, email);
        return response.user;
      }
      return null;
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('Sign up error: ${e.message}');
      }
      throw AppAuthException(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected sign up error: $e');
      }
      throw AppAuthException('Failed to sign up. Please try again.');
    }
  }
  
  // Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Update last login timestamp
        await _updateLastLogin(response.user!.id);
        return response.user;
      }
      return null;
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('Sign in error: ${e.message}');
      }
      throw AppAuthException(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected sign in error: $e');
      }
      throw AppAuthException('Failed to sign in. Please check your credentials.');
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      throw AppAuthException('Failed to sign out. Please try again.');
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      if (kDebugMode) {
        print('Reset password error: $e');
      }
      throw AppAuthException('Failed to send password reset email. Please try again.');
    }
  }
  
  // Create user profile in Supabase database
  Future<void> _createUserProfile(String userId, String email) async {
    try {
      await _supabase.from('users').insert({
        'id': userId,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
        'last_login': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Create user profile error: $e');
      }
      // We don't throw here to avoid blocking signup
    }
  }
  
  // Update last login timestamp
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _supabase.from('users').update({
        'last_login': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      if (kDebugMode) {
        print('Update last login error: $e');
      }
      // We don't throw here to avoid blocking login
    }
  }
}