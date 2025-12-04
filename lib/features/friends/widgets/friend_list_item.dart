// lib/features/friends/widgets/friend_list_item.dart
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class FriendListItem extends StatelessWidget {
  final String name;
  final String avatar; // 프로필 이미지 URL (없으면 아이콘)
  final VoidCallback onTap;

  const FriendListItem({
    super.key,
    required this.name,
    required this.avatar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white10,
      highlightColor: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // 프로필 이미지
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF44474C),
              backgroundImage: avatar.isNotEmpty
                  ? NetworkImage(avatar)
                  : null,
              child: avatar.isEmpty
                  ? const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // 이름
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
