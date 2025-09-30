// lib/home.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'api_auth.dart';
import 'auth_provider.dart'; // ✅ استيراد AuthProvider
// ... استيراد باقي الصفحات (air.dart, iron.dart, etc.)
import 'air.dart';
import 'create_detection.dart';
import 'iron.dart';
import 'lpg.dart';


// ‼️ تأكد من حذف كلاس UserSession المؤقت الذي كان موجودًا هنا.

class HomeScreen extends StatelessWidget { // ✅ تم تحويلها إلى StatelessWidget
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- جلب البيانات من الـ Provider ---
    // AuthProvider هو الآن المصدر الوحيد للحقيقة
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;

    // --- عرض شاشة تحميل إذا كانت البيانات غير جاهزة ---
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Widget buildGlassyCard({
      required IconData icon,
      required String text,
      required VoidCallback onTap,
    }) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25.0.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0.w, sigmaY: 10.0.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25.0.r),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 50.r, color: Colors.white),
                      SizedBox(height: 10.h),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // --- الواجهة الرئيسية ---
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // صورة الخلفية
            Image.asset(
              'images/back.jpg',
              fit: BoxFit.cover,
            ),
            // طبقة تعتيم
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
            // المحتوى القابل للتمرير
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 24.h),
                  child: Column(
                    children: [
                      // --- رسالة الترحيب وبيانات المستخدم ---
                      _WelcomeMessageCard(userData: userData),

                      SizedBox(height: 32.h),

                      // --- Carousel Slider ---


                      SizedBox(height: 32.h),

                      // --- قائمة الخدمات ---
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0.w,
                        mainAxisSpacing: 16.0.h,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          buildGlassyCard(
                            icon: Icons.assignment,
                            text: 'إضافة كشف رقابي',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const KashfRaqabiScreen()));
                            },
                          ),
                          buildGlassyCard(
                            icon: Icons.agriculture,
                            text: 'إضافة كميات حديد سكراب',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const IronForm()));
                            },
                          ),
                          buildGlassyCard(
                            icon: Icons.propane_tank,
                            text: 'إضافة كشف lpg',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LpgForm()));
                            },
                          ),
                          buildGlassyCard(
                            icon: Icons.cloud_outlined,
                            text: 'إضافة قياس ملوثات الهواء',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AirForm()));
                            },
                          ),
                        ],
                      ),
                    ],
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


/// ويدجت منفصل لرسالة الترحيب لجعل الكود أكثر تنظيمًا
class _WelcomeMessageCard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const _WelcomeMessageCard({required this.userData});

  @override
  Widget build(BuildContext context) {
    // جلب AuthProvider لتنفيذ تسجيل الخروج
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0.w, sigmaY: 10.0.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.0.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20.0.r),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'أهلاً وسهلاً',
                    style: GoogleFonts.cairo(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('تسجيل الخروج', style: GoogleFonts.cairo(), textAlign: TextAlign.right),
                          content: Text('هل تريد تسجيل الخروج؟', style: GoogleFonts.cairo(), textAlign: TextAlign.right),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text('إلغاء', style: GoogleFonts.cairo()),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                authProvider.logout(); // ✅ استدعاء دالة الخروج من Provider
                              },
                              child: Text('تسجيل الخروج', style: GoogleFonts.cairo(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.logout, color: Colors.white, size: 24.r),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  userData['email'] ?? 'No Email',
                  style: GoogleFonts.cairo(fontSize: 16.sp, color: Colors.white70),
                  textAlign: TextAlign.right,
                ),
              ),
              if (userData['roles'] != null && (userData['roles'] as List).isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8.0.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: (userData['roles'] as List).map((role) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF53A13D).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Text(
                          role.toString(),
                          style: GoogleFonts.cairo(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}