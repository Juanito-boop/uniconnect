import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  dynamic get _client => SupabaseService.instance.client;

  // Get current user
  dynamic get currentUser => _client.auth.currentUser;

  // Get current session
  dynamic get currentSession => _client.auth.currentSession;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Persist session token key
  static const String _sessionKey = 'user_session_token';

  // Restore session from SharedPreferences
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionString = prefs.getString(_sessionKey);
    if (sessionString != null && currentSession == null) {
      try {
        final sessionMap = jsonDecode(sessionString);
        await _client.auth.recoverSession(sessionMap);
      } catch (_) {}
    }
  }

  // Sign up with email and password
  Future<dynamic> signUp({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.student,
    String? department,
    String? studentId,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role.name,
          'department': department,
          'student_id': studentId,
        },
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  // Sign in with email and password
  Future<dynamic> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // Guardar sesión serializada si existe
      final session = response.session;
      if (session != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
      }
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      if (!isAuthenticated) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  // Update user profile
  Future<UserProfile> updateUserProfile({
    String? fullName,
    String? department,
    String? studentId,
    String? profileImageUrl,
  }) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (department != null) updateData['department'] = department;
      if (studentId != null) updateData['student_id'] = studentId;
      if (profileImageUrl != null)
        updateData['profile_image_url'] = profileImageUrl;

      final response = await _client
          .from('user_profiles')
          .update(updateData)
          .eq('id', currentUser!.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Listen to auth state changes
  Stream<dynamic> get authStateChanges => _client.auth.onAuthStateChange;

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.isAdmin ?? false;
    } catch (error) {
      return false;
    }
  }
}
