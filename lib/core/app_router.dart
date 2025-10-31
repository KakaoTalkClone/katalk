// lib/core/app_router.dart
import 'package:flutter/material.dart';

import '../features/home/home_tabs.dart';
import '../features/chatting_room/screens/chat_room_page.dart';

import '../features/friends/screens/friends_screen.dart';
import '../features/friends/screens/friend_profile_screen.dart';

class AppRouter {
  static const initialRoute = '/';

  static final routes = <String, WidgetBuilder>{
    '/': (_) => const HomeTabs(),
    '/chat/room': (_) => ChatRoomPage(), // ← const 제거
    '/friends': (_) => const FriendsScreen(),
    '/friends/profile': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, bool>?;
      final isMyProfile = args?['isMyProfile'] ?? false;
      return FriendProfileScreen(isMyProfile: isMyProfile);
    },
  };
}
