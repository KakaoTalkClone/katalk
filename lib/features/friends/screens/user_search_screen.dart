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

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userLookupEndpoint}')
          .replace(queryParameters: {'username': query});

      final response = await http.get(
        uri,
        headers: headers,
      );

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
        throw Exception('사용자 검색에 실패했습니다. 상태 코드: ${response.statusCode}, 응답: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _message = '오류 발생: $_error'; // Update message to show error
      });
    } finally {
      if (!mounted) return;
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
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '이름 또는 ID로 검색',
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
      return Center(child: Text('오류: $_error', style: const TextStyle(color: Colors.red)));
    }
    if (_searchResults.isEmpty) {
      return Center(child: Text(_message, style: const TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)), // Placeholder for profile image
          title: Text(user['nickname'] ?? '이름 없음', style: const TextStyle(color: Colors.white)),
          subtitle: Text(user['statusMessage'] ?? '', style: const TextStyle(color: Colors.white70)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FriendProfileScreen(
                  isMyProfile: false, // Searched users are not the current user
                  friendData: user,
                ),
              ),
            );
          },
        );
      },
    );
  }
}