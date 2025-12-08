import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../chat/current_chat_tracker.dart';
import '../../main.dart'; // navigatorKey 접근용

// 백그라운드 메시지 핸들러 (반드시 최상위 함수여야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("[FCM] 백그라운드 메시지 수신: ${message.messageId}");
  // 백그라운드는 OS가 알아서 알림을 띄우므로 별도 처리 불필요
}

class FcmService {
  static final FcmService instance = FcmService._();
  FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final _storage = const FlutterSecureStorage();

  /// 초기화 (main.dart에서 호출)
  Future<void> initialize() async {
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

    // 2. 포그라운드 알림 채널 설정 (Android 필수)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 3. 로컬 알림 초기화
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // 앱 아이콘 사용

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

    // 4. 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // 5. 토큰 처리
    _syncToken();
  }

  /// 토큰 발급 및 서버 전송
  Future<void> _syncToken() async {
    try {
      String? token = await _messaging.getToken();
      debugPrint('[FCM] Token: $token');

      if (token != null) {
        await _sendTokenToServer(token);
      }

      // 토큰 갱신 감지
      _messaging.onTokenRefresh.listen(_sendTokenToServer);
    } catch (e) {
      debugPrint('[FCM] 토큰 가져오기 실패: $e');
    }
  }

  /// [API 연동] 서버에 토큰 저장
  Future<void> _sendTokenToServer(String fcmToken) async {
    try {
      final jwt = await _storage.read(key: 'jwt_token');
      if (jwt == null) return; // 비로그인 상태면 패스

      final uri = Uri.parse('${ApiConstants.baseUrl}/api/push/tokens');
      
      // 플랫폼 정보 (Android/iOS)
      String platform = Platform.isAndroid ? 'ANDROID' : 'IOS';

      // 디바이스 ID (간단히 토큰 일부나 OS 정보 활용)
      String deviceId = 'device_${Platform.operatingSystem}'; 

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
        debugPrint('[FCM] 토큰 저장 실패: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('[FCM] 토큰 전송 에러: $e');
    }
  }

  /// [Foreground] 앱이 켜져있을 때 메시지 수신
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] 포그라운드 수신: ${message.notification?.title}');

    final data = message.data;
    // 서버에서 보낸 roomId 파싱 (String으로 옴)
    final String? msgRoomIdStr = data['roomId'];
    
    // 현재 보고 있는 방인지 확인
    if (msgRoomIdStr != null) {
      final int msgRoomId = int.tryParse(msgRoomIdStr) ?? -1;
      final int? currentRoomId = CurrentChatTracker.instance.roomId;

      if (currentRoomId == msgRoomId) {
        debugPrint('[FCM] 현재 보고 있는 방 메시지라 알림 생략');
        return;
      }
    }

    // 알림 표시 (Heads-up Notification)
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
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
        payload: jsonEncode(data), // 클릭 시 data 전달
      );
    }
  }

  /// [Background -> Foreground] 알림 클릭 시 (앱이 켜져있었으나 백그라운드)
  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('[FCM] 알림 탭 (Background)');
    _navigateToRoom(message.data);
  }

  /// [Local Notification] 포그라운드 알림 클릭 시
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

  /// 채팅방으로 이동 로직
  void _navigateToRoom(Map<String, dynamic> data) {
    final String? roomIdStr = data['roomId'];
    if (roomIdStr == null) return;

    final int roomId = int.parse(roomIdStr);
    final String senderName = data['senderName'] ?? '채팅방';

    // main.dart에 정의할 global navigatorKey 사용
    navigatorKey.currentState?.pushNamed(
      '/chat/room',
      arguments: {
        'roomId': roomId,
        'title': senderName, // 혹은 적절한 방 이름
        'roomType': 'DIRECT', // 기본값, 필요 시 data에 포함해서 받아야 함
      },
    );
  }
}