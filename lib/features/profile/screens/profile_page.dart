import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadMyProfile();
  }

  Future<void> _loadMyProfile() async {
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

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userMyInfoEndpoint}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        if (body['success'] == true && body['data'] != null) {
          setState(() {
            _profileData = body['data'];
          });
        } else {
          throw Exception('프로필 정보를 가져오는 데 실패했습니다: ${body['message']}');
        }
      } else {
        throw Exception('프로필 정보를 가져올 수 없습니다. 상태 코드: ${response.statusCode}');
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        title: const Text('프로필', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: AppColors.text),
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

    if (_error != null || _profileData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error ?? '프로필 정보를 불러올 수 없습니다.', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _loadMyProfile, child: const Text('재시도')),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildProfileCard(context, _profileData!),
        const Spacer(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(color: Colors.white10),
        ),
        _buildActionButtons(context, _profileData!),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, Map<String, dynamic> user) {
    final String? avatarUrl = user['profileImageUrl'];
    final String name = user['nickname'] ?? '이름 없음';
    final String statusMessage = user['statusMessage'] ?? '상태 메시지 없음';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? Image.network(
                    avatarUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 80, color: Colors.grey),
                  )
                : const Icon(Icons.person, size: 80, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusMessage,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> currentUser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(
          icon: Icons.chat_bubble,
          label: '나와의 채팅',
          onPressed: () {
            Navigator.of(context).pushNamed('/chat/room', arguments: {'title': currentUser['nickname']});
          },
        ),
        _buildIconButton(
          icon: Icons.edit,
          label: '프로필 편집',
          onPressed: () {},
        ),
        _buildIconButton(
          icon: Icons.share,
          label: '프로필 공유',
          onPressed: () {},
        ),
      ],
    );
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
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: AppColors.text),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(color: AppColors.text, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}