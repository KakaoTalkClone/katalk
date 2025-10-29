import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart'; // ← 상대경로

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text(
          '채팅',
          style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      floatingActionButton: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.kakaoYellow,
          foregroundColor: AppColors.text,
        ),
        onPressed: () {},
        child: const Text('새 채팅'),
      ),
      body: const Center(child: Text('...')),
    );
  }
}
