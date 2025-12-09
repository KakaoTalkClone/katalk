// katalk/lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://ktalk.shop';
  static const String loginEndpoint = '/api/auth/login';
  static const String userMyInfoEndpoint = '/api/user/my/info';
  static String userProfileEndpoint(int userId) => '/api/user/$userId';
  static String friendByIdEndpoint(int userId) => '/api/friend/$userId';
  static const String friendListEndpoint = '/api/friend';
  static const String addFriendByUsernameEndpoint = '/api/friend/username';
  static const String addFriendByPhoneEndpoint = '/api/friend/phone';
  static const String userSearchEndpoint = '/api/user/search';
  static const String userLookupEndpoint = '/api/user';
  static const String chatRoomsEndpoint = '/api/chat/rooms';

  // 채팅방 메시지 목록
  static String chatRoomMessagesEndpoint(int roomId) =>
      '/api/chat/rooms/$roomId/messages';

  // 1:1 방 생성/획득
  static const String chatDirectRoomEndpoint = '/api/chat/rooms/direct';

  // 그룹 방 생성
  static const String chatGroupRoomEndpoint = '/api/chat/rooms/group';

  // 초대 / 나가기
  static String chatInviteEndpoint(int roomId) =>
      '/api/chat/rooms/$roomId/invite';

  static String chatLeaveEndpoint(int roomId) =>
      '/api/chat/rooms/$roomId/leave';
}

