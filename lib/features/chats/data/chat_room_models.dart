// lib/features/chats/data/chat_room_models.dart

/// 공통으로 쓰는 DateTime 파서
/// - String "2025-12-04T11:20:30" 도 받고
/// - [2025, 12, 4, 11, 20, 30] 이런 배열도 받게 처리
DateTime? _parseDateTime(dynamic raw) {
  if (raw == null) return null;

  // 문자열 ISO 포맷
  if (raw is String) {
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  // 스프링 LocalDateTime 배열 [yyyy, MM, dd, HH, mm, ss(, nano)]
  if (raw is List && raw.length >= 3) {
    try {
      final year = raw[0] as int;
      final month = raw[1] as int;
      final day = raw[2] as int;
      final hour = raw.length > 3 ? raw[3] as int : 0;
      final minute = raw.length > 4 ? raw[4] as int : 0;
      final second = raw.length > 5 ? raw[5] as int : 0;

      return DateTime(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
  }

  return null;
}

/// 채팅방 목록 한 줄 정보
class ChatRoomSummary {
  final int roomId;
  final String roomName;
  final String roomType; // DIRECT / GROUP
  final int unreadCount;
  final String lastMessagePreview;
  final DateTime? lastMessageAt;

  ChatRoomSummary({
    required this.roomId,
    required this.roomName,
    required this.roomType,
    required this.unreadCount,
    required this.lastMessagePreview,
    this.lastMessageAt,
  });

  factory ChatRoomSummary.fromJson(Map<String, dynamic> json) {
    return ChatRoomSummary(
      roomId: json['roomId'] as int,
      roomName: (json['roomName'] as String?) ?? '',
      // 백엔드에서 chatRoomType 으로 줄 수도 있어서 둘 다 대응
      roomType:
          (json['roomType'] as String?) ?? (json['chatRoomType'] as String?) ?? 'DIRECT',
      unreadCount: (json['unreadCount'] as int?) ?? 0,
      lastMessagePreview: (json['lastMessagePreview'] as String?) ?? '',
      lastMessageAt: _parseDateTime(json['lastMessageAt']),
    );
  }
}

/// 채팅방 내 메시지 한 개
class ChatMessage {
  final int messageId;
  final int roomId;
  final int senderId;
  final String senderNickname;
  final String content;
  final String contentType; // TEXT, IMAGE 등
  final DateTime? createdAt;
  final int unreadCount;

  ChatMessage({
    required this.messageId,
    required this.roomId,
    required this.senderId,
    required this.senderNickname,
    required this.content,
    required this.contentType,
    required this.createdAt,
    required this.unreadCount,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] as int,
      roomId: json['roomId'] as int,
      senderId: json['senderId'] as int,
      senderNickname: (json['senderNickname'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      contentType: (json['contentType'] as String?) ?? 'TEXT',
      createdAt: _parseDateTime(json['createdAt']),
      unreadCount: (json['unreadCount'] as int?) ?? 0,
    );
  }
}
