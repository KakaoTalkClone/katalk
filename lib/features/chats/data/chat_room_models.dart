// lib/features/chats/data/chat_room_models.dart
import 'package:flutter/foundation.dart';

/// 채팅방 요약 정보
class ChatRoomSummary {
  final int roomId;
  final String roomName;
  final String roomType; // DIRECT / GROUP
  final int unreadCount;
  final String lastMessagePreview;
  final DateTime? lastMessageAt;

  /// 백엔드에서 내려주는 썸네일 URL (상대방/그룹 프로필)
  final String? thumbnailUrl;

  ChatRoomSummary({
    required this.roomId,
    required this.roomName,
    required this.roomType,
    required this.unreadCount,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    this.thumbnailUrl,
  });

  factory ChatRoomSummary.fromJson(Map<String, dynamic> json) {
    final dynamic typeRaw =
        json['roomType'] ?? json['chatRoomType'] ?? 'DIRECT';

    final dynamic previewRaw = json['lastMessagePreview'];
    final String preview = previewRaw == null
        ? ''
        : (previewRaw is String ? previewRaw : previewRaw.toString());

    final dynamic unreadRaw = json['unreadCount'];
    final int unread = unreadRaw is int
        ? unreadRaw
        : int.tryParse(unreadRaw?.toString() ?? '0') ?? 0;

    return ChatRoomSummary(
      roomId: json['roomId'] as int,
      roomName: (json['roomName'] as String?) ?? '',
      roomType: typeRaw as String,
      unreadCount: unread,
      lastMessagePreview: preview,
      lastMessageAt: _parseDateTime(json['lastMessageAt']),
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}

/// 채팅 메시지
class ChatMessage {
  final int messageId;
  final int roomId;
  final int senderId;
  final String senderNickname;
  final String content;
  final String contentType; // TEXT 등
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
    final dynamic unreadRaw = json['unreadCount'];
    final int unread = unreadRaw is int
        ? unreadRaw
        : int.tryParse(unreadRaw?.toString() ?? '0') ?? 0;

    return ChatMessage(
      messageId: json['messageId'] as int,
      roomId: json['roomId'] as int,
      senderId: json['senderId'] as int,
      senderNickname: (json['senderNickname'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      contentType: (json['contentType'] as String?) ?? 'TEXT',
      createdAt: _parseDateTime(json['createdAt']),
      unreadCount: unread,
    );
  }
}

/// 유저 프로필 ( /api/user/{userId} )
class UserProfile {
  final String? profileImageUrl;
  final List<String> backgroundImageUrls;
  final String nickname;
  final String statusMessage;

  UserProfile({
    required this.profileImageUrl,
    required this.backgroundImageUrls,
    required this.nickname,
    required this.statusMessage,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = json; // 이미 data 부분만 넘긴다고 가정
    return UserProfile(
      profileImageUrl: data['profileImageUrl'] as String?,
      backgroundImageUrls: (data['backgroundImageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      nickname: (data['nickname'] as String?) ?? '',
      statusMessage: (data['statusMessage'] as String?) ?? '',
    );
  }
}

/// Java LocalDateTime 배열 / ISO 문자열 / epoch 등 다 받아주는 공통 파서
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;

  try {
    if (value is List) {
      if (value.length >= 5) {
        return DateTime(
          (value[0] as num).toInt(),
          (value[1] as num).toInt(),
          (value[2] as num).toInt(),
          (value[3] as num).toInt(),
          (value[4] as num).toInt(),
          value.length > 5 ? (value[5] as num).toInt() : 0,
        );
      }
    }

    if (value is String) {
      return DateTime.parse(value);
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
  } catch (e) {
    debugPrint('[ChatModels] _parseDateTime error: $e, value=$value');
  }

  return null;
}
