import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PostCategoryWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const PostCategoryWidget({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  static const Map<String, Map<String, dynamic>> categories = {
    'Académico': {
      'color': Color(0xFF2B5CE6),
      'icon': 'school',
    },
    'Social': {
      'color': Color(0xFF8B5CF6),
      'icon': 'people',
    },
    'Deportes': {
      'color': Color(0xFF10B981),
      'icon': 'sports_soccer',
    },
    'Emergencia': {
      'color': Color(0xFFEF4444),
      'icon': 'warning',
    },
    'General': {
      'color': Color(0xFF6B7280),
      'icon': 'info',
    },
  };

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
                iconName: 'category',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Categoría del evento',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          DropdownButtonFormField<String>(
            value: selectedCategory.isNotEmpty ? selectedCategory : null,
            decoration: InputDecoration(
              hintText: 'Seleccionar categoría',
              prefixIcon: selectedCategory.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: categories[selectedCategory]!['icon'],
                        color: categories[selectedCategory]!['color'],
                        size: 20,
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'category',
                        color: AppTheme.lightTheme.colorScheme.outline,
                        size: 20,
                      ),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            items: categories.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: entry.value['icon'],
                      color: entry.value['color'],
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      entry.key,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: entry.value['color'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                onCategoryChanged(value);
              }
            },
            dropdownColor: AppTheme.lightTheme.colorScheme.surface,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          if (selectedCategory.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: categories[selectedCategory]!['color']
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: categories[selectedCategory]!['color']
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: categories[selectedCategory]!['icon'],
                    color: categories[selectedCategory]!['color'],
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    selectedCategory,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: categories[selectedCategory]!['color'],
                      fontWeight: FontWeight.w600,
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
}
