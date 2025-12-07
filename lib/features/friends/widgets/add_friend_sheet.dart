// lib/features/friends/widgets/add_friend_sheet.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../screens/add_friend_by_id_screen.dart';
import '../screens/add_friend_by_phone_screen.dart';

class AddFriendSheet extends StatelessWidget {
  const AddFriendSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const sheetBg = Color(0xFF111113);
    final topPad = MediaQuery.of(context).padding.top;

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
                      '친구 추가',
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
                  _Category(icon: Icons.person_add_alt_1, label: 'ID로 추가', screen: AddFriendByIdScreen()),
                  _Category(icon: Icons.contact_phone, label: '연락처로 추가', screen: AddFriendByPhoneScreen()),
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
  const _Category({required this.icon, required this.label, required this.screen});
  final IconData icon;
  final String label;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => screen),
        );
        if (result == true) {
          // The sheet that presented this screen should be refreshed.
          // Pop this sheet and return true to the caller (FriendsScreen)
          Navigator.of(context).pop(true);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFE3E9F0), size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
