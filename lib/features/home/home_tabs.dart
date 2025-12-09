import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/k_bottom_nav.dart';
import '../friends/screens/friends_screen.dart';
import '../chats/screens/chats_page.dart';
import '../login/screens/login_screen.dart';
import '../../core/chat/chat_friend_service.dart'; // [추가]

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  // 0: 친구, 1: 채팅, 2: 오픈채팅(placeholder), 3: 쇼핑(placeholder), 4: 더보기(placeholder)
  int _index = 1; // 시작을 채팅으로
  late final PageController _pc = PageController(initialPage: _index);

  @override
  void initState() {
    super.initState();
    // [추가] 앱 시작 시(자동 로그인) 친구 목록 캐싱
    _initCache();
  }

  Future<void> _initCache() async {
    // 친구 목록을 불러와서 캐시에 저장 (알림 프로필 사진용)
    await ChatFriendService.instance.loadFriendsToCache();
  }

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
        children: [
          const FriendsScreen(),      // 0
          const ChatsPage(),          // 1
          const _PlaceholderTab(label: '오픈채팅'), // 2
          const _PlaceholderTab(label: '쇼핑'),     // 3
          const _PlaceholderTab(label: '더보기'),   // 4
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
        child: Column( // New: Use a Column to hold multiple widgets
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(color: AppColors.text)),
            const SizedBox(height: 20), // Add some spacing
            if (label == '더보기') // Only show logout for '더보기' tab
              ElevatedButton(
                onPressed: () {
                  // Simulate logout: clear navigation stack and go to login
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('로그아웃', style: TextStyle(fontSize: 18)),
              ),
          ],
        ),
      ),
    );
  }
}