import "dart:developer";
import "dart:io";
import "dart:typed_data";

import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:get/get.dart";
import "package:overlay_support/overlay_support.dart";
import "package:push_notifications_demo/screens/screen1.dart";
import "package:push_notifications_demo/screens/screen2.dart";
import "package:push_notifications_demo/screens/screen3.dart";
import "package:push_notifications_demo/services/network_service.dart";
import "package:push_notifications_demo/utils/firebase_options.dart";
import "package:timezone/timezone.dart" as timezone;

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("_firebaseMessagingBackgroundHandler() called");
  await NotificationService().initializeApp();
  await NotificationService().registerNotification(
    (RemoteMessage m, String s) {},
  );
  log("_firebaseMessagingBackgroundHandler() completed");
  return Future<void>.value();
}

class NotificationService {
  factory NotificationService() {
    return _singleton;
  }

  NotificationService._internal();

  static final NotificationService _singleton = NotificationService._internal();

  String overlayNotification = "overlay_notification";
  String instantNotification = "instant_notification";
  String notificationWithCustomSound = "custom_sound_notification";
  String scheduledNotification = "scheduled_notification";
  String miscellaneousNotification = "fcm_fallback_notification";
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /* Firebase Functions Start */
  Future<void> initializeApp() async {
    log("Firebase.initializeApp() called");
    final FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log("initializeApp() - app.name: ${app.name}");
    log("Firebase.initializeApp() completed");
    return Future<void>.value();
  }

  void onBackgroundMessage() {
    log("Firebase.onBackgroundMessage() called");
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    log("Firebase.onBackgroundMessage() completed");
    return;
  }

  Future<String> initToken() async {
    log("initToken() called");
    final String fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
    log("fcmToken: $fcmToken");
    log("initToken() completed");
    return Future<String>.value(fcmToken);
  }

  /* Firebase Functions End */

