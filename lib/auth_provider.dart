// في ملف auth_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_auth.dart';

enum AuthStatus { Checking, Authenticated, Unauthenticated }

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.Checking;
  Map<String, dynamic>? _userData;
  String? _token;

  AuthStatus get status => _status;
  Map<String, dynamic>? get userData => _userData;
  String? get token => _token;

  AuthProvider() {
    _checkAuth();
  }

  // ✅ دالة التحقق من المصادقة عند بدء التطبيق
  Future<void> _checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        // لا يوجد توكن محفوظ
        _status = AuthStatus.Unauthenticated;
        notifyListeners();
        return;
      }

      // ✅ التحقق من صلاحية التوكن مع API
      final isValid = await _verifyTokenWithAPI(token);

      if (isValid) {
        // التوكن صالح، استرجع بيانات المستخدم
        final userDataString = prefs.getString('userData');
        if (userDataString != null) {
          _token = token;
          _userData = json.decode(userDataString);
          _status = AuthStatus.Authenticated;
        } else {
          // بيانات غير مكتملة، امسح كل شيء
          await _clearStoredData();
          _status = AuthStatus.Unauthenticated;
        }
      } else {
        // التوكن غير صالح أو المستخدم محذوف، امسح البيانات
        await _clearStoredData();
        _status = AuthStatus.Unauthenticated;
      }
    } catch (e) {
      print('Error checking auth: $e');
      // في حالة خطأ، امسح البيانات للأمان
      await _clearStoredData();
      _status = AuthStatus.Unauthenticated;
    }

    notifyListeners();
  }

  // ✅ دالة التحقق من صلاحية التوكن مع API
  Future<bool> _verifyTokenWithAPI(String token) async {
    try {
      // استدعاء endpoint للتحقق من المستخدم (مثل /api/Auth/me أو /api/user/profile)
      final response = await ApiAuth.verifyToken(token);

      if (response['statusCode'] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Token verification failed: $e');
      return false;
    }
  }

  // ✅ مسح البيانات المخزنة
  Future<void> _clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userData');
    _token = null;
    _userData = null;
  }

  // دالة تسجيل الدخول
  Future<void> login(String email, String password) async {
    try {
      final response = await ApiAuth.login(email, password);

      if (response['statusCode'] == 200) {
        _token = response['token'];
        _userData = response['user'];

        // حفظ البيانات
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userData', json.encode(_userData));

        _status = AuthStatus.Authenticated;
        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'فشل تسجيل الدخول');
      }
    } catch (e) {
      throw Exception('خطأ: ${e.toString()}');
    }
  }

  // دالة تسجيل الخروج
  Future<void> logout() async {
    await _clearStoredData();
    _status = AuthStatus.Unauthenticated;
    notifyListeners();
  }

  // ✅ دالة إعادة التحقق يدويًا (اختياري)
  Future<void> revalidate() async {
    _status = AuthStatus.Checking;
    notifyListeners();
    await _checkAuth();
  }
}