// lib/features/chats/widgets/new_chat_sheet.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../new_chats/screens/select_partners_page.dart';

class NewChatSheet extends StatelessWidget {
  const NewChatSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const sheetBg = Color(0xFF111113);
    final topPad = MediaQuery.of(context).padding.top;

    // void goSelect() {
    //   Navigator.of(context).push(
    //     MaterialPageRoute(builder: (_) => const SelectPartnersPage()),
    //   );
    // }

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: sheetBg,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 20),
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _Category(icon: Icons.chat_bubble_outline, label: '일반채팅'),
                  _Category(icon: Icons.folder_copy_outlined, label: '팀채팅'),
                  _Category(icon: Icons.lock_outline, label: '비밀채팅'),
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

class _Category extends StatelessWidget {
  const _Category({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SelectPartnersPage()),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Icon(icon, color: Color(0xFFE3E9F0), size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
