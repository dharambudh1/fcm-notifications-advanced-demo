import "dart:convert";
import "dart:developer";
import "dart:typed_data";

import "package:http/http.dart" as http;
import "package:internet_connection_checker/internet_connection_checker.dart";
import "package:push_notifications_demo/model/firebase_request_model.dart";
import "package:push_notifications_demo/model/firebase_response_model.dart";
import "package:push_notifications_demo/model/mock_codes_model.dart";
import "package:transparent_image/transparent_image.dart";

class NetworkService {
  final String chunk1 = "AAAAuaWsA0w:APA91bF0sH3iwO33aTSbAmfcS50byeY1e04aCkD";
  final String chunk2 = "QkQPa6bYtdwQbGfva3t7A9ziaoXmArctJSeFGfstcSHtXYrAerB";
  final String chunk3 = "2KHhMusMP9zrQEURFu1KYz1Jv9WmaS2109e-1oP_fneFoxGGFJ";

  Future<FCMResponseModel> requestToFirebase({
    required FCMRequestModel model,
    required void Function(String) callbackHandle,
  }) async {
    FCMResponseModel fcmResponse = FCMResponseModel();
    if (await hasConnection() == false) {
      callbackHandle("No internet");
      return Future<FCMResponseModel>.value(fcmResponse);
    } else {
      http.Response response = http.Response("", 500);
      try {
        response = await http.post(
          Uri.parse("https://fcm.googleapis.com/fcm/send"),
          body: json.encode(model),
          headers: <String, String>{
            "Content-Type": "application/json",
            "Authorization": "key=${chunk1 + chunk2 + chunk3}"
          },
        );
      } on Exception catch (error) {
        callbackHandle("Exception: requestToFirebase(): ${error.toString()}");
      }
      final MockCodesModel reason = await mockCodes(response.statusCode);
      reason.statusCode.toString().startsWith("2")
          ? fcmResponse = FCMResponseModel.fromJson(json.decode(response.body))
          : callbackHandle(mockMessage(reason));
      return Future<FCMResponseModel>.value(fcmResponse);
    }
  }

  Future<Uint8List> getByteArrayFromUrl({
    required String url,
    required void Function(String) callbackHandle,
  }) async {
    Uint8List int8list = kTransparentImage;
    if (await hasConnection() == false) {
      callbackHandle("No internet");
      return Future<Uint8List>.value(int8list);
    } else {
      http.Response response = http.Response("", 500);
      try {
        response = await http.get(Uri.parse(url));
      } on Exception catch (error) {
        callbackHandle("Exception: getByteArrayFromUrl(): ${error.toString()}");
      }
      final MockCodesModel reason = await mockCodes(response.statusCode);
      reason.statusCode.toString().startsWith("2")
          ? int8list = response.bodyBytes
          : callbackHandle(mockMessage(reason));
      return Future<Uint8List>.value(int8list);
    }
  }

  Future<MockCodesModel> mockCodes(int code) async {
    MockCodesModel mockCodesModel = MockCodesModel();
    if (await hasConnection() == false) {
      log("No internet");
      return Future<MockCodesModel>.value(mockCodesModel);
    } else {
      http.Response response = http.Response("", 500);
      try {
        response = await http.get(Uri.parse("https://mock.codes/$code"));
      } on Exception catch (error) {
        log("Exception: mockCodes(): ${error.toString()}");
      }
      mockCodesModel = MockCodesModel.fromJson(json.decode(response.body));
      return Future<MockCodesModel>.value(mockCodesModel);
    }
  }

  String mockMessage(MockCodesModel reason) {
    final String type = reason.statusCode.toString().startsWith("2")
        ? "type: 2×× Success\n"
        : reason.statusCode.toString().startsWith("3")
            ? "type: 3×× Redirection\n"
            : reason.statusCode.toString().startsWith("4")
                ? "type: 4×× Client Error\n"
                : reason.statusCode.toString().startsWith("5")
                    ? "type: 5×× Server Error\n"
                    : "Unknown Error\n";
    final String statusCode = "statusCode: ${reason.statusCode}\n";
    final String description = "description: ${reason.description}";
    return type + statusCode + description;
  }

  Future<bool> hasConnection() async {
    final bool result = await InternetConnectionChecker().hasConnection;
    log("hasConnection() result: $result");
    return Future<bool>.value(result);
  }
}
