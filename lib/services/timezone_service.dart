import "dart:developer";

import "package:flutter_native_timezone/flutter_native_timezone.dart";
import "package:timezone/data/latest_all.dart" as timezone;
import "package:timezone/timezone.dart" as timezone;

class TimeZoneService {
  factory TimeZoneService() {
    return _singleton;
  }

  TimeZoneService._internal();

  static final TimeZoneService _singleton = TimeZoneService._internal();

  Future<void> getLocalTimezoneAndInitialize() async {
    String currentTimeZone = "";
    currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    log("currentTimeZone: $currentTimeZone");
    initializeTimeZones(currentTimeZone);
    return Future<void>.value();
  }

  void initializeTimeZones(String currentTimeZone) {
    timezone.initializeTimeZones();
    timezone.setLocalLocation(timezone.getLocation(currentTimeZone));
    return;
  }
}
