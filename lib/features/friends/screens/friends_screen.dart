import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),

        ],
      ),
      body: ListView(
        children: [
          _buildMyProfile(context),
          const Divider(),
          _buildFriendList(context),
        ],
      ),
    );
  }

  Widget _buildMyProfile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image.asset(
            'assets/images/avatars/avatar1.jpeg',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: const Text(
          '내 이름',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: const Text(
          '상태 메시지',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/friends/profile', arguments: {'isMyProfile': true});
        },
      ),
    );
  }

  Widget _buildFriendList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '친구 2',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: Image.asset(
              'assets/images/avatars/avatar2.jpeg',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: const Text(
            '친구 1',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: const Text(
            '상태 메시지 1',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          onTap: () {
            Navigator.pushNamed(context, '/friends/profile', arguments: {'isMyProfile': false});
          },
        ),
        ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: Image.asset(
              'assets/images/avatars/avatar1.jpeg',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: const Text(
            '친구 2',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: const Text(
            '상태 메시지 2',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          onTap: () {
            Navigator.pushNamed(context, '/friends/profile', arguments: {'isMyProfile': false});
          },
        ),
      ],
    );
  }
}
