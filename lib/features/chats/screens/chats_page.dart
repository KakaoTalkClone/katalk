import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/dummy_chats.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/new_chat_sheet.dart';

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
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
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
      body: ListView.builder(
        itemCount: kDummyChats.length + 1,
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
          final c = kDummyChats[index - 1];
          final name = c['name'] ?? '';
          return ChatListItem(
            avatar: c['avatar'] ?? '',
            name: name,
            message: c['message'] ?? '',
            time: c['time'] ?? '',
            onTap: () {
              Navigator.pushNamed(
                context,
                '/chat/room',
                arguments: {'title': name},
              );
            },
          );
        },
      ),
    );
  }
}
