import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/data/server.dart';
import 'friend_profile_screen.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final server = Server();
    final friends = server.getFriendsForNewChat();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        // 1. AppBar Title Style to match ChatsPage
        title: const Text('친구', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.text),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.text),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
        children: [
          _buildMyProfile(context),
          const Divider(color: Colors.white10),
          _buildFriendList(context, friends),
        ],
      )),
    );
  }

  Widget _buildMyProfile(BuildContext context) {
    // 2. "My Profile" Style adjustments
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(22.0), // Slightly larger radius
          child: Image.asset(
            'assets/images/avatars/avatar1.jpeg',
            width: 58,
            height: 58,
            fit: BoxFit.cover,
          ),
        ),
        title: const Text(
          '내 이름',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.text), // Bolder
        ),
        subtitle: const Text(
          '상태 메시지',
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const FriendProfileScreen(isMyProfile: true),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child;
              },
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendList(BuildContext context, List<Map<String, String>> friends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text(
            '친구 ${friends.length}',
            style: const TextStyle(color: Colors.white54),
          ),
        ),
        ...friends.map((friend) {
          return _FriendListItem(
            name: friend['name']!,
            avatarUrl: friend['avatar']!,
            statusMessage: friend['statusMessage']!, // Pass status message
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FriendProfileScreen(isMyProfile: false, friendData: friend), // Pass friend data
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return child;
                  },
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          );
        })
        // .toList(),
      ],
    );
  }
}

// 3. Friend List Item Style adjustments
class _FriendListItem extends StatelessWidget {
  const _FriendListItem({
    // super.key,
    required this.name,
    required this.avatarUrl,
    required this.statusMessage, // Add statusMessage back
    required this.onTap,
  });

  final String name;
  final String avatarUrl;
  final String statusMessage; // Declare statusMessage
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(18.0), // Match ChatListItem
        child: Image.asset(
          avatarUrl,
          width: 48, // Match ChatListItem
          height: 48, // Match ChatListItem
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.text), // Match ChatListItem
      ),
      subtitle: Text( // Add subtitle back
        statusMessage,
        style: const TextStyle(fontSize: 13, color: Colors.white70),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
