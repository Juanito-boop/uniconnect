import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../models/event.dart';
import '../../services/events_service.dart';
import 'event_calendar_widget.dart';
import 'event_list_widget.dart';
import '../../l10n/app_localizations.dart';

class EventsTabWidget extends StatefulWidget {
  final Function(Event)? onEventTap;

  const EventsTabWidget({
    Key? key,
    this.onEventTap,
  }) : super(key: key);

  @override
  State<EventsTabWidget> createState() => _EventsTabWidgetState();
}

class _EventsTabWidgetState extends State<EventsTabWidget>
    with SingleTickerProviderStateMixin {
  late TabController _eventsTabController;
  List<Event> _events = [];
  bool _isLoading = true;
  String _error = '';
  EventType? _selectedType;
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    _eventsTabController = TabController(length: 2, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _eventsTabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final events = await EventsService.instance.getEvents(
        upcomingOnly: true,
        type: _selectedType,
      );

      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildEventsHeader() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.t('eventsHeader'),
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _showCalendar ? Icons.list : Icons.calendar_today,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      setState(() => _showCalendar = !_showCalendar);
                      HapticFeedback.lightImpact();
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildEventTypesFilter(),
        ],
      ),
    );
  }

  Widget _buildEventTypesFilter() {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 5.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTypeChip(l10n.t('eventsAll'), null),
          ...EventType.values
              .map((type) => _buildTypeChip(type.displayName, type)),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, EventType? type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _loadEvents();
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: EdgeInsets.only(right: 2.w),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEventsContent() {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            SizedBox(height: 2.h),
            Text(l10n.t('eventsError'),
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Text(_error, style: GoogleFonts.inter(color: Colors.grey[600])),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: _loadEvents,
              child: Text(l10n.t('retry')),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            SizedBox(height: 2.h),
            Text(
              l10n.t('eventsNoUpcoming'),
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              l10n.t('eventsCheckLater'),
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: _showCalendar
          ? EventCalendarWidget(
              events: _events,
              onEventTap: widget.onEventTap,
              showNavigationButtons: true,
            )
          : EventListWidget(
              events: _events,
              onEventTap: widget.onEventTap,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildEventsHeader(),
        Expanded(
          child: _buildEventsContent(),
        ),
      ],
    );
  }
}
