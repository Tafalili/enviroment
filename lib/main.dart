// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // استيراد Provider
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'api_auth.dart';
import 'auth_provider.dart'; // استيراد AuthProvider
import 'splash_screen.dart'; // هذا الملف يجب أن يحتوي على AuthWrapper

void main() {
  runApp(
    // لف التطبيق بـ ChangeNotifierProvider لجعله متاحًا في كل مكان
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'Your App Name',
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          debugShowCheckedModeBanner: false,
          home: const AuthWrapper(),
        );
      },
    );
  }
}