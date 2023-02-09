import "package:flutter/material.dart";
import "package:push_notifications_demo/model/firebase_request_model.dart";

class CommonRadioButton extends StatelessWidget {
  const CommonRadioButton(this._notificationType, {super.key});

  final NotificationType _notificationType;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _notificationType.isSelected
          ? Theme.of(context).buttonTheme.colorScheme!.primary
          : Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        height: 80,
        width: 80,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(5.0),
        child: Text(
          _notificationType.name,
          style: TextStyle(
            color: _notificationType.isSelected ? Colors.white : Colors.grey,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
