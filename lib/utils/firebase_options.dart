// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import "package:firebase_core/firebase_core.dart" show FirebaseOptions;
import "package:flutter/foundation.dart"
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        "DefaultFirebaseOptions have not been configured for web - "
        "you can reconfigure this by running the FlutterFire CLI again.",
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          "DefaultFirebaseOptions have not been configured for macos - "
          "you can reconfigure this by running the FlutterFire CLI again.",
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          "DefaultFirebaseOptions have not been configured for windows - "
          "you can reconfigure this by running the FlutterFire CLI again.",
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          "DefaultFirebaseOptions have not been configured for linux - "
          "you can reconfigure this by running the FlutterFire CLI again.",
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          "DefaultFirebaseOptions have not been configured for fuchsia - "
          "you can reconfigure this by running the FlutterFire CLI again.",
        );
      /*default:
        throw UnsupportedError(
          "DefaultFirebaseOptions are not supported for this platform.",
        );*/
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDY5l6e4TLoDMYbh5jt5nZ2amEcpDdtouM",
    appId: "1:797348463436:android:21de73e6ffeedc5bbe45e9",
    messagingSenderId: "797348463436",
    projectId: "push-notification-demo-e1cdf",
    storageBucket: "push-notification-demo-e1cdf.appspot.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyD49pC4oNTvOhtk24tUE3fY1lelaPnLenA",
    appId: "1:797348463436:ios:9167fa9a38e08ecfbe45e9",
    messagingSenderId: "797348463436",
    projectId: "push-notification-demo-e1cdf",
    storageBucket: "push-notification-demo-e1cdf.appspot.com",
    iosClientId:
        "797348463436-kqfqi4m1kvqhmt8pu6gvn9a3n4fnk41s.apps.googleusercontent.com",
    iosBundleId: "com.example.pushNotificationsDemo",
  );
}
