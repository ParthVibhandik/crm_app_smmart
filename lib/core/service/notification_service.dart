import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class NotificationService {
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    // Initialize Local Notifications first (doesn't hang)
    var androidInitialize = const AndroidInitializationSettings('icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    await flutterLocalNotificationsPlugin.initialize(
      initializationsSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null &&
            notificationResponse.payload!.isNotEmpty) {
          _handleNotificationNavigation(notificationResponse.payload!);
        }
      },
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('====> Foreground Message Received: ${message.messageId}');
      _showNotification(message, flutterLocalNotificationsPlugin);
    });

    // Handle app opening from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('====> Message opened app: ${message.messageId}');
      if (message.data.isNotEmpty) {
        _handleNotificationNavigation(jsonEncode(message.data));
      }
    });

    // Handle app opening from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('====> Initial message received: ${message.messageId}');
        if (message.data.isNotEmpty) {
          _handleNotificationNavigation(jsonEncode(message.data));
        }
      }
    });

    // Handle Firebase Messaging in a non-blocking way
    _initFirebaseMessaging();
  }

  static Future<void> _showNotification(RemoteMessage message,
      FlutterLocalNotificationsPlugin localNotifications) async {
    final notification = message.notification;
    if (notification != null) {
      String? imageUrl =
          notification.android?.imageUrl ?? notification.apple?.imageUrl;

      BigPictureStyleInformation? bigPictureStyleInformation;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final String largeIconPath =
              await _downloadAndSaveFile(imageUrl, 'largeIcon');
          final String bigPicturePath =
              await _downloadAndSaveFile(imageUrl, 'bigPicture');
          bigPictureStyleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(bigPicturePath),
            largeIcon: FilePathAndroidBitmap(largeIconPath),
            contentTitle: notification.title,
            summaryText: notification.body,
          );
        } catch (e) {
          debugPrint('====> Error downloading notification image: $e');
        }
      }

      localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: 'icon',
            styleInformation: bigPictureStyleInformation,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  static void _handleNotificationNavigation(String payload) {
    try {
      var data = jsonDecode(payload);
      String? type = data['type'] ?? data['screen'];
      String? typeId = data['type_id'];

      debugPrint('====> Navigating to: $type || ID: $typeId');

      if (typeId == null && type == null) return;

      if (type == 'invoice') {
        Get.toNamed(RouteHelper.invoiceDetailsScreen, arguments: typeId);
      } else if (type == 'lead') {
        Get.toNamed(RouteHelper.leadDetailsScreen, arguments: typeId);
      } else if (type == 'task') {
        Get.toNamed(RouteHelper.taskDetailsScreen, arguments: typeId);
      } else if (type == 'project') {
        Get.toNamed(RouteHelper.projectDetailsScreen, arguments: typeId);
      } else if (type == 'proposal') {
        Get.toNamed(RouteHelper.proposalDetailsScreen, arguments: typeId);
      } else if (type == 'estimate') {
        Get.toNamed(RouteHelper.estimateDetailsScreen, arguments: typeId);
      } else if (type == 'home') {
        Get.offAllNamed(RouteHelper.dashboardScreen);
      }
    } catch (e) {
      debugPrint('====> Navigation Error: $e');
    }
  }

  static Future<void> _initFirebaseMessaging() async {
    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      String? token = await messaging.getToken();
      if (token != null) {
        sendTokenToBackend(token);
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        sendTokenToBackend(newToken);
      });
    } catch (e) {
      debugPrint('====> Firebase Messaging Init Error: $e');
    }
  }

  static Future<void> showBigTextNotification(
      Map<String, String> data, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      data['body']!,
      htmlFormatBigText: true,
      contentTitle: data['title'],
      htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      LocalStrings.appName.tr,
      LocalStrings.appName.tr,
      importance: Importance.max,
      styleInformation: bigTextStyleInformation,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, data['title'], data['body'], platformChannelSpecifics,
        payload: jsonEncode(data));
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(
    Map<String, String> data,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    final String largeIconPath =
        await _downloadAndSaveFile(data['image']!, 'largeIcon');
    final String bigPicturePath =
        await _downloadAndSaveFile(data['image']!, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: data['title'],
      htmlFormatContentTitle: true,
      summaryText: data['body'],
      htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      LocalStrings.appName.tr,
      LocalStrings.appName.tr,
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      priority: Priority.max,
      playSound: true,
      styleInformation: bigPictureStyleInformation,
      importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, data['title'], data['body'], platformChannelSpecifics,
        payload: jsonEncode(data));
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final dio.Response response = await dio.Dio()
        .get(url, options: dio.Options(responseType: dio.ResponseType.bytes));
    final File file = File(filePath);
    await file.writeAsBytes(response.data);
    return filePath;
  }

  static Future<void> sendTokenToBackend(String token) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    String? accessToken =
        sharedPreferences.getString(SharedPreferenceHelper.accessTokenKey);

    if (accessToken != null) {
      try {
        String url = '${UrlContainer.baseUrl}${UrlContainer.fcmTokenUrl}';
        var body = jsonEncode({
          'fcm_token': token,
          'device': Platform.isAndroid ? 'android' : 'ios',
        });

        debugPrint('====> Send Token URL: $url');
        debugPrint('====> Send Token Body: $body');

        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: body,
        );
        debugPrint('====> Send Token Status: ${response.statusCode}');
        debugPrint('====> Send Token Response: ${response.body}');
      } catch (e) {
        debugPrint('====> Send Token Error: ${e.toString()}');
      }
    }
  }
}
