// lib/core/fcm/fcm_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';   // UI 사용
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../chat/current_chat_tracker.dart';
import '../chat/chat_friend_cache.dart'; // [추가] 친구 프로필 캐시 사용
import '../../main.dart'; // navigatorKey 접근용

// 백그라운드 메시지 핸들러
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("[FCM] 백그라운드 메시지 수신: ${message.messageId}");
}

class FcmService {
  static final FcmService instance = FcmService._();
  FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final _storage = const FlutterSecureStorage();

  // [추가] 초기화 여부 체크 (중복 리스너 방지)
  bool _isInitialized = false;

  /// 초기화 (앱 시작 시 호출)
  Future<void> initialize() async {
    // 이미 초기화되었다면 토큰만 갱신하고 리스너는 다시 등록하지 않음
    if (_isInitialized) {
      debugPrint('[FCM] 이미 초기화됨. 토큰만 갱신합니다.');
      await _syncToken();
      return;
    }

    // 1. 권한 요청
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('[FCM] 알림 권한 거부됨');
      return;
    }

    // 2. 포그라운드 알림 채널 설정 (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 3. 로컬 알림 초기화
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 4. 핸들러 등록 (여기서 딱 한 번만 등록됨)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // 5. 토큰 처리
    await _syncToken();
    
    // 초기화 완료 플래그 설정
    _isInitialized = true;
  }

  /// [공개 메서드] 로그인 시 토큰 강제 갱신용
  Future<void> syncTokenOnly() async {
    await _syncToken();
  }

  Future<void> _syncToken() async {
    try {
      String? token;
      if (kIsWeb) {
        token = await _messaging.getToken(
          vapidKey: "BBaJ0R5EUnUTr9EKCR09nR9LQgKCc7TRVm79BHHNUPPOOOw62-HwD3fAL3IRE91TM64t9C8g1BK87zYHyvn6vB8",
        );
      } else {
        token = await _messaging.getToken();
      }
      
      debugPrint('[FCM] Token: $token');

      if (token != null) {
        await _sendTokenToServer(token);
      }

      // 토큰 갱신 스트림은 중복 등록 방지를 위해 초기화 때만 연결하거나, 
      // 여기서는 단순 호출용으로 둠 (listen은 한 번만 하는 게 좋음)
      // _messaging.onTokenRefresh.listen... (생략하거나 initialize로 이동 권장)
    } catch (e) {
      debugPrint('[FCM] 토큰 가져오기 실패: $e');
    }
  }

  Future<void> _sendTokenToServer(String fcmToken) async {
    try {
      final jwt = await _storage.read(key: 'jwt_token');
      if (jwt == null) return;

      final uri = Uri.parse('${ApiConstants.baseUrl}/api/push/tokens');
      
      String platform;
      if (kIsWeb) {
        platform = 'WEB';
      } else {
        platform = Platform.isAndroid ? 'ANDROID' : 'IOS';
      }

      String deviceId = 'device_unknown';
      try {
         if (!kIsWeb) {
            deviceId = 'device_${Platform.operatingSystem}'; 
         } else {
            deviceId = 'device_web_browser';
         }
      } catch(e) {
         deviceId = 'device_web';
      }

      final body = jsonEncode({
        "token": fcmToken,
        "deviceId": deviceId,
        "platform": platform
      });

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: body,
      );

      if (res.statusCode == 200) {
        debugPrint('[FCM] 토큰 서버 저장 성공');
      } else {
        debugPrint('[FCM] 토큰 저장 실패: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('[FCM] 토큰 전송 에러: $e');
    }
  }

  /// [Foreground] 앱이 켜져있을 때 메시지 수신
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] 포그라운드 수신: ${message.notification?.title}');

    final data = message.data;
    final String? msgRoomIdStr = data['roomId'];
    
    // 1. 현재 보고 있는 방인지 확인
    if (msgRoomIdStr != null) {
      final int msgRoomId = int.tryParse(msgRoomIdStr) ?? -1;
      final int? currentRoomId = CurrentChatTracker.instance.roomId;

      if (currentRoomId == msgRoomId) {
        debugPrint('[FCM] 현재 보고 있는 방 메시지라 알림 생략');
        return;
      }
    }

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification == null) return;

    // 2. 이미지 URL 확보 로직 (백엔드 데이터 -> 캐시 -> 기본 이미지)
    String? imageUrl = data['senderImage'] ?? data['profileImageUrl']; // 1순위: Payload
    final String senderName = data['senderName'] ?? notification.title ?? '';
    
    if (imageUrl == null || imageUrl.isEmpty) {
      // 2순위: 캐시된 친구 목록에서 찾기
      imageUrl = ChatFriendCache.instance.nicknameToAvatar[senderName];
    }

    // 3. 알림 표시 (모바일)
    if (!kIsWeb && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: const AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(data),
      );
    } 
    // 4. 알림 표시 (웹 - 스낵바)
    else if (kIsWeb) {
      final context = navigatorKey.currentState?.context;
      
      if (context != null) {
        // 이미 뜬 스낵바가 있다면 제거 (중복 쌓임 방지)
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                // 프로필 이미지 표시
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                    image: (imageUrl != null && imageUrl.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage('assets/images/avatars/avatar1.jpeg'),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        notification.title ?? '알림',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.body ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            width: 400,
            backgroundColor: const Color(0xFF2A2A2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: '보기',
              textColor: const Color(0xFFFEE500),
              onPressed: () => _navigateToRoom(data),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('[FCM] 알림 탭 (Background)');
    _navigateToRoom(message.data);
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('[FCM] 알림 탭 (Local)');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _navigateToRoom(data);
      } catch (e) {
        debugPrint('[FCM] Payload parse error: $e');
      }
    }
  }

  void _navigateToRoom(Map<String, dynamic> data) {
    final String? roomIdStr = data['roomId'];
    if (roomIdStr == null) return;

    final int roomId = int.parse(roomIdStr);
    final String senderName = data['senderName'] ?? '채팅방';

    navigatorKey.currentState?.pushNamed(
      '/chat/room',
      arguments: {
        'roomId': roomId,
        'title': senderName,
        'roomType': 'DIRECT',
      },
    );
  }
}