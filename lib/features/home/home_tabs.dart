import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/k_bottom_nav.dart';
import '../friends/screens/friends_page.dart';
import '../chats/screens/chats_page.dart';

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  // 0: 친구, 1: 채팅, 2: 오픈채팅(placeholder), 3: 쇼핑(placeholder), 4: 더보기(placeholder)
  int _index = 1; // 시작을 채팅으로
  late final PageController _pc = PageController(initialPage: _index);

  void _onTap(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    _pc.animateToPage(
      i,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: PageView(
        controller: _pc,
        onPageChanged: (i) => setState(() => _index = i),
        // 스와이프 허용(원하면 NeverScrollableScrollPhysics 로 막을 수 있음)
        children: const [
          FriendsPage(),      // 0
          ChatsPage(),        // 1
          _PlaceholderTab(label: '오픈채팅'), // 2
          _PlaceholderTab(label: '쇼핑'),     // 3
          _PlaceholderTab(label: '더보기'),   // 4
        ],
      ),
      bottomNavigationBar: KBottomNav(
            currentIndex: _index,
            onTap: _onTap,
        ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(label, style: const TextStyle(color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: Center(
        child: Text(label, style: const TextStyle(color: AppColors.text)),
      ),
    );
  }
}
