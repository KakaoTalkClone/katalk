// lib/features/chats/data/chat_rooms_socket_service.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../../core/constants/api_constants.dart';

/// 방 목록 실시간 갱신용 메시지 모델
class RoomListUpdate {
  final int roomId;
  final String content;
  final int senderId;

  RoomListUpdate({
    required this.roomId,
    required this.content,
    required this.senderId,
  });

  factory RoomListUpdate.fromJson(Map<String, dynamic> json) {
    return RoomListUpdate(
      roomId: json['roomId'] as int,
      content: (json['content'] as String?) ?? '',
      senderId: json['senderId'] as int? ?? -1,
    );
  }
}

/// 채팅방 목록용 웹소켓 서비스
///
/// HTML 테스트 코드 기준:
///   - WS:    https://ktalk.shop/ws
///   - topic: /topic/user.{내유저ID}
class ChatRoomsSocketService {
  ChatRoomsSocketService({
    required this.onUpdate,
    this.onError,
  });

  final void Function(RoomListUpdate update) onUpdate;
  final void Function(Object error)? onError;

  final _storage = const FlutterSecureStorage();
  StompClient? _client;
  int? _myUserId;
  String? _token;

  bool get isConnected => _client?.connected ?? false;

  /// 외부에서 부르는 진입점
  Future<void> connectAndSubscribe() async {
    try {
      _token = await _storage.read(key: 'jwt_token');
      if (_token == null) {
        debugPrint('[RoomsSocket] no jwt_token, skip connect');
        return;
      }

      // 1) 내 유저 ID 조회
      final meUri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.userMyInfoEndpoint}',
      );
      final meRes = await http.get(
        meUri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      debugPrint('[RoomsSocket] my info status=${meRes.statusCode}');
      debugPrint(
        '[RoomsSocket] my info body=${utf8.decode(meRes.bodyBytes)}',
      );

      if (meRes.statusCode != 200) {
        debugPrint('[RoomsSocket] my info failed: ${meRes.statusCode}');
        return;
      }

      final meBody = json.decode(utf8.decode(meRes.bodyBytes));
      _myUserId = (meBody['data']?['id'] as int?);
      if (_myUserId == null) {
        debugPrint('[RoomsSocket] my id null, stop');
        return;
      }

      // 2) 웹소켓 클라이언트 생성 + 연결
      _client = StompClient(
        config: StompConfig.sockJS(
          url: 'https://ktalk.shop/ws',
          stompConnectHeaders: {
            'Authorization': 'Bearer $_token',
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $_token',
          },
          onConnect: _onConnect,
          onStompError: (StompFrame frame) {
            debugPrint('[RoomsSocket] stomp error: ${frame.body}');
            onError?.call(frame.body ?? 'stomp error');
          },
          onWebSocketError: (dynamic error) {
            debugPrint('[RoomsSocket] ws error: $error');
            onError?.call(error);
          },
          onDisconnect: (_) {
            debugPrint('[RoomsSocket] disconnected');
          },
        ),
      );

      _client!.activate();
    } catch (e) {
      debugPrint('[RoomsSocket] connectAndSubscribe error: $e');
      onError?.call(e);
    }
  }

  /// 혹시 다른 데서 connect() 이름으로 부를 수도 있으니 래퍼 하나 더 둠
  Future<void> connect() => connectAndSubscribe();

  void _onConnect(StompFrame frame) {
    debugPrint('[RoomsSocket] connected');
    if (_myUserId == null) return;

    final topic = '/topic/user.${_myUserId}';
    debugPrint('[RoomsSocket] subscribe $topic');

    _client!.subscribe(
      destination: topic,
      callback: (StompFrame frame) {
        if (frame.body == null) return;
        try {
          final map = json.decode(frame.body!) as Map<String, dynamic>;
          final update = RoomListUpdate.fromJson(map);
          onUpdate(update);
        } catch (e) {
          debugPrint('[RoomsSocket] parse error: $e');
        }
      },
    );
  }

  void dispose() {
    try {
      _client?.deactivate();
    } catch (_) {}
    _client = null;
  }
}
