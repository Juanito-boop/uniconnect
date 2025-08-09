import '../models/event.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';

class EventsService {
  static EventsService? _instance;
  static EventsService get instance => _instance ??= EventsService._();

  EventsService._();
  dynamic get _client => SupabaseService.instance.client;

  Future<List<Event>> getEvents({
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
    EventType? type,
    bool upcomingOnly = false,
    bool featuredOnly = false,
  }) async {
    try {
      final userId = AuthService.instance.currentUser?.id;

      var query = _client.from('events').select('''
            *,
            user_profiles!author_id(full_name),
            event_category_assignments!left(
              event_categories!left(id, name, color_code, icon_name)
            )
          ''').eq('status', 'active');

      if (upcomingOnly) {
        query = query.gte('event_date', DateTime.now().toIso8601String());
      }

      if (startDate != null) {
        query = query.gte('event_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('event_date', endDate.toIso8601String());
      }

      if (type != null) {
        query = query.eq('event_type', type.name);
      }

      if (featuredOnly) {
        query = query.eq('is_featured', true);
      }

      query = query.order('event_date', ascending: true).limit(limit);

      final response = await query;

      // Obtener registros de eventos para el usuario actual
      Set<String> registeredEvents = {};
      if (userId != null) {
        final registrations = await _client
            .from('event_registrations')
            .select('event_id')
            .eq('user_id', userId);

        registeredEvents =
            Set<String>.from(registrations.map((r) => r['event_id'] as String));
      }

      // Obtener conteo de registros para cada evento
      final eventIds = response.map((e) => e['id'] as String).toList();
      Map<String, int> registrationCounts = {};

      if (eventIds.isNotEmpty) {
        // Obtener todos los registros y contar manualmente
        final allRegistrations =
            await _client.from('event_registrations').select('event_id');

        // Contar registros por evento
        for (final registration in allRegistrations) {
          final eventId = registration['event_id'] as String;
          if (eventIds.contains(eventId)) {
            registrationCounts[eventId] =
                (registrationCounts[eventId] ?? 0) + 1;
          }
        }
      }

      return response.map<Event>((json) {
        final categories = json['event_category_assignments'] != null
            ? (json['event_category_assignments'] as List)
                .where((assignment) => assignment['event_categories'] != null)
                .map((assignment) =>
                    assignment['event_categories']['name'] as String)
                .toList()
            : <String>[];

        return Event.fromJson({
          ...json,
          'categories': categories,
          'registration_count': registrationCounts[json['id']] ?? 0,
          'is_registered': registeredEvents.contains(json['id']),
        });
      }).toList();
    } catch (error) {
      throw Exception('Error al obtener eventos: $error');
    }
  }

  Future<Event> createEvent({
    required String title,
    required String content,
    required DateTime eventDate,
    required String location,
    String? imageUrl,
    String? registrationUrl,
    int maxAttendees = 0,
    EventType eventType = EventType.general,
    bool requiresRegistration = false,
    List<String> speakers = const [],
    String? agendaUrl,
    bool isOnline = false,
    String? meetingUrl,
    bool isFeatured = false,
    List<String>? categoryIds,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final isAdmin = await AuthService.instance.isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Solo los administradores pueden crear eventos');
      }

      final eventData = {
        'author_id': currentUser.id,
        'title': title,
        'content': content,
        'image_url': imageUrl,
        'event_date': eventDate.toIso8601String(),
        'location': location,
        'registration_url': registrationUrl,
        'max_attendees': maxAttendees,
        'event_type': eventType.name,
        'requires_registration': requiresRegistration,
        'speakers': speakers,
        'agenda_url': agendaUrl,
        'is_online': isOnline,
        'meeting_url': meetingUrl,
        'is_featured': isFeatured,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _client.from('events').insert(eventData).select().single();

      if (categoryIds != null && categoryIds.isNotEmpty) {
        await _assignCategoriesToEvent(response['id'], categoryIds);
      }

      return Event.fromJson(response);
    } catch (error) {
      throw Exception('Error al crear el evento: $error');
    }
  }

  Future<void> registerForEvent(String eventId) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _client.from('event_registrations').insert({
        'event_id': eventId,
        'user_id': userId,
      });
    } catch (error) {
      throw Exception('Error al registrarse en el evento: $error');
    }
  }

  Future<void> cancelRegistration(String eventId) async {
    try {
      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _client
          .from('event_registrations')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', userId);
    } catch (error) {
      throw Exception('Error al cancelar el registro: $error');
    }
  }

  Future<void> toggleLike(String eventId) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final existingLike = await _client
          .from('event_likes')
          .select()
          .eq('event_id', eventId)
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (existingLike != null) {
        await _client
            .from('event_likes')
            .delete()
            .eq('event_id', eventId)
            .eq('user_id', currentUser.id);
      } else {
        await _client.from('event_likes').insert({
          'event_id': eventId,
          'user_id': currentUser.id,
        });
      }
    } catch (error) {
      throw Exception('Error al actualizar el like: $error');
    }
  }

  Future<List<Event>> searchEvents(String query, {int limit = 50}) async {
    try {
      final userId = AuthService.instance.currentUser?.id;

      final response = await _client
          .from('events')
          .select('''
            *,
            user_profiles!author_id(full_name),
            event_category_assignments!left(
              event_categories!left(id, name, color_code, icon_name)
            )
          ''')
          .or('title.ilike.%$query%,content.ilike.%$query%,location.ilike.%$query%')
          .gte('event_date', DateTime.now().toIso8601String())
          .eq('status', 'active')
          .order('event_date', ascending: true)
          .limit(limit);

      // Obtener registros de eventos para el usuario actual
      Set<String> registeredEvents = {};
      if (userId != null) {
        final registrations = await _client
            .from('event_registrations')
            .select('event_id')
            .eq('user_id', userId);

        registeredEvents =
            Set<String>.from(registrations.map((r) => r['event_id'] as String));
      }

      // Obtener conteo de registros para cada evento
      final eventIds = response.map((e) => e['id'] as String).toList();
      Map<String, int> registrationCounts = {};

      if (eventIds.isNotEmpty) {
        // Obtener todos los registros y contar manualmente
        final allRegistrations =
            await _client.from('event_registrations').select('event_id');

        // Contar registros por evento
        for (final registration in allRegistrations) {
          final eventId = registration['event_id'] as String;
          if (eventIds.contains(eventId)) {
            registrationCounts[eventId] =
                (registrationCounts[eventId] ?? 0) + 1;
          }
        }
      }

      return response.map<Event>((json) {
        final categories = json['event_category_assignments'] != null
            ? (json['event_category_assignments'] as List)
                .where((assignment) => assignment['event_categories'] != null)
                .map((assignment) =>
                    assignment['event_categories']['name'] as String)
                .toList()
            : <String>[];

        return Event.fromJson({
          ...json,
          'categories': categories,
          'registration_count': registrationCounts[json['id']] ?? 0,
          'is_registered': registeredEvents.contains(json['id']),
        });
      }).toList();
    } catch (error) {
      throw Exception('Error al buscar eventos: $error');
    }
  }

  Future<Event?> getEventById(String eventId) async {
    try {
      final userId = AuthService.instance.currentUser?.id;

      final response = await _client.from('events').select('''
            *,
            user_profiles!author_id(full_name),
            event_category_assignments!left(
              event_categories!left(id, name, color_code, icon_name)
            )
          ''').eq('id', eventId).eq('status', 'active').single();

      // Verificar si el usuario está registrado
      bool isRegistered = false;
      if (userId != null) {
        final registration = await _client
            .from('event_registrations')
            .select('id')
            .eq('event_id', eventId)
            .eq('user_id', userId)
            .maybeSingle();

        isRegistered = registration != null;
      }

      // Obtener conteo de registros
      final registrationCountResponse = await _client
          .from('event_registrations')
          .select('count')
          .eq('event_id', eventId);

      final registrationCount = registrationCountResponse.isNotEmpty
          ? registrationCountResponse.first['count'] as int
          : 0;

      final categories = response['event_category_assignments'] != null
          ? (response['event_category_assignments'] as List)
              .where((assignment) => assignment['event_categories'] != null)
              .map((assignment) =>
                  assignment['event_categories']['name'] as String)
              .toList()
          : <String>[];

      return Event.fromJson({
        ...response,
        'categories': categories,
        'registration_count': registrationCount,
        'is_registered': isRegistered,
      });
    } catch (error) {
      throw Exception('Error al obtener el evento: $error');
    }
  }

  Future<List<EventCategory>> getEventCategories() async {
    try {
      final response = await _client
          .from('event_categories')
          .select()
          .order('name', ascending: true);

      return response
          .map<EventCategory>((json) => EventCategory.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Error al obtener categorías: $error');
    }
  }

  Future<void> _assignCategoriesToEvent(
      String eventId, List<String> categoryIds) async {
    final assignments = categoryIds
        .map((categoryId) => {
              'event_id': eventId,
              'category_id': categoryId,
            })
        .toList();

    await _client.from('event_category_assignments').insert(assignments);
  }
}

// Modelo para categorías de eventos
class EventCategory {
  final String id;
  final String name;
  final String? description;
  final String colorCode;
  final String? iconName;
  final bool isSystemCategory;
  final DateTime createdAt;

  EventCategory({
    required this.id,
    required this.name,
    this.description,
    required this.colorCode,
    this.iconName,
    required this.isSystemCategory,
    required this.createdAt,
  });

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      colorCode: json['color_code'] as String? ?? '#3B82F6',
      iconName: json['icon_name'] as String?,
      isSystemCategory: json['is_system_category'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Color get color => Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
}
