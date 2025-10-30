import 'package:flutter/material.dart';
import '../features/home/home_tabs.dart';

class AppRouter {
  static const initialRoute = '/';
  static final routes = <String, WidgetBuilder>{
    '/': (_) => const HomeTabs(), 
  };
}
