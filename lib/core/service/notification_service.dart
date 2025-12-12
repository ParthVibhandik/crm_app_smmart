import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class NotificationService {
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(
      initializationsSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        String? typeId;
        String? type = 'general';
        if (notificationResponse.payload!.isNotEmpty) {
          type = jsonDecode(notificationResponse.payload!)['type'];
          typeId = jsonDecode(notificationResponse.payload!)['type_id'];
          debugPrint('====> Notification Type: $type || Type Id: $typeId');
        }
        try {
          if (typeId == null) {
            //
          } else if (type == 'message') {
            //
          } else if (type == 'invoice') {
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
          }
        } catch (e) {
          return;
        }
        return;
      },
    );
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
}
