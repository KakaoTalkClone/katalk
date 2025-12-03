// lib/features/chats/data/chat_api.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';          // ✅ 추가
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import 'chat_room_models.dart';

class ChatApi {
  ChatApi();

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String> _getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('로그인 토큰이 없습니다. 다시 로그인 해주세요.');
    }
    return token;
  }

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// 1. 내가 속한 채팅방 목록 조회
  Future<List<ChatRoomSummary>> fetchMyChatRooms({
    int page = 1,
    int size = 20,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.chatRoomsEndpoint}'
        '?page=$page&size=$size',
);


    debugPrint('[ChatApi] fetchMyChatRooms uri=$uri');

    final res = await http.get(uri, headers: _headers(token));

    debugPrint('[ChatApi] fetchMyChatRooms status=${res.statusCode}');
    debugPrint('[ChatApi] fetchMyChatRooms body=${utf8.decode(res.bodyBytes)}');

    if (res.statusCode != 200) {
      throw Exception('채팅방 목록 조회 실패 (${res.statusCode})');
    }

    final body = json.decode(utf8.decode(res.bodyBytes));
    if (body['success'] != true || body['data'] == null) {
      throw Exception('채팅방 응답 형식이 올바르지 않습니다.');
    }

    final List<dynamic> list = body['data']['content'] ?? [];
    return list
        .map((e) => ChatRoomSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 2. 1:1 채팅방 생성
  Future<Map<String, dynamic>> createDirectRoom(int targetUserId) async {
    final token = await _getToken();
    final uri = Uri.parse(
    '${ApiConstants.baseUrl}${ApiConstants.chatRoomsEndpoint}'
    '/direct?targetUserId=$targetUserId',
  );
ㄴ

    debugPrint('[ChatApi] createDirectRoom uri=$uri');

    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({}),
    );

    debugPrint('[ChatApi] createDirectRoom status=${res.statusCode}');
    debugPrint('[ChatApi] createDirectRoom body=${utf8.decode(res.bodyBytes)}');

    if (res.statusCode != 200) {
      throw Exception('1:1 채팅방 생성 실패 (${res.statusCode})');
    }

    final body = json.decode(utf8.decode(res.bodyBytes));
    if (body['success'] != true || body['data'] == null) {
      throw Exception('1:1 채팅방 응답 형식이 올바르지 않습니다.');
    }

    return Map<String, dynamic>.from(body['data'] as Map);
  }
}
