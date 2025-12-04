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
  late final ChatSocketService _socket;

  final ScrollController _scrollController = ScrollController();

  String _title = '채팅방';
  int? _roomId;
  String _roomType = 'DIRECT';

  int? _myUserId;
  bool _isLoading = true;
  String? _error;
  List<ChatMessage> _messages = [];

  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _socket = ChatSocketService(
      onMessage: (msg) {
        if (!mounted) return;
        if (_roomId == null || msg.roomId != _roomId) return;

        setState(() {
          // 같은 messageId 중복 방지
          final exists =
              _messages.any((m) => m.messageId == msg.messageId);
          if (!exists) {
            _messages.add(msg);
          }
        });

        _scrollToBottom();
      },
      onError: (err) {
        debugPrint('[ChatRoomPage] socket error: $err');
      },
    );
  }

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
        _messages = msgs; // 일단 그대로 저장
      });

      await _socket.connectAndSubscribe(_roomId!);

      // 최초 로딩 후 아래로 스크롤
      _scrollToBottom();
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

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  /// 📨 전송 버튼 눌렀을 때 – 실제 서버 전송
  void _handleSendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (_roomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('채팅방 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.'),
        ),
      );
      return;
    }

    _socket.sendText(_roomId!, trimmed);
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
    _socket.dispose();
    _scrollController.dispose();
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

    // ✅ createdAt 기준으로 오래된 → 최신 순 정렬
    final sorted = [..._messages]
      ..sort((a, b) {
        final ad = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return ad.compareTo(bd);
      });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final msg = sorted[index];
        final isMe = (_myUserId != null && msg.senderId == _myUserId);

        return _MessageBubble(
          text: msg.content,
          time: _formatTime(msg.createdAt),
          isMe: isMe,
          nickname: msg.senderNickname,
        );
      },
    );
  }
}

/// 말풍선 위젯 (이전 버전 그대로)
class _MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final String nickname;
  final String? avatarUrl;

  const _MessageBubble({
    required this.text,
    required this.time,
    required this.isMe,
    required this.nickname,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      // 내가 보낸 메시지
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE400),
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
      // 상대가 보낸 메시지
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 둥근 사각형 아바타
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF44474C),
                borderRadius: BorderRadius.circular(15),
                image: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (avatarUrl == null || avatarUrl!.isEmpty)
                  ? const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 22,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            // 닉네임 + 말풍선 + 시간
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    nickname,
                    style: const TextStyle(
                      color: Color(0xFFF5F5F5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
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
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
