import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_notifications_widget.dart';
import './widgets/notification_card_widget.dart';
import './widgets/notification_filter_chips_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'all';
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock notifications data
  final List<Map<String, dynamic>> _allNotifications = [
    {
      "id": 1,
      "type": "emergency",
      "senderName": "Seguridad Campus",
      "senderAvatar":
          "https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&h=400&fit=crop&crop=face",
      "title": "Alerta de Seguridad",
      "message":
          "Se ha reportado actividad sospechosa en el edificio de ciencias. Evita el área hasta nuevo aviso.",
      "timestamp": DateTime.now().subtract(Duration(minutes: 15)),
      "isRead": false,
    },
    {
      "id": 2,
      "type": "event",
      "senderName": "Eventos Universitarios",
      "senderAvatar":
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face",
      "title": "Conferencia de Tecnología",
      "message":
          "Únete a nosotros mañana a las 14:00 en el auditorio principal para una conferencia sobre inteligencia artificial.",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "isRead": false,
    },
    {
      "id": 3,
      "type": "post",
      "senderName": "Dr. María González",
      "senderAvatar":
          "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop&crop=face",
      "title": "Nueva publicación",
      "message":
          "He compartido material adicional para el examen de matemáticas avanzadas. Revisen la plataforma.",
      "timestamp": DateTime.now().subtract(Duration(hours: 4)),
      "isRead": true,
    },
    {
      "id": 4,
      "type": "rsvp",
      "senderName": "Club de Debate",
      "senderAvatar":
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face",
      "title": "Confirmación RSVP",
      "message":
          "Tu inscripción al torneo de debate del viernes ha sido confirmada. ¡Te esperamos!",
      "timestamp": DateTime.now().subtract(Duration(hours: 6)),
      "isRead": true,
    },
    {
      "id": 5,
      "type": "system",
      "senderName": "Sistema UniConnect",
      "senderAvatar": null,
      "title": "Actualización de la aplicación",
      "message":
          "Nueva versión disponible con mejoras en el rendimiento y corrección de errores.",
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
      "isRead": false,
    },
    {
      "id": 6,
      "type": "event",
      "senderName": "Biblioteca Central",
      "senderAvatar":
          "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face",
      "title": "Horario Extendido",
      "message":
          "Durante la semana de exámenes, la biblioteca estará abierta 24 horas.",
      "timestamp": DateTime.now().subtract(Duration(days: 2)),
      "isRead": true,
    },
    {
      "id": 7,
      "type": "post",
      "senderName": "Coordinación Académica",
      "senderAvatar":
          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop&crop=face",
      "title": "Cambio de horario",
      "message":
          "La clase de Historia del Arte del martes se ha movido al aula 205. Confirmen su asistencia.",
      "timestamp": DateTime.now().subtract(Duration(days: 3)),
      "isRead": true,
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'all') {
      return _allNotifications;
    }
    return _allNotifications
        .where((notification) => notification['type'] == _selectedFilter)
        .toList();
  }

  Map<String, int> get _filterCounts {
    final Map<String, int> counts = {
      'all': _allNotifications.length,
      'post': 0,
      'event': 0,
      'emergency': 0,
      'system': 0,
      'rsvp': 0,
    };

    for (final notification in _allNotifications) {
      final type = notification['type'] as String;
      counts[type] = (counts[type] ?? 0) + 1;
    }

    return counts;
  }

  int get _unreadCount {
    return _allNotifications
        .where((notification) => !(notification['isRead'] as bool? ?? false))
        .length;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(90),
      child: Container(
        color: AppTheme.lightTheme.colorScheme.surface,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: EdgeInsets.only(left: 2.w, top: 16),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
              ),
            ),
            // Icon + badge + title + subtitle
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 2.w, top: 12, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CustomIconWidget(
                              iconName: 'notifications',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 8.w,
                            ),
                            if (_unreadCount > 0)
                              Positioned(
                                right: -2,
                                top: -4,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 1.5.w, vertical: 0.2.h),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.lightTheme.colorScheme.error,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                  ),
                                  child: Text(
                                    _unreadCount > 99
                                        ? '99+'
                                        : _unreadCount.toString(),
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onError,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Notificaciones',
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (_unreadCount > 0)
                          Padding(
                            padding: EdgeInsets.only(left: 2.w),
                            child: TextButton(
                              onPressed: _markAllAsRead,
                              child: Text(
                                'Marcar todas',
                                style: AppTheme.lightTheme.textTheme.labelMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: _showNotificationSettings,
                          icon: CustomIconWidget(
                            iconName: 'settings',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 6.w,
                          ),
                        ),
                      ],
                    ),
                    if (_unreadCount > 0)
                      Padding(
                        padding: EdgeInsets.only(left: 1.5.w, top: 2),
                        child: Text(
                          '$_unreadCount sin leer',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return NotificationFilterChipsWidget(
      selectedFilter: _selectedFilter,
      onFilterChanged: (filter) {
        setState(() {
          _selectedFilter = filter;
        });
        HapticFeedback.lightImpact();
      },
      filterCounts: _filterCounts,
    );
  }

  Widget _buildNotificationsList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }

    final filteredNotifications = _filteredNotifications;

    if (filteredNotifications.isEmpty) {
      return EmptyNotificationsWidget(filterType: _selectedFilter);
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = filteredNotifications[index];
          return NotificationCardWidget(
            notification: notification,
            onTap: () => _onNotificationTap(notification),
            onMarkAsRead: () => _markAsRead(notification['id'] as int),
            onDelete: () => _deleteNotification(notification['id'] as int),
          );
        },
      ),
    );
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notificaciones actualizadas'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    final String type = notification['type'] as String;
    final int id = notification['id'] as int;

    // Mark as read when tapped
    _markAsRead(id);

    // Navigate based on notification type
    switch (type) {
      case 'post':
        Navigator.pushNamed(context, '/post-detail-screen');
        break;
      case 'event':
        Navigator.pushNamed(context, '/main-feed-screen');
        break;
      case 'emergency':
        _showEmergencyDetails(notification);
        break;
      case 'system':
        _showSystemUpdate(notification);
        break;
      case 'rsvp':
        Navigator.pushNamed(context, '/main-feed-screen');
        break;
      default:
        Navigator.pushNamed(context, '/main-feed-screen');
    }
  }

  void _markAsRead(int notificationId) {
    setState(() {
      final index =
          _allNotifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _allNotifications[index]['isRead'] = true;
      }
    });
    HapticFeedback.selectionClick();
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _allNotifications) {
        notification['isRead'] = true;
      }
    });
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Todas las notificaciones marcadas como leídas'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteNotification(int notificationId) {
    setState(() {
      _allNotifications.removeWhere((n) => n['id'] == notificationId);
    });
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notificación eliminada'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            // In a real app, you would restore the notification here
          },
        ),
      ),
    );
  }

  void _showEmergencyDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                notification['title'] as String? ?? 'Alerta de Emergencia',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          notification['message'] as String? ?? '',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/main-feed-screen');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Ver más detalles'),
          ),
        ],
      ),
    );
  }

  void _showSystemUpdate(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'system_update',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                notification['title'] as String? ?? 'Actualización del Sistema',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['message'] as String? ?? '',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              'Características nuevas:',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              '• Mejor rendimiento en la carga de imágenes\n• Corrección de errores menores\n• Nuevas opciones de notificación',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Más tarde'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would trigger the update
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Actualización iniciada'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Actualizar ahora'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        height: 60.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              margin: EdgeInsets.only(bottom: 2.h),
              alignment: Alignment.center,
            ),
            Text(
              'Configuración de Notificaciones',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: ListView(
                children: [
                  _buildSettingTile(
                    'Publicaciones',
                    'Recibir notificaciones de nuevas publicaciones',
                    'article',
                    true,
                  ),
                  _buildSettingTile(
                    'Eventos',
                    'Notificaciones sobre eventos del campus',
                    'event',
                    true,
                  ),
                  _buildSettingTile(
                    'Alertas de Emergencia',
                    'Alertas importantes de seguridad (no se pueden desactivar)',
                    'warning',
                    true,
                    enabled: false,
                  ),
                  _buildSettingTile(
                    'Actualizaciones del Sistema',
                    'Cambios en la aplicación',
                    'settings',
                    false,
                  ),
                  _buildSettingTile(
                    'Confirmaciones RSVP',
                    'Confirmaciones de eventos',
                    'event_available',
                    true,
                  ),
                  SizedBox(height: 2.h),
                  Divider(),
                  SizedBox(height: 2.h),
                  Text(
                    'Configuración Avanzada',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  _buildSettingTile(
                    'Horario Silencioso',
                    '22:00 - 08:00',
                    'bedtime',
                    true,
                  ),
                  _buildSettingTile(
                    'Vibración',
                    'Vibrar al recibir notificaciones',
                    'vibration',
                    true,
                  ),
                  _buildSettingTile(
                    'Sonido',
                    'Reproducir sonido de notificación',
                    'volume_up',
                    true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    String icon,
    bool value, {
    bool enabled = true,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: enabled
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 5.w,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: enabled
              ? AppTheme.lightTheme.colorScheme.onSurface
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: enabled
              ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.6),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: enabled
            ? (newValue) {
                HapticFeedback.selectionClick();
                // Handle switch change
              }
            : null,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 1.h),
    );
  }
}
