// lib/core/chat/chat_api_service.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'models.dart';

class ChatApiService {
  ChatApiService._();
  static final ChatApiService instance = ChatApiService._();

  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() => _storage.read(key: 'jwt_token');

  Future<List<ChatRoomSummary>> fetchMyChatRooms({
    int page = 1,
    int size = 20,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('로그인 토큰이 없습니다.');
    }

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/api/chat/rooms?page=$page&size=$size',
    );

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('채팅방 목록 조회 실패 (${res.statusCode})');
    }

    final body = json.decode(utf8.decode(res.bodyBytes));
    if (body['success'] != true) {
      throw Exception(body['message'] ?? '채팅방 목록 조회 실패');
    }

    final List<dynamic> list = body['data']?['content'] ?? [];
    return list.map((e) => ChatRoomSummary.fromJson(e)).toList();
  }
}
