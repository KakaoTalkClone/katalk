import 'package:flutter/material.dart';

class FriendProfileScreen extends StatelessWidget {
  final bool isMyProfile;

  const FriendProfileScreen({super.key, required this.isMyProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB1C1D7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.qr_code, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(), // Empty container to push content down
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(35.0),
            child: Image.asset(
              isMyProfile
                  ? 'assets/images/avatars/avatar1.jpeg'
                  : 'assets/images/avatars/avatar2.jpeg',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Text(
            isMyProfile ? '내 이름' : '친구 이름',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '상태 메시지',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const Spacer(),
          const Divider(
            color: Colors.white,
            // indent: ,
            // endIndent: 30,
            thickness: 0.5,
          ),
          const SizedBox(height: 20),
          _buildActionButtons(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (isMyProfile) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(
            icon: Icons.chat_bubble,
            label: '나와의 채팅',
            onPressed: () {
              Navigator.of(context).pushNamed('/chat/room');
            },
          ),
          _buildIconButton(icon: Icons.edit, label: '프로필 편집', onPressed: () {}),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(
            icon: Icons.chat_bubble,
            label: '1:1 채팅',
            onPressed: () {
              Navigator.of(context).pushNamed('/chat/room');
            },
          ),
          _buildIconButton(icon: Icons.call, label: '통화하기', onPressed: () {}),
        ],
      );
    }
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
