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

                  return MessageBubble(
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
