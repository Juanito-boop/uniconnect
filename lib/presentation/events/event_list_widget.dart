import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../models/event.dart';
import '../../l10n/app_localizations.dart';

class EventListWidget extends StatelessWidget {
  final List<Event> events;
  final Function(Event)? onEventTap;

  const EventListWidget({
    Key? key,
    required this.events,
    this.onEventTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCardWidget(
          event: event,
          onTap: onEventTap,
        );
      },
    );
  }
}

class EventCardWidget extends StatelessWidget {
  final Event event;
  final Function(Event)? onTap;

  const EventCardWidget({
    Key? key,
    required this.event,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap?.call(event),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with type and date
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: event.eventType.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            event.eventType.icon,
                            color: event.eventType.color,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            event.eventType.displayName,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: event.eventType.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (event.isFeatured)
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
                            Icon(Icons.star,
                                size: 12.sp, color: Colors.amber[800]),
                            SizedBox(width: 1.w),
                            Text(
                              l10n.t('eventFeatured'),
                              style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Title
                Text(
                  event.title,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 1.h),

                // Date and time
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 1.w),
                    Text(
                      DateFormat('MMM d, yyyy • hh:mm a')
                          .format(event.eventDate),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 1.h),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        event.location,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (event.speakers.isNotEmpty) ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.mic, size: 16.sp, color: Colors.grey[600]),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          '${l10n.t('speakersPrefix')} ${event.speakers.join(', ')}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 2.h),

                // Content preview
                Text(
                  event.content,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 2.h),

                // Footer
                Row(
                  children: [
                    // Registration status
                    if (event.requiresRegistration)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: event.hasSpots ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.hasSpots
                              ? l10n.t('registeredCount').replaceFirst(
                                  '{count}', event.registrationCount.toString())
                              : l10n.t('eventFull'),
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Time until event
                    Text(
                      event.localizedTimeUntil(context),
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
