import "dart:async";
import "dart:developer";

import "package:after_layout/after_layout.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";
import "package:push_notifications_demo/common_widgets/common_blinking_button.dart";
import "package:push_notifications_demo/common_widgets/common_check_box.dart";
import "package:push_notifications_demo/common_widgets/common_list_tile.dart";
import "package:push_notifications_demo/common_widgets/common_text_form_field.dart";
import "package:push_notifications_demo/common_widgets/custom_radio_button.dart";
import "package:push_notifications_demo/controller/home_controller.dart";
import "package:push_notifications_demo/model/firebase_request_model.dart";
import "package:push_notifications_demo/model/firebase_response_model.dart";
import "package:push_notifications_demo/services/notification_service.dart";
import "package:push_notifications_demo/utils/notification_type_list.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AfterLayoutMixin<HomeScreen>
    implements WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final HomeController _controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    await NotificationService().initFlutterLocalNotificationsPlugin();
    await NotificationService().registerNotification(_controller.responseModel);
    NotificationService().backgroundNotification(_controller.responseModel);
    await NotificationService().checkForInitialMsg(_controller.responseModel);
    await _controller.updatePermissionStatus();
    return Future<void>.value();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Push notification demo"),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    _formKey.currentState?.reset();
                    _controller.resetValueToDefault();
                  },
                  icon: const Icon(Icons.clear_all),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: showModalSheet,
                  icon: const Icon(Icons.info_outline),
                ),
              )
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              _formKey.currentState?.validate() ?? false
                  ? await _controller.makeAPICall(
                      callbackHandle: showSnackBar,
                    )
                  : log("Form is invalid");
            },
            backgroundColor: Theme.of(context).buttonTheme.colorScheme!.primary,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: <Widget>[
                    CommonBlinkingButton(status: _controller.permStatus.value),
                    notificationModelWidget(),
                    form(),
                    notificationResponseWidget(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.token),
                      title: const Text("FCM Token"),
                      subtitle: const Text("Copy FCM Token to Clipboard"),
                      trailing: IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(
                              text: await NotificationService().initToken(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget notificationModelWidget() {
    final FCMRequestModel notificationModel =
        _controller.notificationModel.value ?? FCMRequestModel();
    return notificationModel.to == null
        ? const SizedBox(
            height: 50,
            child: Center(
              child: Text("FCM payload is empty!"),
            ),
          )
        : Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: _controller.clearNotificationModel,
                child: const Text("Clear FCM Payload"),
              ),
              CommonListTile(
                title: "notification.title",
                subtitle: notificationModel.notification?.title ?? "",
              ),
              CommonListTile(
                title: "notification.body",
                subtitle: notificationModel.notification?.body ?? "",
              ),
              CommonListTile(
                title: "notification.android_channel_id",
                subtitle: notificationModel.notification?.channelId ?? "",
              ),
              CommonListTile(
                title: "notification.icon",
                subtitle: notificationModel.notification?.icon ?? "",
              ),
              CommonListTile(
                title: "notification.color",
                subtitle: notificationModel.notification?.color ?? "",
              ),
              CommonListTile(
                title: "notification.image",
                subtitle: notificationModel.notification?.image ?? "",
              ),
              CommonListTile(
                title: "data.title",
                subtitle: notificationModel.data?.title ?? "",
              ),
              CommonListTile(
                title: "data.body",
                subtitle: notificationModel.data?.body ?? "",
              ),
              CommonListTile(
                title: "data.click_action",
                subtitle: notificationModel.data?.clickAction ?? "",
              ),
              CommonListTile(
                title: "data.id",
                subtitle: notificationModel.data?.id ?? "",
              ),
              CommonListTile(
                title: "data.screen",
                subtitle: notificationModel.data?.screen ?? "",
              ),
            ],
          );
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          CommonTextFormField(
            onChanged: _controller.controllerTitle,
            label: "Title",
          ),
          CommonTextFormField(
            onChanged: _controller.controllerBody,
            label: "Body",
          ),
          CommonTextFormField(
            onChanged: _controller.controllerDataTitle,
            label: "Data Title",
          ),
          CommonTextFormField(
            onChanged: _controller.controllerDataBody,
            label: "Data Body",
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: _controller.typeList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _controller.onNotificationTypeChange(index);
                  },
                  child: CommonRadioButton(notificationTypeList[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          CommonCheckBox(
            iconData: Icons.color_lens_outlined,
            value: _controller.randomColor.value,
            title: "Random Color",
            onChanged: _controller.randomColor,
          ),
          CommonCheckBox(
            iconData: Icons.person_outline,
            value: _controller.randomAvatar.value,
            title: "Random Avatar",
            onChanged: _controller.randomAvatar,
          ),
          CommonCheckBox(
            iconData: Icons.image_outlined,
            value: _controller.randomImage.value,
            title: "Random Image",
            onChanged: _controller.randomImage,
          ),
        ],
      ),
    );
  }

  Widget notificationResponseWidget() {
    final FCMResponseModel fcmResponse =
        _controller.fcmResponseModel.value ?? FCMResponseModel();
    return fcmResponse.multicastId == null
        ? const SizedBox(
            height: 50,
            child: Center(
              child: Text("FCM Response model is empty!"),
            ),
          )
        : Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: _controller.clearFCMResponseModel,
                child: const Text("Clear FCM Response"),
              ),
              CommonListTile(
                title: "multicastId",
                subtitle: (fcmResponse.multicastId ?? 0).toString(),
              ),
              CommonListTile(
                title: "success",
                subtitle: (fcmResponse.success ?? 0).toString(),
              ),
              CommonListTile(
                title: "failure",
                subtitle: (fcmResponse.failure ?? 0).toString(),
              ),
              CommonListTile(
                title: "canonicalIds",
                subtitle: (fcmResponse.canonicalIds ?? 0).toString(),
              ),
              CommonListTile(
                title: "messageId",
                subtitle: fcmResponse.results?.first.messageId ?? "",
              ),
              CommonListTile(
                title: "error",
                subtitle: fcmResponse.results?.first.error ?? "",
              ),
            ],
          );
  }

  Future<void> showModalSheet() async {
    return Future<void>.value(
      showBarModalBottomSheet(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        context: context,
        builder: (BuildContext context) {
          return const Padding(
            padding: EdgeInsets.all(18.0),
            child: Text(
              // ignore: lines_longer_than_80_chars
              "Note: I configured this project with Firebase command-line interface. But due to the lack of an iOS physical phone, I haven't tested this project on any iOS device. This firebase cloud messaging demo works only with Android emulators, Android devices and Apple real iPhones (excluding iPhone simulators).",
            ),
          );
        },
      ),
    );
  }

  SnackbarController showSnackBar(String message) {
    return Get.showSnackbar(
      GetSnackBar(
        title: "Error",
        message: message,
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    log("didChangeAppLifecycleState state: ${state.toString()}");
    await _controller.updatePermissionStatus();
  }

  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeLocales(List<Locale>? locales) {}

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<bool> didPopRoute() {
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRoute(String route) {
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    throw UnimplementedError();
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
