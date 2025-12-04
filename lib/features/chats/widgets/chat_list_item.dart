// lib/features/chats/widgets/chat_list_item.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChatListItem extends StatelessWidget {
  /// 백엔드에서 내려주는 썸네일 URL (없을 수도 있음)
  final String? avatarUrl;

  /// DIRECT / GROUP 에 따라 쓰던 기존 기본 아바타 asset 경로
  final String fallbackAsset;

  final String name;
  final String message;
  final String time;
  final int unreadCount;
  final VoidCallback? onTap;

  const ChatListItem({
    super.key,
    required this.avatarUrl,
    required this.fallbackAsset,
    required this.name,
    required this.message,
    required this.time,
    required this.unreadCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: _Avatar(
        avatarUrl: avatarUrl,
        fallbackAsset: fallbackAsset,
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    required this.avatarUrl,
    required this.fallbackAsset,
    required this.name,
  });

  final String? avatarUrl;
  final String fallbackAsset;
  final String name;

  @override
  Widget build(BuildContext context) {
    const radius = 18.0;
    const size = 48.0;

    // 1) 썸네일 URL 있으면 네트워크 이미지 우선
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _InitialFallback(
            name: name,
            fallbackAsset: fallbackAsset,
          ),
        ),
      );
    }

    // 2) 썸네일 없으면 기존 asset 아바타
    if (fallbackAsset.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          fallbackAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _InitialFallback(name: name, fallbackAsset: ''),
        ),
      );
    }

    // 3) 둘 다 없으면 이니셜 박스
    return _InitialFallback(name: name, fallbackAsset: '');
  }
}

class _InitialFallback extends StatelessWidget {
  const _InitialFallback({
    required this.name,
    required this.fallbackAsset,
  });

  final String name;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    const radius = 10.0;
    const size = 48.0;

    if (fallbackAsset.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          fallbackAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

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
