import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyNotificationsWidget extends StatelessWidget {
  final String filterType;

  const EmptyNotificationsWidget({
    Key? key,
    required this.filterType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> emptyStateConfig =
        _getEmptyStateConfig(filterType);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: emptyStateConfig['icon'] as String,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 15.w,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              emptyStateConfig['title'] as String,
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              emptyStateConfig['subtitle'] as String,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/main-feed-screen'),
          icon: CustomIconWidget(
            iconName: 'home',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 5.w,
          ),
          label: Text('Ver Feed Principal'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        OutlinedButton.icon(
          onPressed: () => _showNotificationSettings(context),
          icon: CustomIconWidget(
            iconName: 'settings',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 5.w,
          ),
          label: Text('Configurar Notificaciones'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getEmptyStateConfig(String filterType) {
    switch (filterType) {
      case 'post':
        return {
          'icon': 'article',
          'title': 'No hay publicaciones nuevas',
          'subtitle':
              'Cuando haya nuevas publicaciones de la universidad, aparecerán aquí.',
        };
      case 'event':
        return {
          'icon': 'event',
          'title': 'No hay eventos próximos',
          'subtitle': 'Te notificaremos sobre eventos importantes del campus.',
        };
      case 'emergency':
        return {
          'icon': 'warning',
          'title': 'No hay alertas de emergencia',
          'subtitle':
              'Las alertas importantes aparecerán aquí para mantenerte informado.',
        };
      case 'system':
        return {
          'icon': 'settings',
          'title': 'No hay actualizaciones del sistema',
          'subtitle':
              'Te informaremos sobre cambios importantes en la aplicación.',
        };
      default:
        return {
          'icon': 'notifications_none',
          'title': 'No tienes notificaciones',
          'subtitle':
              'Mantente conectado con las actividades del campus. Las notificaciones aparecerán aquí.',
        };
    }
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        height: 50.h,
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
                    'Alertas importantes de seguridad',
                    'warning',
                    true,
                  ),
                  _buildSettingTile(
                    'Actualizaciones del Sistema',
                    'Cambios en la aplicación',
                    'settings',
                    false,
                  ),
                  SizedBox(height: 2.h),
                  Divider(),
                  SizedBox(height: 2.h),
                  _buildSettingTile(
                    'Horario Silencioso',
                    '22:00 - 08:00',
                    'bedtime',
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
      String title, String subtitle, String icon, bool value) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 5.w,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall,
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          // Handle switch change
        },
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 1.h),
    );
  }
}
