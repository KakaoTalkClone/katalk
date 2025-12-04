// lib/features/chats/screens/chats_page.dart
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart'; // ✅ baseUrl 사용
import '../data/chat_api.dart';
import '../data/chat_room_models.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/new_chat_sheet.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final ChatApi _api = ChatApi(); // ✅ 인스턴스

  bool _isLoading = true;
  String? _error;
  List<ChatRoomSummary> _rooms = [];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rooms = await _api.fetchMyChatRooms(page: 1, size: 20);
      setState(() {
        _rooms = rooms;
      });
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

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final isAm = hour < 12;
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = isAm ? '오전' : '오후';
    return '$period $h12:$minute';
  }

  /// ✅ 백엔드 thumbnailUrl → 실제로 쓸 avatar URL 계산
  String _buildAvatarUrl(ChatRoomSummary room) {
    final thumb = room.thumbnailUrl;

    if (thumb != null && thumb.isNotEmpty) {
      // 1) 이미 절대 URL 인 경우 (http/https)
      if (thumb.startsWith('http://') || thumb.startsWith('https://')) {
        return thumb;
      }

      // 2) "/files/xxx" 같은 상대경로인 경우 → baseUrl 앞에 붙여줌
      if (thumb.startsWith('/')) {
        // ApiConstants.baseUrl 이 "http://localhost:8080" 같이 slash 없이 끝난다고 가정
        return '${ApiConstants.baseUrl}$thumb';
      }

      // 3) 기타 문자열이면 일단 baseUrl 뒤에 붙여보기
      return '${ApiConstants.baseUrl}/$thumb';
    }

    // 4) 썸네일이 아예 없으면 기존 기본 아바타 사용
    return room.roomType == 'DIRECT'
        ? 'assets/images/avatars/avatar1.jpeg'
        : 'assets/images/avatars/group_default.png';
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(width: 14);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          '채팅',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.text),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: '검색',
            icon: const Icon(Icons.search, color: AppColors.text),
            visualDensity: VisualDensity.compact,
            constraints:
                const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          gap,
          IconButton(
            onPressed: () {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: 'dismiss',
                barrierColor: Colors.black.withOpacity(0.55),
                transitionDuration: const Duration(milliseconds: 220),
                pageBuilder: (_, __, ___) => const NewChatSheet(),
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
            },
            tooltip: '새 대화',
            icon: const Icon(Icons.add_comment_outlined,
                color: AppColors.text),
            visualDensity: VisualDensity.compact,
            constraints:
                const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          gap,
          IconButton(
            onPressed: _loadRooms,
            tooltip: '새로고침',
            icon: const Icon(Icons.refresh, color: AppColors.text),
            visualDensity: VisualDensity.compact,
            constraints:
                const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRooms,
        color: AppColors.accent,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.red, size: 32),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _loadRooms,
                  child: const Text(
                    '다시 시도',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _rooms.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/ad.jpg',
                fit: BoxFit.cover,
              ),
            ),
          );
        }

        final room = _rooms[index - 1];
        final avatar = _buildAvatarUrl(room); // ✅ 여기서 avatar URL 계산

        return ChatListItem(
          avatar: avatar,
          name: room.roomName.isNotEmpty
              ? room.roomName
              : '이름 없는 채팅방',
          message: room.lastMessagePreview,
          time: _formatTime(room.lastMessageAt),
          unreadCount: room.unreadCount,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/chat/room',
              arguments: {
                'roomId': room.roomId,
                'roomType': room.roomType,
                'title': room.roomName,
              },
            );
          },
        );
      },
    );
  }
}
