import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/event.dart';
import '../../services/events_service.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Event _event;
  bool _isLoading = false;
  bool _isProcessingRegistration = false;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    // In a real app, you would refresh the event data here
    // For now, we'll use the passed event
  }

  Future<void> _handleRegistration() async {
    if (!_event.requiresRegistration) return;

    setState(() => _isProcessingRegistration = true);

    try {
      if (_event.isRegisteredByCurrentUser) {
        await EventsService.instance.cancelRegistration(_event.id);
        setState(() {
          _event = _event.copyWith(
            isRegisteredByCurrentUser: false,
            registrationCount: _event.registrationCount - 1,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        await EventsService.instance.registerForEvent(_event.id);
        setState(() {
          _event = _event.copyWith(
            isRegisteredByCurrentUser: true,
            registrationCount: _event.registrationCount + 1,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessingRegistration = false);
    }
  }

  void _shareEvent() {
    final shareText = '''
      🎓 ${_event.title}
      📅 ${DateFormat('MMM dd, yyyy - HH:mm').format(_event.eventDate)}
      📍 ${_event.location}
      ${_event.registrationUrl != null ? '🔗 ${_event.registrationUrl}' : ''}
    ''';
    Share.share(shareText);
  }

  void _addToCalendar() {
    // This would integrate with device calendar in a real app
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to calendar (feature coming soon)'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildEventImage() {
    return Container(
      height: 25.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _event.eventType.color.withAlpha(100),
        image: _event.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(_event.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: _event.imageUrl == null
          ? Center(
              child: Icon(
                _event.eventType.icon,
                size: 60,
                color: _event.eventType.color,
              ),
            )
          : null,
    );
  }

  Widget _buildEventHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _event.eventType.color.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _event.eventType.icon,
                  color: _event.eventType.color,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                _event.eventType.displayName,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _event.eventType.color,
                ),
              ),
              if (_event.isFeatured) ...[
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 12.sp, color: Colors.amber[800]),
                      SizedBox(width: 1.w),
                      Text(
                        'Featured',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            _event.title,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'By ${_event.authorName ?? 'University'}',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem(
            Icons.calendar_today,
            'Date & Time',
            DateFormat('EEEE, MMMM dd, yyyy - HH:mm').format(_event.eventDate),
          ),
          _buildDetailItem(
            Icons.location_on,
            'Location',
            _event.location,
          ),
          if (_event.isOnline && _event.meetingUrl != null) ...[
            _buildDetailItem(
              Icons.video_call,
              'Meeting URL',
              _event.meetingUrl!,
              isLink: true,
            ),
          ],
          if (_event.speakers.isNotEmpty) ...[
            _buildDetailItem(
              Icons.people,
              'Speakers',
              _event.speakers.join(', '),
            ),
          ],
          if (_event.agendaUrl != null) ...[
            _buildDetailItem(
              Icons.description,
              'Agenda',
              'View detailed agenda',
              isLink: true,
              url: _event.agendaUrl,
            ),
          ],
          _buildDetailItem(
            Icons.visibility,
            'Views',
            '${_event.viewCount} views',
          ),
          if (_event.requiresRegistration) ...[
            _buildDetailItem(
              Icons.people,
              'Registration',
              '${_event.registrationCount} / ${_event.maxAttendees > 0 ? _event.maxAttendees : '∞'} registered',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
    String? url,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this event',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _event.content,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          if (_event.requiresRegistration) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _event.hasSpots || _event.isRegisteredByCurrentUser
                    ? _handleRegistration
                    : null,
                icon: _isProcessingRegistration
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        _event.isRegisteredByCurrentUser
                            ? Icons.cancel
                            : Icons.event_available,
                      ),
                label: Text(
                  _event.isRegisteredByCurrentUser
                      ? 'Cancel Registration'
                      : _event.isFull
                          ? 'Event Full'
                          : 'Register',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _event.isRegisteredByCurrentUser
                      ? Colors.orange
                      : _event.isFull
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareEvent,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addToCalendar,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 30.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildEventImage(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareEvent,
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildEventHeader(),
              _buildEventDetails(),
              const Divider(height: 1),
              _buildDescription(),
              const Divider(height: 1),
              _buildActionButtons(),
            ]),
          ),
        ],
      ),
    );
  }
}
