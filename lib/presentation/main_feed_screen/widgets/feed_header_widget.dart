import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FeedHeaderWidget extends StatelessWidget {
  final int unreadNotifications;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onLogoTap;

  const FeedHeaderWidget({
    Key? key,
    this.unreadNotifications = 0,
    this.onNotificationTap,
    this.onLogoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2)),
            ]),
        child: SafeArea(
            bottom: false,
            child: Row(children: [
              GestureDetector(
                  onTap: onLogoTap,
                  child: Row(children: [
                    _buildUniversityLogo(),
                    SizedBox(width: 3.w),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UniConnect',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary)),
                          Text('Universidad Central',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 10.sp)),
                        ]),
                  ])),
              const Spacer(),
              _buildNotificationButton(),
            ])));
  }

  Widget _buildUniversityLogo() {
    return Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.tertiary,
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ]),
        child: Center(
            child: Text('UC',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5))));
  }

  Widget _buildNotificationButton() {
    return GestureDetector(
        onTap: onNotificationTap,
        child: Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12)),
            child: Stack(children: [
              CustomIconWidget(
                  iconName: 'notifications',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24),
              if (unreadNotifications > 0)
                Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                        padding: EdgeInsets.all(0.5.w),
                        decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.error,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    AppTheme.lightTheme.colorScheme.surface)),
                        child: Center(
                            child: Text(
                                unreadNotifications > 99
                                    ? '99+'
                                    : unreadNotifications.toString(),
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 8.sp))))),
            ])));
  }
}
