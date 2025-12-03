// lib/core/chat/chat_friend_cache.dart
class ChatFriendCache {
  ChatFriendCache._();
  static final ChatFriendCache instance = ChatFriendCache._();

  // key: nickname, value: profileImageUrl
  Map<String, String> nicknameToAvatar = {};
}
