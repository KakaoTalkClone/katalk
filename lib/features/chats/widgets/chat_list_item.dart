import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChatListItem extends StatelessWidget {
  final String avatar; // ""면 이니셜
  final String name;
  final String message;
  final String time;
  final VoidCallback? onTap;

  const ChatListItem({
    super.key,
    required this.avatar,
    required this.name,
    required this.message,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: _Avatar(avatar: avatar, name: name), // ⬅ 둥근 사각형 아바타
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
      trailing: Text(
        time,
        style: const TextStyle(color: Colors.white54, fontSize: 11),
      ),
      onTap: onTap,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatar, required this.name});

  final String avatar;
  final String name;

  @override
  Widget build(BuildContext context) {
    const radius = 18.0; // ✅ 살짝 둥근 모서리
    const size = 48.0;

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
