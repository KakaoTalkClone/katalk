import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FriendListItem extends StatelessWidget {
  const FriendListItem({
    super.key,
    required this.name,
    required this.avatar,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String avatar;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            const SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                avatar.isEmpty ? 'assets/images/avatars/avatar1.jpeg' : avatar,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _SelectDot(selected: selected),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class _SelectDot extends StatelessWidget {
  const _SelectDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    const off = Color(0xFF8C8D90);
    const on  = Color(0xFFE3E9F0);

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? on : off, width: 2),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: selected ? 14 : 0,
        height: selected ? 14 : 0,
        decoration: const BoxDecoration(color: on, shape: BoxShape.circle),
      ),
    );
  }
}
