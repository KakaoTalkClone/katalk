import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MessageInputBar extends StatelessWidget {
  const MessageInputBar({super.key});

  static const double _h = 44;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _circleIconButton(
              child: const Icon(Icons.add, size: 20, color: Color(0xFFE3E9F0)),
              onTap: () {},
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: _h,
                child: TextField(
                  style: const TextStyle(color: AppColors.text, fontSize: 16),
                  cursorColor: const Color(0xFFE3E9F0),
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: '메시지 입력',
                    hintStyle: const TextStyle(color: Color(0xFF8C8D90)),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFF1A1B1D),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.emoji_emotions_outlined, color: Color(0xFFE3E9F0)),
                      tooltip: '이모지',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _circleIconButton(
              child: const Text(
                '#',
                style: TextStyle(
                  color: Color(0xFFE3E9F0),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () {},
            ), // ← 입력창 밖, 오른쪽
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton({required Widget child, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: _h,
        height: _h,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1B1D),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
    ));
  }
}
