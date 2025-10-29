import 'package:flutter/material.dart';
import '../screens/main_screen.dart';

class AppRouter {
  static const initialRoute = '/';

  static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    '/': (_) => MainScreen(), 
  };
}
