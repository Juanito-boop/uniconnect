import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/create_post_screen/create_post_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/main_feed_screen/main_feed_screen.dart';
import '../presentation/notifications_screen/notifications_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String createPost = '/create-post-screen';
  static const String login = '/login-screen';
  static const String mainFeed = '/main-feed-screen';
  static const String notifications = '/notifications-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    createPost: (context) => const CreatePostScreen(),
    login: (context) => const LoginScreen(),
    mainFeed: (context) => const MainFeedScreen(),
    notifications: (context) => const NotificationsScreen(),
    // TODO: Add your other routes here
  };
}
