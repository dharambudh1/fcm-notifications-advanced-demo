import "dart:async";

import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:keyboard_dismisser/keyboard_dismisser.dart";
import "package:overlay_support/overlay_support.dart";
import "package:push_notifications_demo/screens/home_screen.dart";
import "package:push_notifications_demo/services/notification_service.dart";
import "package:push_notifications_demo/services/timezone_service.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TimeZoneService().getLocalTimezoneAndInitialize();
  await NotificationService().initializeApp();
  NotificationService().onBackgroundMessage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: OverlaySupport(
        child: GetMaterialApp(
          navigatorKey: Get.key,
          navigatorObservers: <NavigatorObserver>[GetObserver()],
          title: "Push Notification Demo",
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: Colors.blue,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blue,
          ),
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
