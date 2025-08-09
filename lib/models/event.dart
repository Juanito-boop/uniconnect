import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum EventType {
  conference,
  fair,
  workshop,
  seminar,
  networking,
  cultural,
  general
}

extension EventTypeExtension on EventType {
  String get displayName {
    switch (this) {
      case EventType.conference:
        return 'Conferencia';
      case EventType.fair:
        return 'Feria';
      case EventType.workshop:
        return 'Taller';
      case EventType.seminar:
        return 'Seminario';
      case EventType.networking:
        return 'Networking';
      case EventType.cultural:
        return 'Cultural';
      case EventType.general:
        return 'General';
    }
  }

  IconData get icon {
    switch (this) {
      case EventType.conference:
        return Icons.mic;
      case EventType.fair:
        return Icons.store;
      case EventType.workshop:
        return Icons.build;
      case EventType.seminar:
        return Icons.school;
      case EventType.networking:
        return Icons.people;
      case EventType.cultural:
        return Icons.palette;
      case EventType.general:
        return Icons.event;
    }
  }

  Color get color {
    switch (this) {
      case EventType.conference:
        return Colors.blue;
      case EventType.fair:
        return Colors.orange;
      case EventType.workshop:
        return Colors.purple;
      case EventType.seminar:
        return Colors.green;
      case EventType.networking:
        return Colors.pink;
      case EventType.cultural:
        return Colors.amber;
      case EventType.general:
        return Colors.grey;
    }
  }
}

class Event {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String authorId;
  final String? authorName;
  final DateTime eventDate;
  final String location;
  final String? registrationUrl;
  final int maxAttendees;
  final EventType eventType;
  final bool requiresRegistration;
  final List<String> speakers;
  final String? agendaUrl;
  final bool isOnline;
  final String? meetingUrl;
  final bool isFeatured;
  final int viewCount;
  final int likeCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> categories;
  final bool isRegisteredByCurrentUser;
  final int registrationCount;

  Event({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.authorId,
    this.authorName,
    required this.eventDate,
    required this.location,
    this.registrationUrl,
    this.maxAttendees = 0,
    required this.eventType,
    this.requiresRegistration = false,
    this.speakers = const [],
    this.agendaUrl,
    this.isOnline = false,
    this.meetingUrl,
    this.isFeatured = false,
    this.viewCount = 0,
    this.likeCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.categories = const [],
    this.isRegisteredByCurrentUser = false,
    this.registrationCount = 0,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      location: json['location'] as String,
      registrationUrl: json['registration_url'] as String?,
      maxAttendees: json['max_attendees'] as int? ?? 0,
      eventType: _parseEventType(json['event_type'] as String),
      requiresRegistration: json['requires_registration'] as bool? ?? false,
      speakers: List<String>.from(json['speakers'] ?? []),
      agendaUrl: json['agenda_url'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      meetingUrl: json['meeting_url'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
      isRegisteredByCurrentUser: json['is_registered'] as bool? ?? false,
      registrationCount: json['registration_count'] as int? ?? 0,
    );
  }

  static EventType _parseEventType(String type) {
    return EventType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => EventType.general,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'author_id': authorId,
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
      'view_count': viewCount,
      'like_count': likeCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? content,
    String? imageUrl,
    String? authorId,
    String? authorName,
    DateTime? eventDate,
    String? location,
    String? registrationUrl,
    int? maxAttendees,
    EventType? eventType,
    bool? requiresRegistration,
    List<String>? speakers,
    String? agendaUrl,
    bool? isOnline,
    String? meetingUrl,
    bool? isFeatured,
    int? viewCount,
    int? likeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? categories,
    bool? isRegisteredByCurrentUser,
    int? registrationCount,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      registrationUrl: registrationUrl ?? this.registrationUrl,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      eventType: eventType ?? this.eventType,
      requiresRegistration: requiresRegistration ?? this.requiresRegistration,
      speakers: speakers ?? this.speakers,
      agendaUrl: agendaUrl ?? this.agendaUrl,
      isOnline: isOnline ?? this.isOnline,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categories: categories ?? this.categories,
      isRegisteredByCurrentUser:
          isRegisteredByCurrentUser ?? this.isRegisteredByCurrentUser,
      registrationCount: registrationCount ?? this.registrationCount,
    );
  }

  String localizedTimeUntil(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = eventDate.difference(now);

    if (difference.isNegative) {
      return l10n.t('eventEnded');
    } else if (difference.inDays > 7) {
      return l10n
          .t('eventInDays')
          .replaceFirst('{days}', difference.inDays.toString());
    } else if (difference.inDays > 0) {
      return l10n
          .t('eventInShort')
          .replaceFirst('{days}', difference.inDays.toString())
          .replaceFirst('{hours}', (difference.inHours % 24).toString());
    } else if (difference.inHours > 0) {
      return l10n
          .t('eventInHours')
          .replaceFirst('{hours}', difference.inHours.toString())
          .replaceFirst('{minutes}', (difference.inMinutes % 60).toString());
    } else {
      return l10n.t('eventSoon');
    }
  }

  bool get isFull => maxAttendees > 0 && registrationCount >= maxAttendees;
  bool get hasSpots => !isFull || maxAttendees == 0;
}
