import 'package:flutter/material.dart';
import '../features/friends/screens/friend_profile_screen.dart';
import '../features/friends/screens/friends_screen.dart';
import '../features/home/home_tabs.dart';

class AppRouter {
  static const initialRoute = '/';
  static final routes = <String, WidgetBuilder>{
    '/': (_) => const HomeTabs(),
    '/friends': (_) => const FriendsScreen(),
    '/friends/profile': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, bool>?;
      final isMyProfile = args?['isMyProfile'] ?? false;
      return FriendProfileScreen(isMyProfile: isMyProfile);
    },
  };
}
