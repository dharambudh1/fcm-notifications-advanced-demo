import "dart:developer";
import "dart:io";
import "dart:math" as math;
import "dart:ui";

import "package:firebase_messaging/firebase_messaging.dart";
import "package:get/get.dart";
import "package:permission_handler/permission_handler.dart";
import "package:push_notifications_demo/model/firebase_request_model.dart";
import "package:push_notifications_demo/model/firebase_response_model.dart";
import "package:push_notifications_demo/services/network_service.dart";
import "package:push_notifications_demo/services/notification_service.dart";
import "package:push_notifications_demo/utils/notification_type_list.dart";

class HomeController extends GetxController {
  Rx<FCMRequestModel?> notificationModel = FCMRequestModel().obs;
  Rx<FCMResponseModel?> fcmResponseModel = FCMResponseModel().obs;
  Rx<String> controllerTitle = "".obs;
  Rx<String> controllerBody = "".obs;
  Rx<String> controllerDataTitle = "".obs;
  Rx<String> controllerDataBody = "".obs;
  RxList<NotificationType> typeList = notificationTypeList.obs;
  RxBool randomColor = false.obs;
  RxBool randomAvatar = false.obs;
  RxBool randomImage = false.obs;
  RxBool permStatus = false.obs;

  Future<void> responseModel(RemoteMessage event, String source) async {
    final FCMRequestModel object = FCMRequestModel(
      to: await NotificationService().initToken(),
      notification: Notification(
        channelId: event.notification?.android?.channelId ?? "",
        title: event.notification?.title ?? "",
        body: event.notification?.body ?? "",
        color: event.notification?.android?.color ?? "",
        icon: event.notification?.android?.smallIcon ?? "",
        image: Platform.isIOS
            ? event.notification?.apple?.imageUrl ?? ""
            : Platform.isAndroid
                ? event.notification?.android?.imageUrl ?? ""
                : "",
      ),
      data: Data(
        title: event.data["title"] ?? "",
        body: event.data["body"] ?? "",
        clickAction: event.data["click_action"] ?? "",
        id: event.data["_id"] ?? "",
        screen: event.data["screen"] ?? "",
      ),
    );
    notificationModel(object);
    await NotificationService().navigate(event, source);
    return Future<void>.value();
  }

  Future<FCMRequestModel> requestModel() async {
    final NotificationType channelId = notificationTypeList.firstWhere(
      (NotificationType element) {
        return element.isSelected == true;
      },
    );
    final FCMRequestModel object = FCMRequestModel(
      notification: Notification(
        channelId: channelId.value,
        title: controllerTitle.value,
        body: controllerBody.value,
        color: randomColor.value ? generateRandomColor() : null,
        icon: randomAvatar.value
            ? "https://www.fnordware.com/superpng/pngtest8rgba.png"
            : null,
        image: randomImage.value
            ? "https://www.fnordware.com/superpng/pnggrad16rgb.png"
            : null,
      ),
      data: Data(
        title: controllerDataTitle.value,
        body: controllerDataBody.value,
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      ),
      to: await NotificationService().initToken(),
    );
    return Future<FCMRequestModel>.value(object);
  }

  Future<void> makeAPICall({
    required void Function(String) callbackHandle,
  }) async {
    final FCMResponseModel response = await NetworkService().requestToFirebase(
      model: await requestModel(),
      callbackHandle: callbackHandle,
    );
    fcmResponseModel(response);
    return Future<void>.value();
  }

  void clearNotificationModel() {
    notificationModel(FCMRequestModel());
    return;
  }

  void clearFCMResponseModel() {
    fcmResponseModel(FCMResponseModel());
    return;
  }

  void resetValueToDefault() {
    notificationModel(FCMRequestModel());
    fcmResponseModel(FCMResponseModel());
    controllerTitle("");
    controllerBody("");
    controllerDataTitle("");
    controllerDataBody("");
    List<NotificationType> tempArr = <NotificationType>[];
    tempArr = List<NotificationType>.from(typeList)
      ..forEach(
        (NotificationType notificationType) {
          notificationType.isSelected = false;
        },
      );
    tempArr[0].isSelected = true;
    typeList(List<NotificationType>.from(tempArr));
    randomColor(false);
    randomAvatar(false);
    randomImage(false);
    return;
  }

  void onNotificationTypeChange(int index) {
    List<NotificationType> tempArr = <NotificationType>[];
    tempArr = List<NotificationType>.from(typeList)
      ..forEach(
        (NotificationType notificationType) {
          notificationType.isSelected = false;
        },
      );
    tempArr[index].isSelected = true;
    typeList(List<NotificationType>.from(tempArr));
    return;
  }

  String generateRandomColor() {
    final int intValue = (math.Random().nextDouble() * 0xFFFFFF).toInt();
    final String stringValue = Color(intValue).withOpacity(1.0).toHex();
    return stringValue;
  }

  Future<void> updatePermissionStatus() async {
    log("updatePermissionStatus() called");
    final bool value = await Permission.notification.isGranted;
    permStatus(value);
    log("Updated permissionStatus: ${permStatus.value}");
    log("updatePermissionStatus() completed");
    return Future<void>.value();
  }
}
