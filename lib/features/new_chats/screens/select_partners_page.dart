// lib/features/new_chats/screens/select_partners_page.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/data/dummy_friends.dart';
import '../widgets/friend_list_item.dart';

class SelectPartnersPage extends StatefulWidget {
  const SelectPartnersPage({super.key});

  @override
  State<SelectPartnersPage> createState() => _SelectPartnersPageState();
}

class _SelectPartnersPageState extends State<SelectPartnersPage> {
  final Set<int> _selected = {};
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    final filtered = kDummyFriends
        .asMap()
        .entries
        .where((e) => _q.isEmpty || e.value['name']!.toString().contains(_q))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          SizedBox(height: topPad),
         _TopBar(
            onClose: () => Navigator.pop(context),
            canConfirm: _selected.isNotEmpty,
            onConfirm: () {
                // 선택 로직은 지금 무시하고, 단순 진입만
                Navigator.pushNamed(
                context,
                '/chat/room',
                arguments: {'title': '새로운 채팅'}, // 필요하면 선택한 친구 이름으로 교체 가능
                );
            },
            ),

          const SizedBox(height: 12),
          _SearchField(onChanged: (v) => setState(() => _q = v.trim())),
          const SizedBox(height: 6),
          const _SectionLabel(text: '친구'),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero, // ✅ 리스트 상단 여백 제거
              itemCount: filtered.length,
              itemBuilder: (_, idx) {
                final i = filtered[idx].key;
                final f = filtered[idx].value;
                final selected = _selected.contains(i);
                return FriendListItem(
                  name: f['name'] ?? '',
                  avatar: f['avatar'] ?? '',
                  selected: selected,
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selected.remove(i);
                      } else {
                        _selected.add(i);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onClose,
    required this.canConfirm,
    required this.onConfirm,
  });

  final VoidCallback onClose;
  final bool canConfirm;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: AppColors.text),
            ),
          ),
          const Text(
            '대화상대 선택',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: canConfirm ? onConfirm : null,
              child: Text(
                '확인',
                style: TextStyle(
                  color: canConfirm ? const Color(0xFFE3E9F0) : const Color(0xFF6E7073),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 44,
        child: TextField(
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
          cursorColor: const Color(0xFFE3E9F0),
          decoration: InputDecoration(
            hintText: '이름(초성), 전화번호 검색',
            hintStyle: const TextStyle(color: Color(0xFF8C8D90), fontSize: 15),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF8C8D90)),
            filled: true,
            fillColor: const Color(0xFF1A1B1D),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4), // ✅ 더 빡빡하게
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8C8D90),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
