import "package:push_notifications_demo/model/firebase_request_model.dart";
import "package:push_notifications_demo/services/notification_service.dart";

List<NotificationType> notificationTypeList = <NotificationType>[
  NotificationType(
    name: "Overlay",
    value: NotificationService().overlayNotification,
    isSelected: true,
  ),
  NotificationType(
    name: "Instant",
    value: NotificationService().instantNotification,
    isSelected: false,
  ),
  NotificationType(
    name: "Custom Sound",
    value: NotificationService().notificationWithCustomSound,
    isSelected: false,
  ),
  NotificationType(
    name: "Schedule for 10 sec",
    value: NotificationService().scheduledNotification,
    isSelected: false,
  ),
  NotificationType(
    name: "Misc.",
    value: NotificationService().miscellaneousNotification,
    isSelected: false,
  ),
];
