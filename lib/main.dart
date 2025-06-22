import 'dart:io';
import 'package:devops/Screens/splash_Screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(
    DevOpsApp(
      isLoggedIn: isLoggedIn,
    ),
  );
}

class DevOpsApp extends StatelessWidget {
  final bool isLoggedIn;
  const DevOpsApp({required this.isLoggedIn, super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevOps',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(isLoggedIn: isLoggedIn), // Start with splash screen//
    );
  }
}
