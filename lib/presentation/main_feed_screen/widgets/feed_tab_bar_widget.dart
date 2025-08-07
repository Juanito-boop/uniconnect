import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FeedTabBarWidget extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;

  const FeedTabBarWidget({
    Key? key,
    required this.tabController,
    required this.tabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        tabs: tabs.map((tab) => _buildTab(tab)).toList(),
        labelColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        indicatorColor: AppTheme.lightTheme.colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle:
            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  Widget _buildTab(String tabName) {
    IconData iconData;
    String label;

    switch (tabName.toLowerCase()) {
      case 'feed':
        iconData = Icons.home;
        label = 'Feed';
        break;
      case 'events':
        iconData = Icons.event;
        label = 'Eventos';
        break;
      case 'search':
        iconData = Icons.search;
        label = 'Buscar';
        break;
      case 'profile':
        iconData = Icons.person;
        label = 'Perfil';
        break;
      default:
        iconData = Icons.info;
        label = tabName;
    }

    return Tab(
      height: 8.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 24,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
