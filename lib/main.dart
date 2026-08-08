import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/services/api_service.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';
import 'routes/app_routes.dart';
import 'viewmodel/product_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inject global services and viewmodels
  final apiService = ApiService();
  Get.put<ApiService>(apiService);
  Get.put<ProductViewModel>(ProductViewModel(apiService: apiService));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Catalogify',
          debugShowCheckedModeBanner: false,
          
          // Theme settings
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system, // Automatically use dark/light depending on OS setting

          // Routes settings
          initialRoute: AppRoutes.home,
          getPages: AppRoutes.pages,
        );
      },
    );
  }
}
