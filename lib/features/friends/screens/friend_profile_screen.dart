import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../../core/constants/api_constants.dart';

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
    // If it's my own profile, we don't need to fetch any extra data.
    // The required data is already passed from the friends screen.
    if (widget.isMyProfile) {
      setState(() {
        _profileData = widget.friendData;
        _isLoading = false;
      });
      return;
    }

    // Proceed with fetching for a friend's profile
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use initial data as a fallback while loading
      _profileData = widget.friendData;

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
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userProfileEndpoint(userId)}'),
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
        // If fetching fails, we just stick with the data passed from the friends list.
        // This prevents showing a big error for a temporary issue.
        // The user can still see the basic profile.
        print('Could not fetch full profile, using partial data. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use initial data as fallback while loading or if profileData is null
    final initialData = _profileData ?? widget.friendData;

    final String name = initialData['nickname'] ?? '알 수 없음';
    final String? avatarUrl = initialData['profileImageUrl'];
    final String statusMessage = initialData['statusMessage'] ?? '상태 메시지 없음';
    final List<dynamic> backgroundImages = initialData['backgroundImageUrls'] ?? [];
    final String? backgroundImageUrl = backgroundImages.isNotEmpty ? backgroundImages[0] : null;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          if (backgroundImageUrl != null)
            Positioned.fill(
              child: Image.network(
                backgroundImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFB1C1D7)),
              ),
            )
          else
            Container(color: const Color(0xFFB1C1D7)),
          // Main content
          _buildBody(name, avatarUrl, statusMessage),
          // Loading and Error overlays
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildBody(String name, String? avatarUrl, String statusMessage) {
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
          const Spacer(), // Pushes content to the bottom
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
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 100),
                        )
                      : const Icon(Icons.person, size: 100, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 2.0, color: Colors.black45)],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  statusMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    shadows: [Shadow(blurRadius: 2.0, color: Colors.black45)],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white54, indent: 20, endIndent: 20),
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
              Navigator.of(context).pushNamed('/chat/room', arguments: {'title': widget.friendData['nickname'] ?? '나와의 채팅'});
            },
          ),
          _buildIconButton(icon: Icons.edit, label: '프로필 편집', onPressed: () {}),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(
            icon: Icons.chat_bubble,
            label: '1:1 채팅',
            onPressed: () {
              Navigator.of(context).pushNamed('/chat/room', arguments: {'title': widget.friendData['nickname']});
            },
          ),
          _buildIconButton(icon: Icons.call, label: '통화하기', onPressed: () {}),
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
            Text(label, style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 1.0, color: Colors.black45)])),
          ],
        ),
      ),
    );
  }
}
