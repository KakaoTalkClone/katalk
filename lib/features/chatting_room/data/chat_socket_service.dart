import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';

import '../../chats/data/chat_room_models.dart';

typedef SocketMessageHandler = void Function(ChatMessage message);

class ChatSocketService {
  ChatSocketService({
    required this.onMessage,
    this.onError,
  });

  final SocketMessageHandler onMessage;
  final void Function(Object error)? onError;

  final _storage = const FlutterSecureStorage();

  StompClient? _client;
  void Function()? _roomSub; // 이전 구독 해제용
  int? _connectedRoomId;
  String? _token; // send 시 Authorization 헤더용

  bool get isConnected => _client?.connected ?? false;

  Future<String> _getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('JWT 토큰이 없습니다. 다시 로그인 해주세요.');
    }
    return token;
  }

  /// roomId 기준으로 연결 + 구독까지 한 번에
  Future<void> connectAndSubscribe(int roomId) async {
    _token ??= await _getToken();

    // 이미 연결돼 있으면 구독만 변경
    if (_client != null && _client!.connected) {
      _subscribeRoom(roomId);
      return;
    }

    _client = StompClient(
      config: StompConfig.sockJS(
        // HTML 테스트 코드 기준: const WS = "https://ktalk.shop/ws";
        url: 'https://ktalk.shop/ws',
        stompConnectHeaders: {
          'Authorization': 'Bearer $_token',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $_token',
        },
        onConnect: (_) {
          debugPrint('[ChatSocket] connected');
          _subscribeRoom(roomId);
        },
        onStompError: (frame) {
          debugPrint('[ChatSocket] stomp error: ${frame.body}');
          onError?.call(frame.body ?? 'stomp error');
        },
        onWebSocketError: (error) {
          debugPrint('[ChatSocket] websocket error: $error');
          onError?.call(error);
        },
        onDisconnect: (_) {
          debugPrint('[ChatSocket] disconnected');
          _connectedRoomId = null;
          _roomSub = null;
        },
      ),
    );

    _client!.activate();
  }

  void _subscribeRoom(int roomId) {
    if (!(_client?.connected ?? false)) return;

    // 같은 방이면 다시 구독 안 함
    if (_roomSub != null && _connectedRoomId == roomId) return;

    // 이전 구독 해제
    _roomSub?.call();

    final topic = '/topic/chatroom.$roomId';
    debugPrint('[ChatSocket] subscribe $topic');

    _roomSub = _client!.subscribe(
      destination: topic,
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final map = json.decode(frame.body!) as Map<String, dynamic>;

          // HTML 테스트 클라 기준: 읽음 이벤트 등도 같은 topic으로 옴
          // 우리는 일단 content 있는 메시지만 처리
          if (!map.containsKey('content')) {
            return;
          }

          final msg = ChatMessage.fromJson(map);
          onMessage(msg);
        } catch (e, s) {
          debugPrint('[ChatSocket] message parse error: $e\n$s');
        }
      },
    );

    _connectedRoomId = roomId;
  }

  /// 텍스트 메시지 전송 (HTML sendMsg()와 동일)
  Future<void> sendText(int roomId, String content) async {
    if (_client == null || !_client!.connected) {
      debugPrint('[ChatSocket] sendText but client not connected');
      return;
    }

    final payload = jsonEncode({
      'roomId': roomId,
      'content': content,
      'contentType': 'TEXT',
    });

    _client!.send(
      destination: '/pub/chat/message',
      body: payload,
      headers: {
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
    );
  }

  void dispose() {
    _roomSub?.call();
    _roomSub = null;
    if (_client != null) {
      _client!.deactivate();
      _client = null;
    }
  }
}


