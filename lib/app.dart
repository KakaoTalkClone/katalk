// lib/app.dart
import 'package:flutter/material.dart';
import 'core/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,                         // ← 텍스트/아이콘 자동 밝게
        scaffoldBackgroundColor: const Color(0xFF080808),   // ← 전체 기본 배경
        canvasColor: const Color(0xFF080808),               // ← 리스트 등 배경
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF080808),
          surfaceTintColor: Color(0xFF080808),              // M3 틴트 제거
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600,
          ),
        ),
        dividerColor: Colors.white10,
      ),
      initialRoute: AppRouter.initialRoute,
      routes: AppRouter.routes,
    );
  }
}
