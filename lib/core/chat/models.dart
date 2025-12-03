// lib/core/chat/models.dart
enum ChatRoomType { direct, group }

ChatRoomType chatRoomTypeFromString(String value) {
  switch (value) {
    case 'DIRECT':
      return ChatRoomType.direct;
    case 'GROUP':
      return ChatRoomType.group;
    default:
      return ChatRoomType.direct;
  }
}

class ChatRoomSummary {
  final int roomId;
  final String roomName;
  final ChatRoomType roomType;
  final String lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ChatRoomSummary({
    required this.roomId,
    required this.roomName,
    required this.roomType,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory ChatRoomSummary.fromJson(Map<String, dynamic> json) {
    return ChatRoomSummary(
      roomId: json['roomId'] as int,
      roomName: json['roomName'] as String? ?? '',
      roomType: chatRoomTypeFromString(json['roomType'] as String? ?? 'DIRECT'),
      lastMessagePreview: json['lastMessagePreview'] as String? ?? '',
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'] as String)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}
