import 'package:flutter/material.dart';
import 'package:uniconnect/models/event.dart';
import 'package:uniconnect/presentation/create_event_screen/create_event_screen.dart';
import 'package:uniconnect/presentation/events/calendar_screen.dart';
import 'package:uniconnect/presentation/events/event_detail_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/create_post_screen/create_post_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/main_feed_screen/main_feed_screen.dart';
import '../presentation/notifications_screen/notifications_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String createPost = '/create-post-screen';
  static const String createEvent = '/create-event-screen'; // Nuevo
  static const String login = '/login-screen';
  static const String mainFeed = '/main-feed-screen';
  static const String notifications = '/notifications-screen';
  static const String eventDetail = '/event-detail-screen'; // Nuevo
  static const String calendar = '/calendar-screen'; // Nuevo

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    createPost: (context) => const CreatePostScreen(),
    createEvent: (context) => const CreateEventScreen(), // Nuevo
    login: (context) => const LoginScreen(),
    mainFeed: (context) => const MainFeedScreen(),
    notifications: (context) => const NotificationsScreen(),
    eventDetail: (context) => EventDetailScreen(event: ModalRoute.of(context)!.settings.arguments as Event,), // Nuevo
    calendar: (context) => const CalendarScreen(), // Nuevo
  };
}
