import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'api_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ✅ تم إزالة Imports القديمة وغير الضرورية مثل http و shared_preferences
import 'auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // ✅ تحديث شامل لمنطق تسجيل الدخول مع معالجة احترافية للأخطاء
  Future<void> _loginUser() async {
    // التحقق من أن الحقول ليست فارغة
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // استدعاء دالة تسجيل الدخول من الـ Provider
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // في حالة النجاح، سيقوم AuthWrapper بنقلك تلقائيًا. لا حاجة لكود هنا.

    } catch (e) {
      // في حالة الفشل، التقط الخطأ الذي تم رميه من AuthProvider
      // واعرض رسالة الخطأ الدقيقة للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()), // عرض الخطأ الفعلي من الـ API
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // تأكد من أن الواجهة ما زالت موجودة قبل تحديث الحالة
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 واجهة المستخدم تبقى كما هي تمامًا بدون أي تغيير
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'images/back.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey,
                  child: const Center(
                    child: Text('Add an image to assets/images/back.jpg'),
                  ),
                );
              },
            ),
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0.w, sigmaY: 10.0.h),
                  child: Container(
                    width: 320.w,
                    padding: EdgeInsets.all(24.0.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25.0.r),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'تسجيل الدخول',
                            style: GoogleFonts.cairo(
                              fontSize: 34.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'اهلا بك في صفحة تسجيل الدخول',
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: 32.h),
                          TextFormField(
                            controller: _emailController,
                            style: GoogleFonts.cairo(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'اسم الدخول',
                              hintStyle: GoogleFonts.cairo(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0.r),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: const Icon(Icons.person_outline, color: Colors.white54),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: GoogleFonts.cairo(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'رمز الدخول',
                              hintStyle: GoogleFonts.cairo(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0.r),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: const Icon(Icons.visibility_off_outlined, color: Colors.white54),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            width: double.infinity,
                            height: 50.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0.r),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF53A13D),
                                  Color(0xFF286438),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _loginUser,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                shadowColor: MaterialStateProperty.all(Colors.transparent),
                                elevation: MaterialStateProperty.all(0),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0.r),
                                  ),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                'تسجيل الدخول',
                                style: GoogleFonts.cairo(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}