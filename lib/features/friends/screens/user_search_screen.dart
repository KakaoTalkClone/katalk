import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import 'friend_profile_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  List<dynamic> _searchResults = [];
  String? _error;
  String _message = '이름 또는 ID로 친구를 찾아보세요.';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchUsers(_searchController.text);
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
          _message = '이름 또는 ID로 친구를 찾아보세요.';
        });
      }
    });
  }

  Future<void> _searchUsers(String query) async {
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

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.friendListEndpoint}',
      ).replace(queryParameters: {'nickname': query});

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        if (!mounted) return;
        setState(() {
          _searchResults = body['data']['content'] ?? [];
          if (_searchResults.isEmpty) {
            _message = '검색 결과가 없습니다.';
          }
        });
      } else {
        throw Exception(
          '친구 검색에 실패했습니다. 상태 코드: ${response.statusCode}, 응답: ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _message = '오류 발생: $_error'; // Update message to show error
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '친구 이름으로 검색',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text('오류: $_error', style: const TextStyle(color: Colors.red)),
      );
    }
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(_message, style: const TextStyle(color: Colors.white54)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const Divider(
        color: AppColors.grey1, // 구분선 색상 (조절 가능)
        height: 1,
        indent: 70, // 프로필 이미지 너비 + 여백만큼 들여쓰기
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final profileImageUrl = user['profileImageUrl'] as String?;
        final nickname = user['nickname'] ?? '이름 없음';
        final statusMessage = user['statusMessage'] as String?;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FriendProfileScreen(isMyProfile: false, friendData: user),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // 프로필 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(20), // 둥근 정도 (원형에 가깝게)
                  child: Container(
                    width: 44,
                    height: 44,
                    color: AppColors.grey1, // 이미지 로딩 전 배경색
                    child:
                        (profileImageUrl != null && profileImageUrl.isNotEmpty)
                        ? Image.network(
                            profileImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: AppColors.grey2,
                                size: 24,
                              );
                            },
                          )
                        : const Icon(
                            Icons.person,
                            color: AppColors.grey2,
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // 텍스트 정보 (이름 + 상태메시지)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        nickname,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (statusMessage != null &&
                          statusMessage.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          statusMessage,
                          style: const TextStyle(
                            color: AppColors.grey2,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
