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
        title: const Text('친구', style: TextStyle(color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: const Center(child: Text('FriendsPage', style: TextStyle(color: AppColors.text))),
    );
  }
}
