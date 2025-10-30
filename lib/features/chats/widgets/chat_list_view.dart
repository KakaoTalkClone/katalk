import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/dummy_chats.dart';
import 'chat_list_item.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8), // 살짝 여유
      itemCount: kDummyChats.length,
      itemBuilder: (context, i) {
        final c = kDummyChats[i];
        return ChatListItem(
          avatar: c['avatar'] ?? '',
          name: c['name'] ?? '',
          message: c['message'] ?? '',
          time: c['time'] ?? '',
          onTap: () {
            // TODO: 채팅방 진입
          },
        );
      },
    );
  }
}
