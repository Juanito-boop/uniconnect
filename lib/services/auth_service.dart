import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  dynamic get _client => SupabaseService.instance.client;

  // Obtener usuario actual
  dynamic get currentUser => _client.auth.currentUser;

  // Obtener sesión actual
  dynamic get currentSession => _client.auth.currentSession;

  // Verificar si el usuario está autenticado
  bool get isAuthenticated => currentUser != null;

  // Clave para persistir la sesión
  static const String _sessionKey = 'user_session_token';

  // Restaurar sesión desde SharedPreferences
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

  // Registro con email y contraseña
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
      throw Exception('Error al registrarse: $error');
    }
  }

  // Iniciar sesión con email y contraseña
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
      throw Exception('Error al iniciar sesión: $error');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (error) {
      throw Exception('Error al cerrar sesión: $error');
    }
  }

  // Obtener perfil de usuario actual
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
      throw Exception('Error al obtener el perfil: $error');
    }
  }

  // Actualizar perfil de usuario
  Future<UserProfile> updateUserProfile({
    String? fullName,
    String? department,
    String? studentId,
    String? profileImageUrl,
  }) async {
    try {
      if (!isAuthenticated) {
        throw Exception('Usuario no autenticado');
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
      throw Exception('Error al actualizar el perfil: $error');
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Error al restablecer la contraseña: $error');
    }
  }

  // Escuchar cambios de autenticación
  Stream<dynamic> get authStateChanges => _client.auth.onAuthStateChange;

  // Verificar si el usuario actual es admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.isAdmin ?? false;
    } catch (error) {
      return false;
    }
  }
}
