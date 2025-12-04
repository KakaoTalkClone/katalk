// lib/features/new_chats/screens/select_partners_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/friend_list_item.dart';
import '../../chats/data/chat_api.dart';

class SelectPartnersPage extends StatefulWidget {
  final bool isGroupChat; // true면 그룹 채팅, false면 1:1

  const SelectPartnersPage({super.key, required this.isGroupChat});

  @override
  State<SelectPartnersPage> createState() => _SelectPartnersPageState();
}

class _SelectPartnersPageState extends State<SelectPartnersPage> {
  final ChatApi _chatApi = ChatApi();

  final Set<int> _selectedIds = {}; // 선택된 친구 id들 (그룹 채팅용)
  List<dynamic> _friends = [];
  bool _isLoading = true;
  String? _error;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
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
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.friendListEndpoint}',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        if (body['success'] == true && body['data'] != null) {
          setState(() {
            _friends = body['data']['content'] ?? [];
          });
        } else {
          throw Exception('친구 목록 데이터 형식이 올바르지 않습니다.');
        }
      } else {
        throw Exception('친구 목록을 불러오는 데 실패했습니다.');
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

  /// 친구 한 명 클릭했을 때
  void _handleFriendTap(Map<String, dynamic> friend) async {
    final friendId = friend['userId'] as int?;

    if (friendId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('userId가 없는 친구입니다.')),
      );
      return;
    }

    if (widget.isGroupChat) {
      // 👉 그룹 채팅 모드: 단순히 선택 토글
      setState(() {
        if (_selectedIds.contains(friendId)) {
          _selectedIds.remove(friendId);
        } else {
          _selectedIds.add(friendId);
        }
      });
    } else {
      // 👉 1:1 채팅 모드: 바로 방 생성 후 입장
      try {
        final nickname = friend['nickname'] as String? ?? '새로운 채팅';
        final room = await _chatApi.createDirectRoom(friendId);
        final roomId = room['roomId'] as int?;
        final roomType =
            (room['chatRoomType'] ?? room['roomType'] ?? 'DIRECT') as String;

        if (roomId == null) {
          throw Exception('roomId가 응답에 없습니다.');
        }

        if (!mounted) return;

        Navigator.of(context).pop(); // 선택 페이지 닫기
        Navigator.pushNamed(
          context,
          '/chat/room',
          arguments: {
            'roomId': roomId,
            'roomType': roomType,
            'title': nickname,
          },
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅방 생성 실패: $e')),
        );
      }
    }
  }

  /// 그룹 채팅 이름 자동 생성 (선택된 친구들 기반)
  String _buildGroupName() {
    final selectedFriends = _friends
        .where((f) => _selectedIds.contains(f['userId'] as int))
        .toList();

    if (selectedFriends.isEmpty) return '그룹채팅';

    final names = selectedFriends
        .map((f) => (f['nickname'] as String?) ?? '친구')
        .toList();

    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names[0]}, ${names[1]}';
    return '${names[0]}, ${names[1]} 외 ${names.length - 2}명';
  }

  /// 상단 "확인" 버튼 눌렀을 때 (그룹 채팅 생성)
  Future<void> _createGroupChat() async {
    if (!widget.isGroupChat) return;
    if (_selectedIds.isEmpty) return;

    // 2명 이상 선택하도록 가이드
    if (_selectedIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 채팅은 최소 2명 이상 선택해야 합니다.')),
      );
      return;
    }

    final roomName = _buildGroupName();

    try {
      final room = await _chatApi.createGroupRoom(
        roomName: roomName,
        memberUserIds: _selectedIds.toList(),
      );

      final roomId = room['roomId'] as int?;
      final roomType =
          (room['chatRoomType'] ?? room['roomType'] ?? 'GROUP') as String;

      if (roomId == null) {
        throw Exception('roomId가 응답에 없습니다.');
      }

      if (!mounted) return;

      Navigator.of(context).pop(); // 선택 페이지 닫기
      Navigator.pushNamed(
        context,
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
        SnackBar(content: Text('그룹 채팅방 생성 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    final filtered = _friends
        .where(
          (friend) =>
              _q.isEmpty ||
              (friend['nickname'] as String? ?? '')
                  .toLowerCase()
                  .contains(_q.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SizedBox(height: topPad),
          _TopBar(
            onClose: () => Navigator.pop(context),
            isGroupChat: widget.isGroupChat,
            canConfirm: _selectedIds.isNotEmpty,
            onConfirm: _createGroupChat,
          ),
          const SizedBox(height: 12),
          _SearchField(
            onChanged: (v) => setState(() => _q = v.trim()),
          ),
          const SizedBox(height: 6),
          const _SectionLabel(text: '친구'),
          Expanded(
            child: _buildBody(filtered),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<dynamic> filteredFriends) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (filteredFriends.isEmpty) {
      return const Center(
        child: Text(
          '검색된 친구가 없습니다.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: filteredFriends.length,
      itemBuilder: (_, idx) {
        final friend = filteredFriends[idx];
        final friendId = friend['userId'] as int;
        final isSelected = _selectedIds.contains(friendId);

        return FriendListItem(
          name: friend['nickname'] ?? '',
          avatar: friend['profileImageUrl'] ?? '',
          selected: widget.isGroupChat ? isSelected : false,
          onTap: () => _handleFriendTap(friend),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onClose,
    required this.isGroupChat,
    required this.canConfirm,
    required this.onConfirm,
  });

  final VoidCallback onClose;
  final bool isGroupChat;
  final bool canConfirm;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: AppColors.text),
            ),
          ),
          const Text(
            '대화상대 선택',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isGroupChat)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: canConfirm ? onConfirm : null,
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: canConfirm
                        ? const Color(0xFFE3E9F0)
                        : const Color(0xFF6E7073),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: TextField(
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
          cursorColor: const Color(0xFFE3E9F0),
          decoration: InputDecoration(
            hintText: '이름(초성), 전화번호 검색',
            hintStyle: const TextStyle(
              color: Color(0xFF8C8D90),
              fontSize: 15,
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF8C8D90)),
            filled: true,
            fillColor: const Color(0xFF1A1B1D),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8C8D90),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
