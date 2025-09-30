// lib/api_auth.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiAuth {
  static const String baseUrl = 'https://enviroment.technounityopdc.com/api';

  // ✅ تسجيل الدخول
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/LoginUnified'),
        body: ({
          'email': email,
          'password': password,
          'rememberMe': true.toString(),
        }),
      ).timeout(const Duration(seconds: 15));

      print('Login Status: ${response.statusCode}');
      print('Login Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'statusCode': 200,
          'message': data['message'],
          'token': data['token'], // ✅ الآن يرجع token
          'user': {
            'email': data['email'],
            'roles': data['roles'],
            'userId': data['userId'],
          },
        };
      } else {
        final data = json.decode(response.body);
        return {
          'statusCode': response.statusCode,
          'message': data['message'] ?? 'فشل تسجيل الدخول',
        };
      }
    } catch (e) {
      return {
        'statusCode': 500,
        'message': 'خطأ في الاتصال: ${e.toString()}',
      };
    }
  }

  // ✅ التحقق من صلاحية التوكن
  static Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Auth/VerifyUser'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Verify Status: ${response.statusCode}');
      print('Verify Response: ${response.body}');

      if (response.statusCode == 200) {
        return {'statusCode': 200, 'data': json.decode(response.body)};
      } else {
        return {
          'statusCode': response.statusCode,
          'message': 'التوكن غير صالح أو المستخدم محذوف',
        };
      }
    } catch (e) {
      return {'statusCode': 500, 'message': 'خطأ: ${e.toString()}'};
    }
  }
}