  /* Local Notification Plugin Functions Start */
  Future<void> initFlutterLocalNotificationsPlugin() async {
    log("initFlutterLocalNotificationsPlugin() called");
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("ic_launcher");
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: didReceiveLocalNotification,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onSelectNotification: selectNotification,
      onDidReceiveNotificationResponse: (
        NotificationResponse details,
      ) {
        selectNotification(details.payload);
      },
    );
    log("initFlutterLocalNotificationsPlugin() completed");
    return Future<void>.value();
  }

  Future<void> selectNotification(String? payload) async {
    log("selectNotification() called");
    if (payload != null) {
      final Map<String, dynamic> data = <String, dynamic>{};
      List<String> str = <String>[];
      str = payload.replaceAll("{", "").replaceAll("}", "").split(",");
      for (int i = 0; i < str.length; i++) {
        final List<String> s = str[i].split(":");
        data.putIfAbsent(s[0].trim(), () => s[1].trim());
      }
      final RemoteMessage event = RemoteMessage(data: data);
      await navigate(event, "selectNotification");
    } else {
      log("selectNotification() - payload != null: ${payload != null}");
    }
    log("selectNotification() completed");
    return Future<void>.value();
  }

  Future<void> didReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    log("didReceiveLocalNotification() called");
    log("didReceiveLocalNotification() completed");
    return Future<void>.value();
  }

  Future<bool> checkPermission() async {
    log("checkPermission() called");
    bool permissionStatus = false;
    log("Prompting Notification permission for ${Platform.operatingSystem}");
    if (Platform.isIOS) {
      permissionStatus = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
      log("${Platform.operatingSystem} requestPermissions: $permissionStatus");
    } else if (Platform.isAndroid) {
      permissionStatus = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      if (permissionStatus == false) {
        permissionStatus = await flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.requestPermission() ??
            false;
      }
      log("${Platform.operatingSystem} requestPermission: $permissionStatus");
    } else {
      log("${Platform.operatingSystem} is Unsupported");
    }
    log("checkPermission() completed");
    return Future<bool>.value(permissionStatus);
  }

  Future<void> setForegroundNotificationPresentationOptions() async {
    log("setForegroundNotificationPresentationOptions() called");
    // For iOS request permission first.
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    final NotificationSettings settings = await messaging.requestPermission();
    log("iOS authorizationStatus name: ${settings.authorizationStatus.name}");
    // Update the iOS foreground notification presentation options to allow
    // heads up notifications.
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    log("setForegroundNotificationPresentationOptions() completed");
    return Future<void>.value();
  }

  Future<void> createNotificationChannel() async {
    log("createNotificationChannel() called");
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(overlayNotificationChannel());
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(instantNotificationChannel());
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(notificationWithCustomSoundChannel());
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(scheduledNotificationChannel());
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(miscellaneousNotificationChannel());
    log("createNotificationChannel() completed");
    return Future<void>.value();
  }

  Future<void> registerNotification(
    Function(RemoteMessage m, String s) modelBinding,
  ) async {
    log("registerNotification() called");
    final bool permissionStatus = await checkPermission();
    log("permissionStatus: $permissionStatus");
    if (Platform.isIOS) {
      await setForegroundNotificationPresentationOptions();
    } else if (Platform.isAndroid) {
      await createNotificationChannel();
    } else {
      log("${Platform.operatingSystem} Unsupported for registerNotification");
    }
    foregroundNotification(modelBinding);
    log("registerNotification() completed");
    return Future<void>.value();
  }

  /* Local Notification Plugin Functions End */

  /* State-wise Notification Management Start */
  // This method will call when the app is in foreground state
  void foregroundNotification(
    Function(RemoteMessage m, String s) modelBinding,
  ) {
    log("foregroundNotification() called");
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage event) async {
        log("FirebaseMessaging.onMessage.listen() called");
        modelBinding(event, "onMessage");
        await showNotification(event);
        log("FirebaseMessaging.onMessage.listen() completed");
      },
    );
    log("foregroundNotification() completed");
  }

  // This method will call when the app is in background state
  void backgroundNotification(
    Function(RemoteMessage m, String s) modelBinding,
  ) {
    log("backgroundNotification() called");
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage event) {
        log("FirebaseMessaging.onMessageOpenedApp.listen() called");
        modelBinding(event, "onMessageOpenedApp");
        log("FirebaseMessaging.onMessageOpenedApp.listen() completed");
      },
    );
    log("backgroundNotification() completed");
  }

  // This method will call when the app is in kill state
  Future<void> checkForInitialMsg(
    Function(RemoteMessage m, String s) modelBinding,
  ) async {
    log("checkForInitialMsg() called");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final RemoteMessage? event =
        await FirebaseMessaging.instance.getInitialMessage();
    if (event != null) {
      modelBinding(event, "getInitialMessage");
    }
    log("checkForInitialMsg() completed");
    return Future<void>.value();
  }

  /* State-wise Notification Management End */

  /* Show Notification Start */
  Future<dynamic> showNotification(RemoteMessage event) async {
    log("showNotification() called");
    final RemoteNotification? notification = event.notification;
    final AndroidNotification? android = event.notification?.android;
    final AppleNotification? ios = event.notification?.apple;
    if (notification != null && (android != null || ios != null)) {
      if (Platform.isAndroid) {
        if (notification.android?.channelId == overlayNotification) {
          customShowOverlayNotification(notification, event);
        } else if (notification.android?.channelId == instantNotification) {
          await commonNotificationView(
            channel: instantNotificationChannel(),
            notification: notification,
            event: event,
            isCustomSoundRequired: false,
          );
        } else if (notification.android?.channelId ==
            notificationWithCustomSound) {
          await commonNotificationView(
            channel: notificationWithCustomSoundChannel(),
            notification: notification,
            event: event,
            isCustomSoundRequired: true,
          );
        } else if (notification.android?.channelId == scheduledNotification) {
          await zonedScheduleNotificationView(
            channel: scheduledNotificationChannel(),
            notification: notification,
            event: event,
            isCustomSoundRequired: false,
          );
        } else if (notification.android?.channelId ==
            miscellaneousNotification) {
          await commonNotificationView(
            channel: miscellaneousNotificationChannel(),
            notification: notification,
            event: event,
            isCustomSoundRequired: false,
          );
        } else {
          await commonNotificationView(
            channel: miscellaneousNotificationChannel(),
            notification: notification,
            event: event,
            isCustomSoundRequired: false,
          );
        }
      } else if (Platform.isIOS) {
        await commonNotificationView(
          channel: miscellaneousNotificationChannel(),
          notification: notification,
          event: event,
          isCustomSoundRequired: false,
        );
      } else {
        log("Unsupported Platform.");
      }
    }
    log("showNotification() completed");
  }

  /* Show Notification End */

  /* Notification Resource Download From URL Start */
  Future<Uint8List> downloadNotificationResourceFromURL(String url) async {
    final Uint8List int8list = await NetworkService().getByteArrayFromUrl(
      url: url,
      callbackHandle: (String message) {
        log("Error on - downloadNotificationResourceFromURL(): $message");
      },
    );
    return Future<Uint8List>.value(int8list);
  }
  /* Notification Resource Download From URL End */

  /* Notification Style Information Start */
  Future<StyleInformation?> styleInformation(
    RemoteNotification notification,
    RemoteMessage event,
  ) async {
    log("styleInformation() called");
    final StyleInformation? style = notification.android?.imageUrl != null
        ? BigPictureStyleInformation(
            ByteArrayAndroidBitmap(
              await downloadNotificationResourceFromURL(
                notification.android?.imageUrl ?? "",
              ),
            ),
            largeIcon: notification.android?.smallIcon != null
                ? ByteArrayAndroidBitmap(
                    await downloadNotificationResourceFromURL(
                      notification.android?.smallIcon ?? "",
                    ),
                  )
                : null,
          )
        : null;
    log("styleInformation() completed");
    return Future<StyleInformation?>.value(style);
  }

  Future<AndroidBitmap<Object>?> largeIcon(
    RemoteNotification notification,
    RemoteMessage event,
  ) async {
    log("largeIcon() called");
    final AndroidBitmap<Object>? icon = notification.android?.smallIcon != null
        ? ByteArrayAndroidBitmap(
            await downloadNotificationResourceFromURL(
              notification.android?.smallIcon ?? "",
            ),
          )
        : null;
    log("largeIcon() completed");
    return Future<AndroidBitmap<Object>?>.value(icon);
  }

  Color? color(
    RemoteNotification notification,
    RemoteMessage event,
  ) {
    log("color() called");
    final Color? color = notification.android?.color != null
        ? HexColor.fromHex(
            notification.android?.color.toString() ?? "#1A6D47",
          )
        : null;
    log("color() completed");
    return color;
  }

  /* Notification Style Information End */

  /* Notification Details Start */
  Future<AndroidNotificationDetails> commonAndroidNotificationDetails({
    required String channelId,
    required String channelName,
    required String channelDescription,
    required bool isCustomSoundRequired,
    required RemoteNotification notification,
    required RemoteMessage event,
  }) async {
    log("commonAndroidNotificationDetails() called");
    final AndroidNotificationDetails details = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      color: color(notification, event),
      icon: "@drawable/ic_launcher",
      sound: isCustomSoundRequired
          ? const RawResourceAndroidNotificationSound("slow_spring_board")
          : null,
      importance: Importance.high,
      priority: Priority.high,
      largeIcon: await largeIcon(notification, event),
      styleInformation: await styleInformation(notification, event),
    );
    log("commonAndroidNotificationDetails() completed");
    return Future<AndroidNotificationDetails>.value(details);
  }

  DarwinNotificationDetails commonIOSNotificationDetails({
    required String threadIdentifier,
    required String subtitle,
    required bool isCustomSoundRequired,
  }) {
    log("commonIOSNotificationDetails() called");
    final DarwinNotificationDetails details = DarwinNotificationDetails(
      threadIdentifier: threadIdentifier,
      subtitle: subtitle,
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
      sound: isCustomSoundRequired ? "slow_spring_board.aiff" : null,
    );
    log("commonIOSNotificationDetails() completed");
    return details;
  }

  /* Notification Details End */

  /* Notification Views Start */
  OverlaySupportEntry customShowOverlayNotification(
    RemoteNotification notification,
    RemoteMessage event,
  ) {
    log("customShowOverlayNotification() called");
    log("customShowOverlayNotification() completed");
    return showOverlayNotification(
      duration: const Duration(seconds: 4),
      (BuildContext context) {
        return SafeArea(
          child: Card(
            color: Platform.isAndroid && notification.android?.color != null
                ? HexColor.fromHex(
                    notification.android?.color.toString() ?? "#1A6D47",
                  )
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            margin: const EdgeInsets.all(14),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              leading:
                  Platform.isAndroid && notification.android?.smallIcon != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            notification.android?.smallIcon ?? "",
                          ),
                        )
                      : null,
              trailing:
                  (Platform.isIOS && notification.apple?.imageUrl != null) ||
                          (Platform.isAndroid &&
                              notification.android?.imageUrl != null)
                      ? Image.network(
                          Platform.isIOS
                              ? notification.apple?.imageUrl ?? ""
                              : Platform.isAndroid
                                  ? notification.android?.imageUrl ?? ""
                                  : "",
                        )
                      : null,
              title: Text(notification.title ?? ""),
              subtitle: Text(notification.body ?? ""),
              onTap: () async {
                OverlaySupportEntry.of(context)?.dismiss();
                await navigate(event, "showOverlayNotification");
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> commonNotificationView({
    required AndroidNotificationChannel channel,
    required RemoteNotification notification,
    required RemoteMessage event,
    required bool isCustomSoundRequired,
  }) async {
    log("commonNotificationView() called");
    log("commonNotificationView() completed");
    return flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: await commonAndroidNotificationDetails(
          channelId: channel.id,
          channelName: channel.name,
          channelDescription: channel.description ?? "",
          isCustomSoundRequired: isCustomSoundRequired,
          notification: notification,
          event: event,
        ),
        iOS: commonIOSNotificationDetails(
          threadIdentifier: channel.id,
          subtitle: channel.description ?? "",
          isCustomSoundRequired: isCustomSoundRequired,
        ),
      ),
      payload: event.data.toString(),
    );
  }

  Future<void> zonedScheduleNotificationView({
    required AndroidNotificationChannel channel,
    required RemoteNotification notification,
    required RemoteMessage event,
    required bool isCustomSoundRequired,
  }) async {
    log("zonedScheduleNotificationView() called");
    log("zonedScheduleNotificationView() completed");
    return flutterLocalNotificationsPlugin.zonedSchedule(
      notification.hashCode,
      notification.title,
      notification.body,
      timezone.TZDateTime.now(timezone.local).add(const Duration(seconds: 10)),
      NotificationDetails(
        android: await commonAndroidNotificationDetails(
          channelId: channel.id,
          channelName: channel.name,
          channelDescription: channel.description ?? "",
          isCustomSoundRequired: isCustomSoundRequired,
          notification: notification,
          event: event,
        ),
        iOS: commonIOSNotificationDetails(
          threadIdentifier: channel.id,
          subtitle: channel.description ?? "",
          isCustomSoundRequired: isCustomSoundRequired,
        ),
      ),
      payload: event.data.toString(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /* Notification Views End */

  /* Notification Channels Start */
  AndroidNotificationChannel overlayNotificationChannel() {
    log("overlayNotificationChannel() called");
    log("overlayNotificationChannel() completed");
    return AndroidNotificationChannel(
      overlayNotification,
      "Overlay Notifications",
      description: "This channel is used for overlay notifications.",
      importance: Importance.high,
    );
  }

  AndroidNotificationChannel instantNotificationChannel() {
    log("instantNotificationChannel() called");
    log("instantNotificationChannel() completed");
    return AndroidNotificationChannel(
      instantNotification,
      "Instant Notifications",
      description: "This channel is used for instant notifications.",
      importance: Importance.high,
    );
  }

  AndroidNotificationChannel notificationWithCustomSoundChannel() {
    log("notificationWithCustomSoundChannel() called");
    log("notificationWithCustomSoundChannel() completed");
    return AndroidNotificationChannel(
      notificationWithCustomSound,
      "Custom Sound Notifications",
      description: "This channel is used for notifications with custom sound.",
      importance: Importance.high,
      sound: const RawResourceAndroidNotificationSound("slow_spring_board"),
    );
  }

  AndroidNotificationChannel scheduledNotificationChannel() {
    log("scheduledNotificationChannel() called");
    log("scheduledNotificationChannel() completed");
    return AndroidNotificationChannel(
      scheduledNotification,
      "Scheduled Notifications",
      description: "This channel is used for schedule notifications.",
      importance: Importance.high,
    );
  }

  AndroidNotificationChannel miscellaneousNotificationChannel() {
    log("miscellaneousNotificationChannel() called");
    log("miscellaneousNotificationChannel() completed");
    return AndroidNotificationChannel(
      miscellaneousNotification,
      "Miscellaneous Notifications",
      description: "This channel is used for miscellaneous notifications.",
      importance: Importance.high,
    );
  }

  /* Notification Channels End */

  /* Notification Navigation Start */
  Future<void> navigate(RemoteMessage event, String source) async {
    log("navigate() called");
    if (source != "onMessage") {
      final Map<String, dynamic> data = event.data;
      if (data.containsKey("screen")) {
        Widget screen = const SizedBox();
        switch (data["screen"]) {
          case "screen1":
            screen = Screen1(id: data["_id"] ?? "N / A");
            break;
          case "screen2":
            screen = Screen2(id: data["_id"] ?? "N / A");
            break;
          case "screen3":
            screen = Screen3(id: data["_id"] ?? "N / A");
            break;
          default:
            log("Unknown screen name.");
            return;
        }
        await Navigator.of(Get.key.currentContext!).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return screen;
            },
          ),
        );
      } else {
        log("Screen param not available.");
      }
    }
    log("navigate() completed");
    return Future<void>.value();
  }
/* Notification Navigation Start */

}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    log("fromHex() called");
    final StringBuffer buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write("ff");
    }
    buffer.write(hexString.replaceFirst("#", ""));
    log("fromHex() completed");
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) {
    log("toHex() called");
    log("toHex() completed");
    return '${leadingHashSign ? '#' : ''}'
        '${alpha.toRadixString(16).padLeft(2, '0')}'
        '${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
  }
}
