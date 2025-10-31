// lib/features/chatting_room/screens/chat_room_page.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/message_input_bar.dart';

class ChatRoomPage extends StatelessWidget {
  ChatRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final title = (args?['title'] as String?) ?? '채팅방';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 48,
        centerTitle: true, // ✅ 가운데 정렬
        leadingWidth: 44,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
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
      body: const SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: SizedBox()),
            MessageInputBar(), // ✅ 하단 입력 바
          ],
        ),
      ),
    );
  }
}
