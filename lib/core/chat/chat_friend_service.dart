// lib/core/chat/chat_friend_service.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'chat_friend_cache.dart';

class ChatFriendService {
  ChatFriendService._();
  static final ChatFriendService instance = ChatFriendService._();

  final _storage = const FlutterSecureStorage();

  Future<void> loadFriendsToCache() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;

    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.friendListEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) return;

    final body = json.decode(utf8.decode(res.bodyBytes));
    final List<dynamic> content = body['data']?['content'] ?? [];

    final map = <String, String>{};
    for (final f in content) {
      final nick = f['nickname'] as String? ?? '';
      final avatar = f['profileImageUrl'] as String? ?? '';
      if (nick.isNotEmpty && avatar.isNotEmpty) {
        map[nick] = avatar;
      }
    }

    ChatFriendCache.instance.nicknameToAvatar = map;
  }
}
