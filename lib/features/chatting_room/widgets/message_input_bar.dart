// lib/features/chatting_room/widgets/message_input_bar.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MessageInputBar extends StatefulWidget {
  const MessageInputBar({
    super.key,
    this.onSend,
  });

  /// 전송 버튼 눌렀을 때 호출되는 콜백
  final ValueChanged<String>? onSend;

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 부모에게 전달
    widget.onSend?.call(text);

    // 입력창 비우기
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        color: const Color(0xFF111214), // 기존 바탕 느낌 유지용
        child: Row(
          children: [
            // 왼쪽 + 버튼 (첨부, 이모티콘 등)
            IconButton(
              onPressed: () {
                // TODO: 나중에 사진/파일/이모티콘 붙일 거면 여기서 처리
              },
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF8C8D90),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),

            // 가운데 텍스트 입력
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1B1D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                  ),
                  cursorColor: AppColors.accent,
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '메시지 입력',
                    hintStyle: TextStyle(
                      color: Color(0xFF8C8D90),
                      fontSize: 15,
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),

            // 오른쪽: # → 전송 버튼으로 교체
            const SizedBox(width: 6),
            IconButton(
              onPressed: _handleSend,
              icon: const Icon(
                Icons.send_rounded,
                color: AppColors.accent, // 카톡 느낌 노랑/포인트색 쓰면 됨
                size: 22,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        ),
      ),
    );
  }
}
