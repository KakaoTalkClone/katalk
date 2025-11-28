// katalk/lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://ktalk.shop';
  static const String loginEndpoint = '/api/auth/login';
  static const String userMyInfoEndpoint = '/api/user/my/info';
  static String userProfileEndpoint(int userId) => '/api/user/$userId';
  static String friendByIdEndpoint(int userId) => '/api/friend/$userId';
  static const String friendListEndpoint = '/api/friend';
  static const String addFriendByUsernameEndpoint = '/api/friend/username';
  static const String userSearchEndpoint = '/api/user/search';
}
