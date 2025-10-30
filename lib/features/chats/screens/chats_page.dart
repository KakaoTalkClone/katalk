import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        title: const Text('채팅',
            style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: AppColors.text),
        actions: const [
          Icon(Icons.search, color: AppColors.text),
          SizedBox(width: 8),
          Icon(Icons.notifications_none_rounded, color: AppColors.text),
          SizedBox(width: 8),
          Icon(Icons.settings_outlined, color: AppColors.text),
          SizedBox(width: 8),
        ],
      ),
      body: const Center(
        child: Text('채팅 리스트 영역', style: TextStyle(color: AppColors.text)),
      ),
    );
  }
}
