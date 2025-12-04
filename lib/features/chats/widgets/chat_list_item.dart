// lib/features/chats/widgets/chat_list_item.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChatListItem extends StatelessWidget {
  /// fallback 로컬 아바타(없으면 "")
  final String avatar;
  /// 백엔드에서 내려준 썸네일 URL
  final String? thumbnailUrl;

  final String name;
  final String message;
  final String time;
  final int unreadCount;
  final VoidCallback? onTap;

  const ChatListItem({
    super.key,
    required this.avatar,
    required this.name,
    required this.message,
    required this.time,
    required this.unreadCount,
    this.thumbnailUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: _Avatar(
        avatar: avatar,
        thumbnailUrl: thumbnailUrl,
        name: name,
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        message,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 5),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.avatar,
    required this.thumbnailUrl,
    required this.name,
  });

  /// fallback 로컬 에셋 경로
  final String avatar;
  /// 서버에서 내려준 썸네일 URL
  final String? thumbnailUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    const radius = 18.0; // 살짝 둥근 모서리
    const size = 48.0;

    // 1️⃣ 서버 썸네일이 있으면 우선 사용
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          thumbnailUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackAvatar(
            avatar: avatar,
            name: name,
          ),
        ),
      );
    }

    // 2️⃣ 썸네일이 없으면 기존 로컬 에셋/이니셜 fallback
    return _FallbackAvatar(avatar: avatar, name: name);
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({
    required this.avatar,
    required this.name,
  });

  final String avatar;
  final String name;

  @override
  Widget build(BuildContext context) {
    const radius = 10.0;
    const size = 48.0;

    // 로컬 에셋이 지정돼 있으면 사용
    if (avatar.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          avatar,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _InitialFallback(name: name),
        ),
      );
    }

    // 에셋도 없으면 이니셜
    return _InitialFallback(name: name);
  }
}

class _InitialFallback extends StatelessWidget {
  const _InitialFallback({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    const radius = 10.0;
    const size = 48.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF212123),
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name.characters.first : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
