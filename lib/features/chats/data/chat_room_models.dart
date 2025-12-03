// lib/features/chats/data/chat_room_models.dart
class ChatRoomSummary {
  final int roomId;
  final String roomName;
  final String roomType; // "DIRECT" | "GROUP"
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
    final rawTime = json['lastMessageAt'] as String?;
    DateTime? parsed;
    if (rawTime != null && rawTime.isNotEmpty) {
      try {
        parsed = DateTime.parse(rawTime).toLocal();
      } catch (_) {
        parsed = null;
      }
    }

    return ChatRoomSummary(
      roomId: json['roomId'] as int,
      roomName: json['roomName'] as String? ?? '',
      roomType: json['roomType'] as String? ?? 'DIRECT',
      lastMessagePreview: json['lastMessagePreview'] as String? ?? '',
      lastMessageAt: parsed,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}
