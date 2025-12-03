// lib/features/friends/screens/friend_profile_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../chats/data/chat_api.dart';

class FriendProfileScreen extends StatefulWidget {
  final bool isMyProfile;
  final Map<String, dynamic> friendData;

  const FriendProfileScreen({
    super.key,
    required this.isMyProfile,
    required this.friendData,
  });

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // 내 프로필이면 이미 넘어온 데이터 사용
    if (widget.isMyProfile) {
      setState(() {
        _profileData = widget.friendData;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _profileData = widget.friendData; // 기본 데이터

      final userId = widget.friendData['userId'];
      if (userId == null) {
        throw Exception('User ID is missing.');
      }

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

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}'
          '${ApiConstants.userProfileEndpoint(userId)}',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        final profileDataFromServer = body['data'];
        if (profileDataFromServer != null) {
          setState(() {
            _profileData = profileDataFromServer;
          });
        } else {
          throw Exception('상세 프로필 데이터가 비어있습니다.');
        }
      } else {
        debugPrint(
          'Could not fetch full profile, using partial data. '
          'Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// ✅ 1:1 채팅 버튼 눌렀을 때: 방 생성 + 채팅방으로 이동
  Future<void> _start1To1Chat() async {
    final friendId = widget.friendData['userId'] as int?;
    final nickname =
        widget.friendData['nickname'] as String? ?? '1:1 채팅';

    if (friendId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효하지 않은 사용자입니다.')),
      );
      return;
    }

    try {
      final api = ChatApi();
      final data = await api.createDirectRoom(friendId);

      if (!mounted) return;

      final roomId = data['roomId'] as int;
      final roomName = data['roomName'] as String? ?? nickname;
      final roomType = data['roomType'] as String? ?? 'DIRECT';

      Navigator.of(context).pushNamed(
        '/chat/room',
        arguments: {
          'roomId': roomId,
          'roomType': roomType,
          'title': roomName,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채팅방 생성 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialData = _profileData ?? widget.friendData;

    final String name = initialData['nickname'] ?? '알 수 없음';
    final String? avatarUrl = initialData['profileImageUrl'];
    final String statusMessage =
        initialData['statusMessage'] ?? '상태 메시지 없음';
    final List<dynamic> backgroundImages =
        initialData['backgroundImageUrls'] ?? [];
    final String? backgroundImageUrl =
        backgroundImages.isNotEmpty ? backgroundImages[0] : null;

    return Scaffold(
      body: Stack(
        children: [
          if (backgroundImageUrl != null)
            Positioned.fill(
              child: Image.network(
                backgroundImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: const Color(0xFFB1C1D7)),
              ),
            )
          else
            Container(color: const Color(0xFFB1C1D7)),
          _buildBody(name, avatarUrl, statusMessage),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Center(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    String name,
    String? avatarUrl,
    String statusMessage,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.qr_code, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(35.0),
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 100),
                        )
                      : const Icon(Icons.person,
                          size: 100, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black45,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  statusMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black45,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.white54,
            indent: 20,
            endIndent: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: _buildActionButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (widget.isMyProfile) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(
            icon: Icons.chat_bubble,
            label: '나와의 채팅',
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/chat/room',
                arguments: {
                  'title': widget.friendData['nickname'] ?? '나와의 채팅',
                },
              );
            },
          ),
          _buildIconButton(
            icon: Icons.edit,
            label: '프로필 편집',
            onPressed: () {},
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(
            icon: Icons.chat_bubble,
            label: '1:1 채팅',
            onPressed: _start1To1Chat, // ✅ 여기서 1:1 채팅 시작
          ),
          _buildIconButton(
            icon: Icons.call,
            label: '통화하기',
            onPressed: () {},
          ),
        ],
      );
    }
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                shadows: [
                  Shadow(blurRadius: 1.0, color: Colors.black45),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
