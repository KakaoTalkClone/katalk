// lib/core/chat/current_chat_tracker.dart
class CurrentChatTracker {
  CurrentChatTracker._();
  static final CurrentChatTracker instance = CurrentChatTracker._();

  /// 현재 보고 있는 채팅방 ID (없으면 null)
  int? roomId;

  void enterRoom(int id) {
    roomId = id;
  }

  void exitRoom() {
    roomId = null;
  }
}