import 'dart:ui';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'full_screen.dart';

// Model for City data
class City {
  final int id;
  final String cityName;

  City({required this.id, required this.cityName});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? 0,
      cityName: json['cityName'] ?? '',
    );
  }
}

// Model for Gas Station data
class GasStation {
  final int id;
  final String gasStationName;

  GasStation({required this.id, required this.gasStationName});

  factory GasStation.fromJson(Map<String, dynamic> json) {
    return GasStation(
      id: json['id'] ?? 0,
      gasStationName: json['gasStationName'] ?? '',
    );
  }
}

class IronForm extends StatefulWidget {
  const IronForm({super.key});

  @override
  State<IronForm> createState() => _IronFormState();
}

class _IronFormState extends State<IronForm> {
  // Form controllers and variables
  String? selectedMohafaza;
  int? selectedMohafazaId; // إضافة ID المحافظة المحددة
  DateTime? selectedDate;
  File? selectedImage;
  bool _isLoading = false;
  bool _isLoadingCities = true;
  bool _isLoadingStations = false;

  final ImagePicker _picker = ImagePicker();

  // Dynamic data from API
  List<City> cities = [];
  List<String> mohafazat = [];
  Map<String, int> citiesMap = {}; // Map لتخزين اسم المدينة و ID

  List<GasStation> gasStations = [];
  List<String> stations = [];
  Map<String, int> stationsMap = {}; // Map لتخزين اسم المحطة و ID

  // Static data for other dropdowns

  @override
  void initState() {
    super.initState();
    _fetchCitiesFromServer();
  }

  // Function to fetch gas stations from server

  // Function to fetch cities from server
  Future<void> _fetchCitiesFromServer() async {
    try {
      print('Starting to fetch cities from server...');

      setState(() {
        _isLoadingCities = true;
      });

      print('Making POST request to: https://enviroment.technounityopdc.com/api/DetectionAPI/GetCities');

      final response = await http.post(
        Uri.parse('https://enviroment.technounityopdc.com/api/DetectionAPI/GetCities'),
        headers: {
          "Hdr-GetCities": 'Cities-2025-OK',
        },
        body: json.encode({}),
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Parsed response data: $responseData');
        print('Response data type: ${responseData.runtimeType}');

        // Parse the response as direct list
        List<dynamic> citiesJson = responseData as List;
        print('Cities JSON list length: ${citiesJson.length}');

        if (citiesJson.isNotEmpty) {
          print('First city example: ${citiesJson[0]}');
        }

        setState(() {
          cities = citiesJson.map((cityJson) {
            print('Processing city: $cityJson');
            return City.fromJson(cityJson);
          }).toList();

          mohafazat = cities.map((city) {
            print('City name: ${city.cityName}, ID: ${city.id}');
            return city.cityName;
          }).toList();

          // إنشاء Map للمدن (اسم المدينة -> ID)
          citiesMap = {};
          for (var city in cities) {
            citiesMap[city.cityName] = city.id;
            print('Added to map: ${city.cityName} -> ${city.id}');
          }

          _isLoadingCities = false;
        });

        print('Cities loaded successfully: ${cities.length} cities');
        print('Final mohafazat list: $mohafazat');
        print('Final cities map: $citiesMap');
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Error response body: ${response.body}');
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught in _fetchCitiesFromServer: $e');
      print('Exception type: ${e.runtimeType}');
      print('Stack trace: ${StackTrace.current}');

      setState(() {
        _isLoadingCities = false;
        print('Using fallback static data...');
      });

      print('Error fetching cities: $e');

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ في تحميل المدن. سيتم استخدام البيانات الافتراضية.',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Function to pick date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: const Color(0xFF53A13D),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF53A13D),
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
// Function to submit form with all data including the image
  Future<void> _submitForm() async {
    // التحقق من أن جميع الحقول المطلوبة ممتلئة
    if (selectedMohafazaId == null ||
        selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء ملء جميع الحقول وإرفاق الصورة', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // تفعيل مؤشر التحميل
    });

    try {
      // ================== التعديلات بناءً على صور Postman ==================

      // 1. تحديث الرابط الصحيح
      var uri = Uri.parse('https://enviroment.technounityopdc.com/api/IronAPI/Create');
      var request = http.MultipartRequest('POST', uri);

      // 2. إضافة الهيدر المطلوب
      request.headers['Hdr-Create-Iron'] = 'Iron-2025-OK';

      // 3. تحديث أسماء الحقول لتطابق Postman
      request.fields['CityId'] = selectedMohafazaId.toString();
      request.fields['IronDate'] = selectedDate!.toIso8601String();

      // 4. تحديث اسم حقل الصورة
      request.files.add(
        await http.MultipartFile.fromPath(
          'PhotoFile', // تم التعديل
          selectedImage!.path,
        ),
      );

      // ====================================================================

      // إرسال الطلب وانتظار الرد
      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // نجح الإرسال
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء الكشف الرقابي بنجاح', style: GoogleFonts.cairo()),
            backgroundColor: Colors.green,
          ),
        );
        if (mounted) Navigator.pop(context); // العودة للشاشة السابقة بعد النجاح
      } else {
        print('فشل في إرسال البيانات: ${response.body}');
        // فشل الإرسال
        throw Exception('فشل في إرسال البيانات: ${response.body}');
      }
    } catch (e) {
      // معالجة أي أخطاء تحدث أثناء العملية
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // إيقاف مؤشر التحميل في كل الحالات (نجاح أو فشل)
      setState(() {
        _isLoading = false;
      });
    }
  }
  // Function to show image picker dialog
  Future<void> _showImagePickerDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              'اختر صورة',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Color(0xFF53A13D), size: 24.r),
                  title: Text(
                    'التقط صورة',
                    style: GoogleFonts.cairo(),
                  ),
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: Color(0xFF53A13D), size: 24.r),
                  title: Text(
                    'اختر من المعرض',
                    style: GoogleFonts.cairo(),
                  ),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.cairo(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Future<File?> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.absolute.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");

    // تقوم الدالة بإرجاع متغير من نوع XFile
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
      minWidth: 1024,
      minHeight: 1024,
    );

    if (result != null) {
      // ✅ نقوم بتحويل XFile إلى File هنا
      final compressedFile = File(result.path);

      print('Original image size: ${file.lengthSync()} bytes');
      // ✅ نستخدم المتغير الجديد للحصول على الحجم والعودة به
      print('Compressed image size: ${compressedFile.lengthSync()} bytes');
      return compressedFile;
    }
    return null;
  }
  // Function to pick image
