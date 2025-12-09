import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // kIsWeb 사용을 위해 필요
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/fcm/fcm_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kIsWeb) {
      // ★★★ [웹 전용] Firebase 콘솔의 설정값을 여기에 넣으세요 ★★★
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCydG1oH2gWlC7zp1RgLjZUgiDaPC0uXME",
          authDomain: "piuda-bfb0f.firebaseapp.com",
          projectId: "piuda-bfb0f",
          storageBucket: "piuda-bfb0f.appspot.com",
          messagingSenderId: "137988483909",
          appId: "1:137988483909:web:34203cf1e3109d4188ec2c",
        ),
      );
    } else {
      // [모바일] google-services.json 파일을 자동으로 읽음
      await Firebase.initializeApp();
    }
    
    // FCM 서비스 초기화
    await FcmService.instance.initialize();
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }

  runApp(const App());
}