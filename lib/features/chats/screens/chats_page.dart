// lib/features/chats/screens/chats_page.dart
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../data/chat_api.dart';
import '../data/chat_room_models.dart';
import '../data/chat_rooms_socket_service.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/new_chat_sheet.dart';
import '../../../core/chat/chat_friend_cache.dart'; // [추가]

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final ChatApi _api = ChatApi();

  ChatRoomsSocketService? _roomsSocket;

  bool _isLoading = true;
  String? _error;
  List<ChatRoomSummary> _rooms = [];

  @override
  void initState() {
    super.initState();
    _roomsSocket = ChatRoomsSocketService(
      onUpdate: _handleRoomUpdate,
      onError: (err) => debugPrint('[ChatsPage] rooms socket error: $err'),
    );
    // 웹소켓 연결
    _roomsSocket!.connectAndSubscribe();
    // 초기 목록 로딩
    _loadRooms();
  }

  @override
  void dispose() {
    _roomsSocket?.dispose();
    super.dispose();
  }

  /// 웹소켓으로 방 목록에 변화가 전달됐을 때
  void _handleRoomUpdate(RoomListUpdate update) async {
    debugPrint('[ChatsPage] room update from ws: roomId=${update.roomId}');

    // 가장 안전한 방식: 그냥 목록 다시 조회
    try {
      final rooms = await _api.fetchMyChatRooms(page: 1, size: 20);
      
      // [호출] 웹소켓 업데이트 시 캐시도 재확인
      _updateCacheFromRooms(rooms);

      if (!mounted) return;
      setState(() {
        _rooms = rooms;
      });
    } catch (e) {
      debugPrint('[ChatsPage] reload on ws error: $e');
    }
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rooms = await _api.fetchMyChatRooms(page: 1, size: 20);
      
      // [호출] 초기 로드 시 캐시 업데이트
      _updateCacheFromRooms(rooms);

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

  /// [신규 로직] 채팅방 목록에서 닉네임과 썸네일 URL을 추출하여 캐시에 저장
  void _updateCacheFromRooms(List<ChatRoomSummary> rooms) {
      final cacheUpdates = <String, String>{};
      for (var room in rooms) {
        // DIRECT 채팅방이고, 썸네일 URL과 방 이름(닉네임)이 있을 경우 캐싱
        if (room.roomType == 'DIRECT' && 
            room.thumbnailUrl != null && 
            room.thumbnailUrl!.isNotEmpty && 
            room.roomName.isNotEmpty) {
          // NOTE: roomName을 상대방 닉네임으로 가정하고 캐시 키로 사용
          cacheUpdates[room.roomName] = room.thumbnailUrl!;
        }
      }
      ChatFriendCache.instance.nicknameToAvatar.addAll(cacheUpdates);
      debugPrint('[ChatCache] 캐시 업데이트 됨. 채팅방 목록 기반으로 ${cacheUpdates.length}개 추가.');
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

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(width: 14);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
            icon: const Icon(Icons.add_comment_outlined, color: AppColors.text),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          gap,
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
                const Icon(Icons.error_outline, color: Colors.red, size: 32),
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

        final fallbackAvatar = room.roomType == 'DIRECT'
            ? 'assets/images/avatars/avatar1.jpeg'
            : 'assets/images/avatars/group_default.png';

        return ChatListItem(
          avatarUrl: room.thumbnailUrl,      // 🔥 백엔드 썸네일
          fallbackAsset: fallbackAvatar,     // 🔥 없으면 기존 기본 아바타
          name: room.roomName.isNotEmpty ? room.roomName : '이름 없는 채팅방',
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