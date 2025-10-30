// lib/features/chats/screens/chats_page.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/dummy_chats.dart';
import '../widgets/chat_list_item.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

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
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          gap,
          IconButton(
            onPressed: () {},
            tooltip: '새 대화',
            icon: const Icon(Icons.add_comment_outlined, color: AppColors.text),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          gap,
          IconButton(
            onPressed: () {},
            tooltip: '설정',
            icon: const Icon(Icons.settings_outlined, color: AppColors.text),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const SizedBox(width: 6),
        ],
      ),

      // ✅ 하나의 ListView에서 0번째만 배너, 나머지는 채팅 아이템
      body: ListView.builder(
        itemCount: kDummyChats.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // 상단 배너
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
          final c = kDummyChats[index - 1]; // 채팅 데이터는 -1 오프셋
          return ChatListItem(
            avatar: c['avatar'] ?? '',
            name: c['name'] ?? '',
            message: c['message'] ?? '',
            time: c['time'] ?? '',
            onTap: () {},
          );
        },
      ),
    );
  }
}
