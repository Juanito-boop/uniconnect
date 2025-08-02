import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationCardWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCardWidget({
    Key? key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification['isRead'] as bool? ?? false;
    final String type = notification['type'] as String? ?? 'post';
    final bool isEmergency = type == 'emergency';

    return Dismissible(
      key: Key(notification['id'].toString()),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomIconWidget(
          iconName: 'mark_email_read',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 6.w,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomIconWidget(
          iconName: 'delete',
          color: AppTheme.lightTheme.colorScheme.error,
          size: 6.w,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onMarkAsRead?.call();
          return false;
        } else {
          return await _showDeleteConfirmation(context);
        }
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isEmergency
                ? AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.05)
                : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEmergency
                  ? AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3)
                  : isRead
                      ? Colors.transparent
                      : AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.3),
              width: isEmergency ? 2 : (isRead ? 0 : 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 1.h),
                    _buildContent(),
                    SizedBox(height: 1.h),
                    _buildFooter(),
                  ],
                ),
              ),
              if (!isRead) _buildUnreadIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final String? avatarUrl = notification['senderAvatar'] as String?;
    final String type = notification['type'] as String? ?? 'post';

    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: type == 'emergency'
              ? AppTheme.lightTheme.colorScheme.error
              : AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? CustomImageWidget(
                imageUrl: avatarUrl,
                width: 12.w,
                height: 12.w,
                fit: BoxFit.cover,
              )
            : Container(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                child: CustomIconWidget(
                  iconName: _getTypeIcon(type),
                  color: type == 'emergency'
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    final String senderName =
        notification['senderName'] as String? ?? 'Universidad';
    final String type = notification['type'] as String? ?? 'post';
    final bool isEmergency = type == 'emergency';

    return Row(
      children: [
        Expanded(
          child: Text(
            senderName,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isEmergency
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 2.w),
        _buildTypeChip(type),
      ],
    );
  }

  Widget _buildTypeChip(String type) {
    final Map<String, dynamic> typeConfig = _getTypeConfig(type);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: (typeConfig['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        typeConfig['label'] as String,
        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          color: typeConfig['color'] as Color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildContent() {
    final String title = notification['title'] as String? ?? '';
    final String message = notification['message'] as String? ?? '';
    final bool isRead = notification['isRead'] as bool? ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        if (title.isNotEmpty && message.isNotEmpty) SizedBox(height: 0.5.h),
        if (message.isNotEmpty)
          Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildFooter() {
    final DateTime timestamp =
        notification['timestamp'] as DateTime? ?? DateTime.now();
    final String timeAgo = _getTimeAgo(timestamp);

    return Row(
      children: [
        CustomIconWidget(
          iconName: 'access_time',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 4.w,
        ),
        SizedBox(width: 1.w),
        Text(
          timeAgo,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildUnreadIndicator() {
    return Container(
      width: 2.w,
      height: 2.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        shape: BoxShape.circle,
      ),
    );
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'post':
        return 'article';
      case 'event':
        return 'event';
      case 'emergency':
        return 'warning';
      case 'system':
        return 'settings';
      case 'rsvp':
        return 'event_available';
      default:
        return 'notifications';
    }
  }

  Map<String, dynamic> _getTypeConfig(String type) {
    switch (type) {
      case 'post':
        return {
          'label': 'Publicación',
          'color': AppTheme.lightTheme.colorScheme.primary,
        };
      case 'event':
        return {
          'label': 'Evento',
          'color': AppTheme.lightTheme.colorScheme.tertiary,
        };
      case 'emergency':
        return {
          'label': 'Emergencia',
          'color': AppTheme.lightTheme.colorScheme.error,
        };
      case 'system':
        return {
          'label': 'Sistema',
          'color': AppTheme.lightTheme.colorScheme.secondary,
        };
      case 'rsvp':
        return {
          'label': 'RSVP',
          'color': Colors.green,
        };
      default:
        return {
          'label': 'General',
          'color': AppTheme.lightTheme.colorScheme.secondary,
        };
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'hace ${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Eliminar notificación',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            content: Text(
              '¿Estás seguro de que quieres eliminar esta notificación?',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  onDelete?.call();
                },
                child: Text(
                  'Eliminar',
                  style:
                      TextStyle(color: AppTheme.lightTheme.colorScheme.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'mark_email_read',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Marcar como leída'),
              onTap: () {
                Navigator.pop(context);
                onMarkAsRead?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 6.w,
              ),
              title: Text('Eliminar'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context).then((confirmed) {
                  if (confirmed) onDelete?.call();
                });
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 6.w,
              ),
              title: Text('Configuración de notificaciones'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to notification settings
              },
            ),
          ],
        ),
      ),
    );
  }
}
