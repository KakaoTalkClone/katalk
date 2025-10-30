import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NewChatSheet extends StatelessWidget {
  const NewChatSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const sheetBg = Color(0xFF111113);
    final topPad = MediaQuery.of(context).padding.top; // 상태바 높이

    return Material(
      color: Colors.transparent, // 아래 영역 투명 (뒤 화면 보이게)
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: sheetBg, // 상태바까지 이 색으로 채움
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 20), // 컨텐츠는 상태바 아래부터
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: AppColors.text),
                        tooltip: '닫기',
                      ),
                    ),
                    const Text(
                      '새로운 채팅',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _CategoryItem(
                    icon: Icons.chat_bubble_outline,
                    label: '일반채팅',
                  ),
                  _CategoryItem(
                    icon: Icons.folder_copy_outlined,
                    label: '팀채팅',
                  ),
                  _CategoryItem(
                    icon: Icons.lock_outline,
                    label: '비밀채팅',
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: const Color(0xFFE3E9F0)), // 배경 없이 아이콘만
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
