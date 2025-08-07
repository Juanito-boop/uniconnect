import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../models/event.dart';
import '../../services/events_service.dart';
import 'event_calendar_widget.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Event> _events = [];
  bool _isLoading = true;
  String _error = '';
  EventType? _selectedType;
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final events = await EventsService.instance.getEvents(
        upcomingOnly: false,
        type: _selectedType,
        startDate: _selectedRange?.start,
        endDate: _selectedRange?.end,
        limit: 100,
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

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (range != null) {
      setState(() {
        _selectedRange = range;
        _loadEvents();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Event Calendar',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _selectDateRange,
            tooltip: 'Filter by date range',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                      SizedBox(height: 2.h),
                      Text('Error: $_error'),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: _loadEvents,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Text(
                            '${_events.length} Events',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedRange != null) ...[
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                '(${DateFormat('MMM dd').format(_selectedRange!.start)} - ${DateFormat('MMM dd').format(_selectedRange!.end)})',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: EventCalendarWidget(
                        events: _events,
                        onEventTap: (event) {
                          Navigator.pushNamed(
                            context,
                            '/event-detail-screen',
                            arguments: event,
                          );
                        },
                        showNavigationButtons: true,
                      ),
                    ),
                  ],
                ),
    );
  }
}