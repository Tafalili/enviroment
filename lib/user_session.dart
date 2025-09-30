// lib/user_session.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// هذا الكلاس يتعامل مع حفظ وحذف بيانات جلسة المستخدم بشكل آمن
class UserSession {
  static const _storage = FlutterSecureStorage();
  static const String _userSessionKey = 'user_session_data';

  /// حفظ بيانات المستخدم بشكل آمن بعد تسجيل الدخول
  static Future<void> saveUserSession(Map<String, dynamic> userData) async {
    final userSessionJson = jsonEncode(userData);
    await _storage.write(key: _userSessionKey, value: userSessionJson);
  }

  /// جلب بيانات جلسة المستخدم
  /// سيعود بـ null إذا لم يكن المستخدم مسجل دخوله
  static Future<Map<String, dynamic>?> getUserSession() async {
    final sessionData = await _storage.read(key: _userSessionKey);
    if (sessionData == null) {
      return null;
    }
    return jsonDecode(sessionData);
  }

  /// حذف بيانات الجلسة عند تسجيل الخروج
  static Future<void> deleteUserSession() async {
    await _storage.delete(key: _userSessionKey);
  }
}