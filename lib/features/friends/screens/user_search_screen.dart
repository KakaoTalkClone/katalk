import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';

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

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userSearchEndpoint}'),
        headers: headers,
        body: json.encode({'q': query, 'page': 0, 'size': 20}),
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
        throw Exception('사용자 검색에 실패했습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _addFriend(String username) async {
    // This is copied from friends_screen, can be refactored into a service later.
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token == null) throw Exception('로그인 토큰을 찾을 수 없습니다.');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addFriendByUsernameEndpoint}'),
        headers: headers,
        body: json.encode({'username': username}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("친구 '${username}'가 성공적으로 추가되었습니다.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('친구 추가 실패: ${responseData['message'] ?? '알 수 없는 오류'}')),
          );
        }
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류 (${response.statusCode}): ${response.body}')),
        );
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
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
          subtitle: Text(user['email'] ?? '', style: const TextStyle(color: Colors.white70)),
          trailing: ElevatedButton(
            onPressed: () {
              // Note: The add friend API uses 'username', but search result provides 'nickname' and 'email'.
              // Assuming 'email' can be used as 'username' for adding. This may need clarification.
              _addFriend(user['email']); 
            },
            child: const Text('추가'),
          ),
        );
      },
    );
  }
}
