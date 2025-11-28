import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 입력해 주세요.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final String? accessToken = responseData['data']['access'];
          if (accessToken != null) {
            await _storage.write(key: 'jwt_token', value: accessToken);
            // Navigate to main tabs
            Navigator.of(context).pushReplacementNamed('/');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('로그인 실패: 토큰을 받을 수 없습니다.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그인 실패: ${responseData['message'] ?? '알 수 없는 오류'}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Local light theme for this screen only
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: AppColors.kakaoYellow,
        scaffoldBackgroundColor: Colors.white,
      ),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const Text(
                '카카오톡을 시작합니다',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '사용하던 카카오계정이 있다면\n이메일 또는 전화번호로 로그인해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '이메일 또는 전화번호',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login, // Call _login function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kakaoYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '회원가입',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '카카오계정 또는 비밀번호 찾기',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
