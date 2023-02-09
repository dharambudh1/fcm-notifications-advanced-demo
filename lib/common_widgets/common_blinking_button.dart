import "dart:developer";

import "package:app_settings/app_settings.dart";
import "package:flutter/material.dart";

class CommonBlinkingButton extends StatefulWidget {
  const CommonBlinkingButton({required this.status, super.key});

  final bool status;

  @override
  CommonBlinkingButtonState createState() => CommonBlinkingButtonState();
}

class CommonBlinkingButtonState extends State<CommonBlinkingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (widget.status)
          rowWidget()
        else
          FadeTransition(
            opacity: _animationController,
            child: rowWidget(),
          ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(50, 50),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const CircleBorder(),
          ),
          onPressed: () async {
            await AppSettings.openNotificationSettings(
              callback: () {
                log("AppSettings.openNotificationSettings() callback");
              },
              asAnotherTask: true,
            );
          },
          child: const Icon(Icons.settings),
        )
      ],
    );
  }

  Widget rowWidget() {
    final String status = widget.status ? "Yes" : "No";
    final Color color = widget.status ? Colors.green : Colors.red;
    return Row(
      children: <Widget>[
        Text("Has Notification Permission: $status"),
        const SizedBox(width: 5),
        Icon(Icons.circle, color: color),
      ],
    );
  }
}
