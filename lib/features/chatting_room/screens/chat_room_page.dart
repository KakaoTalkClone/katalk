// lib/features/chatting_room/screens/chat_room_page.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/data/server.dart';
import '../widgets/message_input_bar.dart';
import '../widgets/message_bubble.dart';

class ChatRoomPage extends StatelessWidget {
  const ChatRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // ✅ 앱바 타이틀 (채팅 상대 이름과 동일하게 사용)
    final title = (args?['title'] as String?) ?? '채팅방';

    // ✅ 더미 메시지 키: 지금은 title과 동일하게 사용
    final chatName = title;

    // ✅ Get messages from Server
    final server = Server();
    final messages = server.getMessages(chatName);

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
          title,
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
            // 🗨️ 채팅 메시지 리스트
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg['isMe'] as bool? ?? false;
                  final text = msg['message'] as String? ?? '';
                  final time = msg['time'] as String? ?? '';

                  return _MessageBubble(
                    text: text,
                    time: time,
                    isMe: isMe,
                  );
                },
              ),
            ),

            // ✏️ 하단 입력 바
            const MessageInputBar(),
          ],
        ),
      ),
    );
  }
}

/// 말풍선 위젯
class _MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;

  const _MessageBubble({
    required this.text,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    // 🔧 AppColors.primary 대신 직접 색 지정
    final bgColor = isMe
        ? const Color(0xFF1D9BF0) // 내 메시지 말풍선 색
        : const Color(0xFF2A2A2A); // 상대 말풍선 색
    final textColor = Colors.white;
    final align =
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: align,
        children: [
          if (!isMe) const SizedBox(width: 24),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: radius,
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 24),
        ],
      ),
    );
  }
}
