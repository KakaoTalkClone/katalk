// lib/features/chatting_room/screens/chat_room_page.dart
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../chats/data/chat_api.dart';
import '../../chats/data/chat_room_models.dart';
import '../data/chat_socket_service.dart';
import '../widgets/message_input_bar.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ChatApi _api = ChatApi();
  ChatSocketService? _socket;

  String _title = '채팅방';
  int? _roomId;
  String _roomType = 'DIRECT';

  int? _myUserId;
  bool _isLoading = true;
  String? _error;
  List<ChatMessage> _messages = [];

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    _title = (args?['title'] as String?) ?? '채팅방';
    _roomId = args?['roomId'] as int?;
    _roomType = (args?['roomType'] as String?) ?? 'DIRECT';

    _loadInitial();
  }

  Future<void> _loadInitial() async {
    if (_roomId == null) {
      setState(() {
        _isLoading = false;
        _error = 'roomId가 전달되지 않았습니다.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final myId = await _api.fetchMyUserId();
      final msgs =
          await _api.fetchMessages(roomId: _roomId!, page: 1, size: 50);

      if (!mounted) return;
      setState(() {
        _myUserId = myId;
        _messages = msgs;
      });

      // ✅ REST로 기존 메시지 불러온 다음 WebSocket 연결
      await _initSocket();
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

  Future<void> _initSocket() async {
    if (_roomId == null) return;

    _socket ??= ChatSocketService(
      onMessage: (ChatMessage msg) {
        if (!mounted) return;
        // 혹시 다른 방 메시지가 날아오면 무시
        if (msg.roomId != _roomId) return;
        setState(() {
          _messages.add(msg);
        });
      },
      onError: (err) {
        debugPrint('[ChatRoomPage] socket error: $err');
      },
    );

    await _socket!.connectAndSubscribe(_roomId!);
  }

  /// 📨 전송 버튼 눌렀을 때 (실제 서버로 보내기)
  void _handleSendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (_roomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('roomId가 없습니다.')),
      );
      return;
    }

    if (_socket == null || !_socket!.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('채팅 서버에 연결 중입니다. 잠시 후 다시 시도해주세요.')),
      );
      return;
    }

    // ✅ 실제 서버로 STOMP 전송 → 서버가 저장 → 브로드캐스트 →
    //    onMessage에서 _messages에 추가됨
    _socket!.sendText(_roomId!, trimmed);
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
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 48,
        centerTitle: true,
        leadingWidth: 44,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.text,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
          tooltip: '뒤로',
        ),
        title: Text(
          _title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Icon(Icons.search, color: AppColors.text, size: 22),
          SizedBox(width: 12),
          Icon(Icons.menu, color: AppColors.text, size: 22),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            MessageInputBar(
              onSend: _handleSendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 32),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          '아직 메시지가 없습니다.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = (_myUserId != null && msg.senderId == _myUserId);

        // 나중에 상대 프로필 URL 생기면 여기 avatarUrl에 넣어주면 됨
        return _MessageBubble(
          text: msg.content,
          time: _formatTime(msg.createdAt),
          isMe: isMe,
          avatarUrl: null,
        );
      },
    );
  }
}

/// 말풍선 위젯 (카톡 느낌: 내 메시지 노란색, 상대 회색 + 프로필 + 시간 위치)
class _MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final String? avatarUrl;

  const _MessageBubble({
    required this.text,
    required this.time,
    required this.isMe,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      // 내가 보낸 메시지: 오른쪽 정렬 + 노란 말풍선 + 시간은 왼쪽
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 시간 (왼쪽)
            Text(
              time,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 4),
            // 말풍선
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE400), // 카톡 노란색
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 상대가 보낸 메시지: 왼쪽에 프로필, 그 옆 회색 말풍선, 오른쪽에 시간
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 아바타
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF44474C),
              backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: (avatarUrl == null || avatarUrl!.isEmpty)
                  ? const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            // 말풍선 + 시간
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2A2A2A), // 회색
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
