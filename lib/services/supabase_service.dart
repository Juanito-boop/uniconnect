import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static bool _initialized = false;

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    if (_initialized) return; // Evitar inicialización doble
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
          'ERROR: Las variables de entorno SUPABASE_URL y SUPABASE_ANON_KEY no están definidas.\n\n'
          'Debes iniciar la app usando:\n'
          'flutter run --dart-define=SUPABASE_URL=TU_URL --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY\n\n'
          'Reemplaza TU_URL y TU_ANON_KEY por los valores reales de tu proyecto Supabase.');
    }

    // Logging básico
    debugPrint('[SupabaseService] Inicializando con URL: $supabaseUrl');
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _initialized = true;
    debugPrint('[SupabaseService] Inicialización completada');
  }

  // Get Supabase client
  SupabaseClient get client => Supabase.instance.client;
}
