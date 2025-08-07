import '../services/supabase_service.dart';

/// Ejemplos de consultas para eventos con categorías usando la tabla puente
/// 
/// Estructura de la base de datos:
/// - events (tabla principal)
/// - event_categories (categorías disponibles)
/// - event_category_assignments (tabla puente para relación muchos a muchos)
class EventsQueryExamples {
  static dynamic get _client => SupabaseService.instance.client;

  /// Ejemplo 1: Obtener todos los eventos con sus categorías
  static Future<void> getAllEventsWithCategories() async {
    try {
      final response = await _client
          .from('events')
          .select('''
            *,
            user_profiles!author_id(full_name),
            event_category_assignments!inner(
              event_categories!inner(id, name, color_code, icon_name)
            )
          ''')
          .eq('status', 'active')
          .order('event_date', ascending: true);

      print('Eventos con categorías:');
      for (final event in response) {
        final categories = event['event_category_assignments'] != null 
            ? (event['event_category_assignments'] as List)
                .map((assignment) => assignment['event_categories']['name'])
                .toList()
            : <String>[];
        
        print('Evento: ${event['title']}');
        print('Categorías: ${categories.join(', ')}');
        print('---');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  /// Ejemplo 2: Obtener eventos de una categoría específica
  static Future<void> getEventsByCategory(String categoryName) async {
    try {
      final response = await _client
          .from('events')
          .select('''
            *,
            user_profiles!author_id(full_name),
            event_category_assignments!inner(
              event_categories!inner(id, name, color_code, icon_name)
            )
          ''')
          .eq('status', 'active')
          .eq('event_category_assignments.event_categories.name', categoryName)
          .order('event_date', ascending: true);

      print('Eventos de la categoría "$categoryName":');
      for (final event in response) {
        print('Evento: ${event['title']}');
        print('Fecha: ${event['event_date']}');
        print('---');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  /// Ejemplo 3: Obtener eventos con múltiples categorías
  static Future<void> getEventsWithMultipleCategories() async {
    try {
      final response = await _client
          .from('events')
          .select('''
            *,
            user_profiles!author_id(full_name),
            event_category_assignments!inner(
              event_categories!inner(id, name, color_code, icon_name)
            )
          ''')
          .eq('status', 'active')
          .order('event_date', ascending: true);

      print('Eventos con múltiples categorías:');
      for (final event in response) {
        final categories = event['event_category_assignments'] != null 
            ? (event['event_category_assignments'] as List)
                .map((assignment) => assignment['event_categories']['name'])
                .toList()
            : <String>[];
        
        if (categories.length > 1) {
          print('Evento: ${event['title']}');
          print('Categorías: ${categories.join(', ')}');
          print('---');
        }
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  /// Ejemplo 4: Crear un evento y asignarle categorías
  static Future<void> createEventWithCategories() async {
    try {
      // 1. Crear el evento
      final eventData = {
        'title': 'Taller de Flutter',
        'content': 'Aprende Flutter desde cero',
        'event_date': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        'location': 'Aula 101',
        'author_id': 'user-id-here', // Reemplazar con ID real
        'event_type': 'workshop',
        'requires_registration': true,
        'max_attendees': 30,
      };

      final eventResponse = await _client
          .from('events')
          .insert(eventData)
          .select()
          .single();

      final eventId = eventResponse['id'];

      // 2. Obtener IDs de categorías (asumiendo que ya existen)
      final categoriesResponse = await _client
          .from('event_categories')
          .select('id')
          .in_('name', ['Talleres', 'Tecnología']);

      // 3. Asignar categorías al evento
      final assignments = categoriesResponse
          .map((category) => {
                'event_id': eventId,
                'category_id': category['id'],
              })
          .toList();

      await _client
          .from('event_category_assignments')
          .insert(assignments);

      print('Evento creado con categorías exitosamente');
    } catch (error) {
      print('Error: $error');
    }
  }

  /// Ejemplo 5: Consulta SQL directa equivalente
  static Future<void> sqlEquivalentQuery() async {
    try {
      // Esta es la consulta SQL equivalente a lo que hace Supabase:
      // SELECT e.*, up.full_name, ec.name as category_name
      // FROM events e
      // LEFT JOIN user_profiles up ON e.author_id = up.id
      // LEFT JOIN event_category_assignments eca ON e.id = eca.event_id
      // LEFT JOIN event_categories ec ON eca.category_id = ec.id
      // WHERE e.status = 'active'
      // ORDER BY e.event_date ASC;

      final response = await _client
          .from('events')
          .select('''
            *,
            user_profiles!author_id(full_name),
            event_category_assignments!left(
              event_categories!left(id, name, color_code, icon_name)
            )
          ''')
          .eq('status', 'active')
          .order('event_date', ascending: true);

      print('Consulta equivalente a SQL:');
      for (final event in response) {
        final categories = event['event_category_assignments'] != null 
            ? (event['event_category_assignments'] as List)
                .where((assignment) => assignment['event_categories'] != null)
                .map((assignment) => assignment['event_categories']['name'])
                .toList()
            : <String>[];
        
        print('Evento: ${event['title']}');
        print('Autor: ${event['user_profiles']?['full_name']}');
        print('Categorías: ${categories.join(', ')}');
        print('---');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}
