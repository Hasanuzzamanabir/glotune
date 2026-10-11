import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/core/values/app_colors.dart';
import 'app/routes/app_pages.dart';
import 'app/core/services/auth_service.dart';
import 'app/core/services/interaction_service.dart';
import 'app/core/services/pip_service.dart';
import 'app/core/services/notification_websocket_service.dart';
import 'app/core/services/live_game_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Filter out image resource service noise (404/502 broken media links) from console
  FlutterError.onError = (FlutterErrorDetails details) {
    final exceptionStr = details.exception.toString();
    if (details.library == 'image resource service' ||
        exceptionStr.contains('HttpException: Invalid statusCode') ||
        exceptionStr.contains('NetworkImageLoadException')) {
      return;
    }
    FlutterError.presentError(details);
  };

  await Get.putAsync(() => AuthService().init());
  Get.put(InteractionService());
  Get.put(PipService());
  Get.put(NotificationWebSocketService());
  Get.put(LiveGameService());

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