// Function to pick image
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );

      if (pickedFile != null) {
        // بعد اختيار الصورة، قم بضغطها
        final compressedImage = await _compressImage(File(pickedFile.path));
        setState(() {
          selectedImage = compressedImage; // حفظ الصورة المضغوطة
        });
      }
    } catch (e) {
      // ... (error handling)
    }
  }

  // Helper function to build glassy containers
  Widget _buildGlassyContainer({required Widget child, double? height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: double.infinity,
          height: height,
          padding: EdgeInsets.all(16.0.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15.0.r),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.15),
                offset: Offset(-3.w, -3.h),
                blurRadius: 6.r,
                spreadRadius: 1.r,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(3.w, 3.h),
                blurRadius: 6.r,
                spreadRadius: 1.r,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // Build dropdown field with loading state
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.0.h, right: 4.0.w),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFFFFF),
            ),
            textAlign: TextAlign.right,
          ),
        ),
        _buildGlassyContainer(
          child: isLoading
              ? Center(
            child: SizedBox(
              height: 20.h,
              width: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
              : DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: '-- اختر $label --',
              hintStyle: const TextStyle(color: Colors.white),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 14.sp),
            dropdownColor: const Color(0xFF53A13D).withOpacity(0.9),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                alignment: Alignment.centerRight,
                child: Text(
                  item,
                  style: GoogleFonts.cairo(color: Colors.white),
                  textAlign: TextAlign.right,
                ),
              );
            }).toList(),
            onChanged: isLoading ? null : onChanged,
          ),
        ),
      ],
    );
  }

  // Build date field
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.0.h, right: 4.0.w),
          child: Text(
            'تاريخ الكشف',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFFFFF),
            ),
            textAlign: TextAlign.right,
          ),
        ),
        _buildGlassyContainer(
          child: InkWell(
            onTap: _selectDate,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.0.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white70),
                  Text(
                    selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : 'mm/dd/yyyy',
                    style: GoogleFonts.cairo(
                      color: selectedDate != null ? Colors.white : Colors.white70,
                      fontSize: 14.sp,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build image picker field
  Widget _buildImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.0.h, right: 4.0.w),
          child: Text(
            'صورة سجل الاشتغال',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFFFFF),
            ),
            textAlign: TextAlign.right,
          ),
        ),
        _buildGlassyContainer(
          child: InkWell(
            onTap: _showImagePickerDialog,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.0.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF53A13D).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Choose File',
                      style: GoogleFonts.cairo(color: Colors.white, fontSize: 12.sp),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      selectedImage != null
                          ? selectedImage!.path.split('/').last
                          : 'No file chosen',
                      style: GoogleFonts.cairo(
                        color: selectedImage != null ? Colors.white : Colors.white70,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (selectedImage != null)
          Padding(
            padding: EdgeInsets.only(top: 10.0.h),
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                // حاوية الصورة
                _buildGlassyContainer(
                  height: 200.h,
                  child: InkWell(
                    onTap: () {
                      // فتح الصورة بملء الشاشة عند الضغط
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(imageFile: selectedImage!),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                // زر الحذف
                Positioned(
                  top: 8.h,
                  left: 8.w, // تعديل ليتناسب مع RTL
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 20.r),
                      onPressed: () {
                        // حذف الصورة عند الضغط
                        setState(() {
                          selectedImage = null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
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

            // Semi-transparent overlay
            Container(
              color: Colors.black.withOpacity(0.3),
            ),

            // Main content
            Column(
              children: [
                // Custom App Bar
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16.0.w),
                    child: Row(
                      children: [
                        Text(
                          'إضافة كشف رقابي',
                          style: GoogleFonts.cairo(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Scrollable Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.0.w),
                    child: Column(
                      children: [
                        // Mohafaza Dropdown
                        _buildDropdownField(
                          label: 'اسم المحافظة',
                          value: selectedMohafaza,
                          items: mohafazat,
                          isLoading: _isLoadingCities,
                          onChanged: (value) {
                            setState(() {
                              // امسح اختيار المحطة السابق عند تغيير المحافظة
                              selectedMohafaza = value;
                              selectedMohafazaId = value != null ? citiesMap[value] : null;
                            });

                            if (value != null) {
                              print('Selected City: $value, ID: ${citiesMap[value]}');
                            }
                          },
                        ),
                        // Date Field
                        _buildDateField(),
                        SizedBox(height: 16.h),

                        // Image Field
                        _buildImageField(),
                        SizedBox(height: 32.h),

                        // Submit Button
                        _buildGlassyContainer(
                          child: Container(
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
                              onPressed: _isLoading ? null : _submitForm,
                              // ✅ FIX APPLIED HERE
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
                                'إنشاء',
                                style: GoogleFonts.cairo(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}