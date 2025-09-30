// lib/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'home.dart';
import 'login.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authStatus = Provider.of<AuthProvider>(context).status;

    if (authStatus == AuthStatus.Authenticated) {
      return const HomeScreen();
    } else if (authStatus == AuthStatus.Unauthenticated) {
      return const LoginPage();
    } else {
      // ✅ Splash screen with custom styling
      return const SplashScreen();
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF53A13D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Image.asset(
              'images/icon.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            // App Name in Arabic (Cairo font, white color)
            const Text(
              'الرقابة البيئية',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            // White Progress Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}