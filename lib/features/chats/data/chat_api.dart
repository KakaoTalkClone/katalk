// lib/features/chats/data/chat_api.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import 'chat_room_models.dart';

class ChatApi {
  ChatApi();

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  int? _cachedMyId;

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

  /// 내가 속한 채팅방 목록 조회
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

  /// 1:1 채팅방 생성 (HTML createDirect()와 동일)
  Future<Map<String, dynamic>> createDirectRoom(int targetUserId) async {
    final token = await _getToken();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.chatDirectRoomEndpoint}'
      '?targetUserId=$targetUserId',
    );
    debugPrint('[ChatApi] createDirectRoom uri=$uri');

    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({}), // HTML도 {} 보냄
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

  /// 방 안 메시지 목록 조회 (HTML enterRoom()에서 불러오는 것)
  Future<List<ChatMessage>> fetchMessages({
    required int roomId,
    int page = 1,
    int size = 50,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}'
      '${ApiConstants.chatRoomMessagesEndpoint(roomId)}'
      '?page=$page&size=$size',
    );
    debugPrint('[ChatApi] fetchMessages uri=$uri');

    final res = await http.get(uri, headers: _headers(token));

    debugPrint('[ChatApi] fetchMessages status=${res.statusCode}');
    debugPrint('[ChatApi] fetchMessages body=${utf8.decode(res.bodyBytes)}');

    if (res.statusCode != 200) {
      throw Exception('메시지 목록 조회 실패 (${res.statusCode})');
    }

    final body = json.decode(utf8.decode(res.bodyBytes));
    if (body['success'] != true || body['data'] == null) {
      throw Exception('메시지 응답 형식이 올바르지 않습니다.');
    }

    final List<dynamic> list = body['data']['content'] ?? [];
    return list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 내 userId 조회 (HTML loginAndConnect()에서 /user/my/info 호출하던 것)
  Future<int> fetchMyUserId() async {
    if (_cachedMyId != null) return _cachedMyId!;

    final token = await _getToken();
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.userMyInfoEndpoint}',
    );
    debugPrint('[ChatApi] fetchMyUserId uri=$uri');

    final res = await http.get(uri, headers: _headers(token));

    debugPrint('[ChatApi] fetchMyUserId status=${res.statusCode}');
    debugPrint('[ChatApi] fetchMyUserId body=${utf8.decode(res.bodyBytes)}');

    if (res.statusCode != 200) {
      throw Exception('내 정보 조회 실패 (${res.statusCode})');
    }

    final body = json.decode(utf8.decode(res.bodyBytes));
    if (body['success'] != true || body['data'] == null) {
      throw Exception('내 정보 응답 형식이 올바르지 않습니다.');
    }

    final data = body['data'] as Map<String, dynamic>;
    final id = data['id'] as int?;
    if (id == null) {
      throw Exception('내 정보에 id가 없습니다.');
    }

    _cachedMyId = id;
    return id;
  }
}
