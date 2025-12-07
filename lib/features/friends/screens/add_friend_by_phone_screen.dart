// lib/features/friends/screens/add_friend_by_phone_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';

class AddFriendByPhoneScreen extends StatefulWidget {
  const AddFriendByPhoneScreen({super.key});

  @override
  State<AddFriendByPhoneScreen> createState() => _AddFriendByPhoneScreenState();
}

class _AddFriendByPhoneScreenState extends State<AddFriendByPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addFriend() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('친구의 연락처를 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception('로그인 토큰을 찾을 수 없습니다.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addFriendByPhoneEndpoint}'),
        headers: headers,
        body: json.encode({'phone': phone}),
      );

      if (!mounted) return;

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("친구 '$phone'가 성공적으로 추가되었습니다.")),
        );
        Navigator.of(context).pop(true);
      } else {
        final errorMessage = responseData['error']?['message'] ?? '알 수 없는 오류';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 추가 실패: $errorMessage')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('연락처로 친구 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              autofocus: true,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '친구 연락처를 입력하세요',
                hintStyle: TextStyle(color: Colors.white54),
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _addFriend,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      '추가',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
