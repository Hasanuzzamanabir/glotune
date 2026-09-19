import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/core/values/app_colors.dart';
import 'app/routes/app_pages.dart';
import 'app/core/services/auth_service.dart';
import 'app/core/services/interaction_service.dart';
import 'app/core/services/pip_service.dart';
import 'app/core/services/notification_websocket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => AuthService().init());
  Get.put(InteractionService());
  Get.put(PipService());
  Get.put(NotificationWebSocketService());

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return 
        
        
        
        GetMaterialApp(
          title: "Application",
          initialRoute: Routes.SPLASH,
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.background,
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            useMaterial3: true,
          ),
        );
      },
    ),
  );
}
