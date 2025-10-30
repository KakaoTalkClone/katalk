import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        title: const Text('친구',
            style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: const Center(
        child: Text('친구 리스트 영역', style: TextStyle(color: AppColors.text)),
      ),
    );
  }
}
