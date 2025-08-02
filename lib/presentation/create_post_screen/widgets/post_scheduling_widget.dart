import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PostSchedulingWidget extends StatelessWidget {
  final bool isScheduled;
  final DateTime? scheduledDate;
  final Function(bool) onScheduleToggle;
  final Function(DateTime) onDateTimeChanged;

  const PostSchedulingWidget({
    Key? key,
    required this.isScheduled,
    this.scheduledDate,
    required this.onScheduleToggle,
    required this.onDateTimeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Programar publicación',
                  style: AppTheme.lightTheme.textTheme.titleSmall,
                ),
              ),
              Switch(
                value: isScheduled,
                onChanged: onScheduleToggle,
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              ),
            ],
          ),
          if (isScheduled) ...[
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha y hora de publicación',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: CustomIconWidget(
                            iconName: 'calendar_today',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 18,
                          ),
                          label: Text(
                            scheduledDate != null
                                ? '${scheduledDate!.day.toString().padLeft(2, '0')}/${scheduledDate!.month.toString().padLeft(2, '0')}/${scheduledDate!.year}'
                                : 'Seleccionar fecha',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectTime(context),
                          icon: CustomIconWidget(
                            iconName: 'access_time',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 18,
                          ),
                          label: Text(
                            scheduledDate != null
                                ? '${scheduledDate!.hour.toString().padLeft(2, '0')}:${scheduledDate!.minute.toString().padLeft(2, '0')}'
                                : 'Seleccionar hora',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (scheduledDate != null) ...[
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'info',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Se publicará el ${_formatDateTime(scheduledDate!)}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'flash_on',
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Se publicará inmediatamente',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: scheduledDate ?? DateTime.now().add(Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final currentTime =
          scheduledDate ?? DateTime.now().add(Duration(hours: 1));
      final newDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        currentTime.hour,
        currentTime.minute,
      );
      onDateTimeChanged(newDateTime);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: scheduledDate != null
          ? TimeOfDay.fromDateTime(scheduledDate!)
          : TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 1))),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final currentDate =
          scheduledDate ?? DateTime.now().add(Duration(hours: 1));
      final newDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        picked.hour,
        picked.minute,
      );
      onDateTimeChanged(newDateTime);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];

    return '${dateTime.day} de ${months[dateTime.month - 1]} de ${dateTime.year} a las ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
