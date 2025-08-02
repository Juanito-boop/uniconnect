import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationFilterChipsWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Map<String, int> filterCounts;

  const NotificationFilterChipsWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.filterCounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filters = [
      {
        'key': 'all',
        'label': 'Todas',
        'icon': 'notifications',
      },
      {
        'key': 'post',
        'label': 'Publicaciones',
        'icon': 'article',
      },
      {
        'key': 'event',
        'label': 'Eventos',
        'icon': 'event',
      },
      {
        'key': 'emergency',
        'label': 'Emergencia',
        'icon': 'warning',
      },
      {
        'key': 'system',
        'label': 'Sistema',
        'icon': 'settings',
      },
    ];

    return Container(
      height: 6.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final String key = filter['key'] as String;
          final String label = filter['label'] as String;
          final String icon = filter['icon'] as String;
          final bool isSelected = selectedFilter == key;
          final int count = filterCounts[key] ?? 0;

          return GestureDetector(
            onTap: () => onFilterChanged(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: icon,
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : key == 'emergency'
                            ? AppTheme.lightTheme.colorScheme.error
                            : AppTheme.lightTheme.colorScheme.onSurface,
                    size: 4.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    label,
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (count > 0) ...[
                    SizedBox(width: 1.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 1.5.w, vertical: 0.2.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : key == 'emergency'
                                ? AppTheme.lightTheme.colorScheme.error
                                : AppTheme.lightTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 9.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
