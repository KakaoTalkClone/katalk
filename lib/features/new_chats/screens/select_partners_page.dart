// lib/features/new_chats/screens/select_partners_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/friend_list_item.dart';
import '../../chats/data/chat_api.dart';

class SelectPartnersPage extends StatefulWidget {
  final bool isGroupChat;

  const SelectPartnersPage({super.key, required this.isGroupChat});

  @override
  State<SelectPartnersPage> createState() => _SelectPartnersPageState();
}

class _SelectPartnersPageState extends State<SelectPartnersPage> {
  final Set<int> _selectedIds = {}; // Store selected friend IDs
  final ChatApi _chatApi = ChatApi(); // ✅ ChatApi 인스턴스

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
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 친구 하나 탭했을 때 동작
  void _handleFriendTap(Map<String, dynamic> friend) async {
    if (widget.isGroupChat) {
      // 그룹 채팅 모드: 선택 토글
      final friendId = friend['userId'] as int;
      setState(() {
        if (_selectedIds.contains(friendId)) {
          _selectedIds.remove(friendId);
        } else {
          _selectedIds.add(friendId);
        }
      });
    } else {
      // 1:1 채팅 모드: 실제 방 생성 후 입장
      try {
        final partnerId = friend['userId'] as int?;
        final nickname = friend['nickname'] as String? ?? '새로운 채팅';

        if (partnerId == null) {
          throw Exception('userId가 없습니다.');
        }

        // ✅ 인스턴스로 호출
        final room = await _chatApi.createDirectRoom(partnerId);

        final roomId = room['roomId'];
        final roomType = room['roomType'] ?? 'DIRECT';
        final roomName = room['roomName'] ?? nickname;

        if (!mounted) return;

        Navigator.of(context).pop(); // 선택 페이지 닫기
        Navigator.pushNamed(
          context,
          '/chat/room',
          arguments: {
            'roomId': roomId,
            'roomType': roomType,
            'title': roomName,
            'partnerInfo': partnerId,
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

  /// ✅ 그룹 채팅 생성 버튼(확인) 눌렀을 때
  /// 지금은 아직 백엔드 그룹 생성 API 안 붙이고,
  /// 선택된 멤버 정보만 들고 채팅방 화면으로 진입하는 스텁 버전.
  Future<void> _createGroupChat() async {
    if (!widget.isGroupChat || _selectedIds.isEmpty) return;

    final selectedFriends = _friends
        .where((f) => _selectedIds.contains(f['userId'] as int))
        .toList();

    final title = '새로운 그룹 채팅 (${selectedFriends.length}명)';

    // TODO: 나중에 여기에서 ChatApi로 실제 그룹 방 생성 API 호출

    Navigator.of(context).pop(); // 선택 페이지 닫기
    Navigator.pushNamed(
      context,
      '/chat/room',
      arguments: {
        'roomId': null, // 아직 서버 방 없음
        'roomType': 'GROUP',
        'title': title,
        'partnerInfo':
            selectedFriends.map((f) => f['userId'] as int).toList(),
      },
    );
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
            onConfirm: _createGroupChat, // ✅ 이제 정의돼 있음
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
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 15,
          ),
          cursorColor: const Color(0xFFE3E9F0),
          decoration: InputDecoration(
            hintText: '이름(초성), 전화번호 검색',
            hintStyle: const TextStyle(
              color: Color(0xFF8C8D90),
              fontSize: 15,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Color(0xFF8C8D90),
            ),
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
