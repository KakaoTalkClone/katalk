// lib/core/app_router.dart
import 'package:flutter/material.dart';

import '../features/home/home_tabs.dart';
import '../features/chatting_room/screens/chat_room_page.dart';
import '../features/friends/screens/friends_screen.dart';
import '../features/friends/screens/friend_profile_screen.dart';
import '../features/login/screens/login_screen.dart'; // New import
import '../features/friends/screens/user_search_screen.dart'; // Import for search screen

class AppRouter {
  static const initialRoute = '/login'; // Changed initial route

  static final routes = <String, WidgetBuilder>{
    '/': (_) => const HomeTabs(),
    '/login': (_) => const LoginScreen(), // New login route
    '/chat/room': (_) => ChatRoomPage(), // ← const 제거
    '/friends': (_) => const FriendsScreen(),
    '/friends/search': (_) => const UserSearchScreen(), // Route for user search
    '/friends/profile': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final isMyProfile = args['isMyProfile'] as bool? ?? false;
      final friendData = args['friendData'] as Map<String, dynamic>;
      return FriendProfileScreen(
        isMyProfile: isMyProfile,
        friendData: friendData,
      );
    },
  };
}
