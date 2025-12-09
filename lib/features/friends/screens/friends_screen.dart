import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/chat/chat_friend_cache.dart'; // [추가]
import 'package:my_app/features/friends/widgets/add_friend_sheet.dart';
import 'friend_profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  bool _isLoading = true;
  List<dynamic> _friends = [];
  Map<String, dynamic>? _myProfileData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFriendData();
  }

  Future<void> _loadFriendData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('로그인 토큰을 찾을 수 없습니다.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      // 1. Fetch my basic user info to get my ID
      final myInfoResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userMyInfoEndpoint}'),
        headers: headers,
      );

      if (myInfoResponse.statusCode != 200) {
        throw Exception('내 정보를 불러오는 데 실패했습니다.');
      }
      final myInfoBody = json.decode(utf8.decode(myInfoResponse.bodyBytes));
      if (myInfoBody['success'] != true || myInfoBody['data'] == null) {
        throw Exception('내 정보 응답이 올바르지 않습니다.');
      }
      final myUserId = myInfoBody['data']['id'];

      // 2. Fetch my full profile using the ID from the first call
      final myProfileResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userProfileEndpoint(myUserId)}'),
        headers: headers,
      );

      if (myProfileResponse.statusCode != 200) {
        throw Exception('내 상세 프로필을 불러오는 데 실패했습니다.');
      }
      final myProfileBody = json.decode(utf8.decode(myProfileResponse.bodyBytes));
      if (myProfileBody['success'] == true && myProfileBody['data'] != null) {
        _myProfileData = myProfileBody['data'];
        // Ensure the userId is present in the map for navigation
        _myProfileData?['userId'] = myUserId;
      } else {
        throw Exception('내 상세 프로필 데이터가 비어있습니다.');
      }
      
      // 3. Fetch friends list
      final friendsResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.friendListEndpoint}'),
        headers: headers,
      );

      if (friendsResponse.statusCode == 200) {
        final friendsBody = json.decode(utf8.decode(friendsResponse.bodyBytes));
        if (friendsBody['success'] == true && friendsBody['data'] != null) {
          _friends = friendsBody['data']['content'] ?? [];

          // ▼▼▼ [추가] 화면 목록 갱신하면서 캐시도 업데이트 (중요!) ▼▼▼
          final cacheMap = <String, String>{};
          for (var f in _friends) {
            final nick = f['nickname'] as String?;
            final url = f['profileImageUrl'] as String?;
            if (nick != null && nick.isNotEmpty && url != null && url.isNotEmpty) {
              cacheMap[nick] = url;
            }
          }
          // 기존 캐시에 덮어씌우기 (addAll은 키가 같으면 값을 업데이트함)
          ChatFriendCache.instance.nicknameToAvatar.addAll(cacheMap);

        } else {
          throw Exception('친구 목록 데이터가 비어있습니다.');
        }
      } else {
        throw Exception('친구 목록을 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        title: const Text('친구', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/friends/search');
            },
            icon: const Icon(Icons.search, color: AppColors.text),
          ),
          IconButton(
            onPressed: () async {
              final result = await showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: 'add_friend',
                barrierColor: Colors.black.withOpacity(0.55),
                transitionDuration: const Duration(milliseconds: 220),
                pageBuilder: (_, __, ___) => const AddFriendSheet(),
                transitionBuilder: (_, anim, __, child) {
                  final offset = Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: anim,
                      curve: Curves.easeOutCubic,
                    ),
                  );
                  return SlideTransition(position: offset, child: child);
                },
              );
              if (result == true) {
                _loadFriendData();
              }
            },
            icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.text),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('오류 발생: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loadFriendData, child: const Text('다시 시도')),
          ],
        ),
      );
    }
    if (_myProfileData == null) {
      return const Center(child: Text('내 프로필 정보를 불러올 수 없습니다.', style: TextStyle(color: Colors.white)));
    }
    return ListView(
      children: [
        _buildMyProfile(context, _myProfileData!),
        const Divider(color: Colors.white10),
        _buildFriendList(context, _friends),
      ],
    );
  }

  Widget _buildMyProfile(BuildContext context, Map<String, dynamic> currentUser) {
    final avatarUrl = currentUser['profileImageUrl'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(22.0),
          child: (avatarUrl != null && avatarUrl.isNotEmpty)
              ? Image.network(
                  avatarUrl,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 58),
                )
              : const Icon(Icons.person, size: 58, color: Colors.grey),
        ),
        title: Text(
          currentUser['nickname'] ?? '이름 없음',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text),
        ),
        subtitle: Text(
          currentUser['statusMessage'] ?? '',
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FriendProfileScreen(isMyProfile: true, friendData: currentUser),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendList(BuildContext context, List<dynamic> friends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text(
            '친구 ${friends.length}',
            style: const TextStyle(color: Colors.white54),
          ),
        ),
        ...friends.map((friend) {
          return _FriendListItem(
            friendData: friend,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FriendProfileScreen(isMyProfile: false, friendData: friend),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          );
        })
      ],
    );
  }
}

class _FriendListItem extends StatelessWidget {
  const _FriendListItem({
    required this.friendData,
    required this.onTap,
  });

  final Map<String, dynamic> friendData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = friendData['profileImageUrl'];
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(18.0),
        child: (avatarUrl != null && avatarUrl.isNotEmpty)
            ? Image.network(
                avatarUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 48),
              )
            : const Icon(Icons.person, size: 48, color: Colors.grey),
      ),
      title: Text(
        friendData['nickname'] ?? '이름 없음',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.text),
      ),
      subtitle: Text(
        friendData['statusMessage'] ?? '',
        style: const TextStyle(fontSize: 13, color: Colors.white70),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
