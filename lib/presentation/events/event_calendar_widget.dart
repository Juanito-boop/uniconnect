import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';

class EventCalendarWidget extends StatefulWidget {
  final List<Event> events;
  final Function(Event)? onEventTap;
  final DateTime? initialDate;

  const EventCalendarWidget({
    Key? key,
    required this.events,
    this.onEventTap,
    this.initialDate, required bool showNavigationButtons,
  }) : super(key: key);

  @override
  State<EventCalendarWidget> createState() => _EventCalendarWidgetState();
}

class _EventCalendarWidgetState extends State<EventCalendarWidget> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late final Map<DateTime, List<Event>> _eventsMap;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate ?? DateTime.now();
    _selectedDay = widget.initialDate ?? DateTime.now();
    _eventsMap = _groupEventsByDate(widget.events);
  }

  Map<DateTime, List<Event>> _groupEventsByDate(List<Event> events) {
    final Map<DateTime, List<Event>> map = {};

    for (final event in events) {
      final date = DateTime(
        event.eventDate.year,
        event.eventDate.month,
        event.eventDate.day,
      );

      if (map[date] == null) {
        map[date] = [];
      }
      map[date]!.add(event);
    }

    return map;
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _eventsMap[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCalendarHeader(),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar<Event>(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(color: Colors.red),
                outsideDaysVisible: false,
                cellPadding: const EdgeInsets.all(6),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        events.length.clamp(0, 3),
                        (index) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: events[index].eventType.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, date, events) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_getEventsForDay(_selectedDay ?? DateTime.now()).isNotEmpty)
            Container(
              padding: EdgeInsets.all(4.w),
              child: Text(
                'Events on ${DateFormat('MMM d, yyyy').format(_selectedDay ?? DateTime.now())}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          Container(
            height: 200, // Altura fija para la lista de eventos
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _getEventsForDay(_selectedDay ?? DateTime.now()).length,
              itemBuilder: (context, index) {
                final event =
                    _getEventsForDay(_selectedDay ?? DateTime.now())[index];
                return CalendarEventCard(
                  event: event,
                  onTap: widget.onEventTap,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Event Calendar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            '${_getEventsForDay(_focusedDay).length} events',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ],
      ),
    );
  }
}

class CalendarEventCard extends StatelessWidget {
  final Event event;
  final Function(Event)? onTap;

  const CalendarEventCard({
    Key? key,
    required this.event,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 1.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: event.eventType.color,
          child: Icon(
            event.eventType.icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          event.title,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${event.timeUntilEvent} • ${event.location}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: event.requiresRegistration
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: event.hasSpots ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.hasSpots ? 'Open' : 'Full',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              )
            : null,
        onTap: () => onTap?.call(event),
      ),
    );
  }
}
