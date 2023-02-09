class NotificationType {
  NotificationType({
    required this.name,
    required this.value,
    required this.isSelected,
  });

  String name;
  String value;

  bool isSelected;
}

class FCMRequestModel {
  FCMRequestModel({
    this.notification,
    this.data,
    this.to,
  });

  FCMRequestModel.fromJson(Map<String, dynamic> json) {
    notification = json["notification"] != null
        ? Notification.fromJson(json["notification"])
        : null;
    data = json["data"] != null ? Data.fromJson(json["data"]) : null;
    to = json["to"];
  }

  Notification? notification;
  Data? data;
  String? to;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (notification != null) {
      map["notification"] = notification?.toJson();
    }
    if (data != null) {
      map["data"] = data?.toJson();
    }
    map["to"] = to;
    return map;
  }
}

class Data {
  Data({
    this.clickAction,
    this.title,
    this.body,
    this.id,
    this.screen,
  });

  Data.fromJson(Map<String, dynamic> json) {
    clickAction = json["click_action"];
    title = json["title"];
    body = json["body"];
    id = json["_id"];
    screen = json["screen"];
  }

  String? clickAction;
  String? title;
  String? body;
  String? id;
  String? screen;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["click_action"] = clickAction;
    map["title"] = title;
    map["body"] = body;
    map["_id"] = id;
    map["screen"] = screen;
    return map;
  }
}

class Notification {
  Notification({
    this.title,
    this.body,
    this.channelId,
    this.icon,
    this.color,
    this.image,
  });

  Notification.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    body = json["body"];
    channelId = json["android_channel_id"];
    icon = json["icon"];
    color = json["color"];
    image = json["image"];
  }

  String? title;
  String? body;
  String? channelId;
  String? icon;
  String? color;
  String? image;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["title"] = title;
    map["body"] = body;
    map["android_channel_id"] = channelId;
    map["icon"] = icon;
    map["color"] = color;
    map["image"] = image;
    return map;
  }
}
