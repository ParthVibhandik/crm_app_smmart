import 'dart:convert';
import 'dart:io';

import 'package:flutex_admin/core/helper/header_helper.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:url_launcher/url_launcher.dart';

class ApiClient extends GetxService {
  SharedPreferences sharedPreferences;
  ApiClient({required this.sharedPreferences});

  Future<ResponseModel> request(
      String uri, String method, Map<String, dynamic>? params,
      {bool passHeader = false}) async {
    Uri url = Uri.parse(uri);
    http.Response response;
    Map<String, String> headers = await HeaderHelper.getBaseHeaders();

    try {
      if (method == Method.postMethod) {
        headers['Accept'] = 'application/json';
        if (passHeader) {
          initToken();
          if (token.isNotEmpty) headers['Authorization'] = token;
        }
        HeaderHelper.logHeaders(headers);
        if (passHeader) {
          response = await http.post(url, body: params, headers: headers);
        } else {
          response = await http.post(url, body: params, headers: headers);
        }
      } else if (method == Method.putMethod) {
        headers['Content-Type'] =
            'application/x-www-form-urlencoded; charset=UTF-8';
        headers['Accept'] = 'application/json';
        initToken();
        if (token.isNotEmpty) headers['Authorization'] = token;
        HeaderHelper.logHeaders(headers);
        response = await http.put(url, body: params, headers: headers);
      } else if (method == Method.deleteMethod) {
        headers['Accept'] = 'application/json';
        initToken();
        if (token.isNotEmpty) headers['Authorization'] = token;
        HeaderHelper.logHeaders(headers);
        response = await http.delete(url, headers: headers);
      } else {
        headers['Accept'] = 'application/json';
        if (passHeader) {
          initToken();
          if (token.isNotEmpty) headers['Authorization'] = token;
          HeaderHelper.logHeaders(headers);
          response = await http.get(url, headers: headers);
        } else {
          HeaderHelper.logHeaders(headers);
          response = await http.get(url, headers: headers);
        }
      }

      if (kDebugMode) {
        print('====> url: ${uri.toString()}');
        print('====> method: $method');
        print('====> params: ${params.toString()}');
        print('====> status: ${response.statusCode}');
        print('====> body: ${response.body.toString()}');
        print('====> token: $token');
      }

      Map<String, dynamic>? responseJson;
      try {
        responseJson = jsonDecode(response.body) as Map<String, dynamic>?;
      } on FormatException {
        return ResponseModel(false, LocalStrings.badResponseMsg.tr, '');
      }

      if (responseJson == null) {
        debugPrint('====> Response is not a valid JSON object');
        return ResponseModel(false, LocalStrings.badResponseMsg.tr, '');
      }

      // Handle force update before any other status handling
      if (response.statusCode == 426 ||
          responseJson['error_code'] == 'APP_UPDATE_REQUIRED' ||
          responseJson['error'] ==
              'A new update is available. Please update the app to continue.') {
        _handleAppUpdateRequired(responseJson);
        return ResponseModel(
          false,
          responseJson['message']?.toString() ??
              responseJson['error']?.toString() ??
              'App update required',
          response.body,
        );
      }

      // Missing headers error must stop flow
      if (response.statusCode == 400 &&
          responseJson['error'] ==
              'Missing or unsupported app version headers.') {
        return ResponseModel(
          false,
          responseJson['error']?.toString() ??
              'Missing or unsupported app version headers.',
          response.body,
        );
      }

      StatusModel model = StatusModel.fromJson(responseJson);

      if (response.statusCode == 200) {
        try {
          if (!model.status!) {
            sharedPreferences.setBool(
                SharedPreferenceHelper.rememberMeKey, false);
            sharedPreferences.remove(SharedPreferenceHelper.token);
            Get.offAllNamed(RouteHelper.loginScreen);
          }
        } catch (e) {
          e.toString();
        }

        return ResponseModel(true, model.message!.tr, response.body);
      } else if (response.statusCode == 401) {
        sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
        Get.offAllNamed(RouteHelper.loginScreen);
        return ResponseModel(false, model.message!.tr, response.body);
      } else if (response.statusCode == 404) {
        return ResponseModel(false, model.message!.tr, response.body);
      } else if (response.statusCode == 500) {
        return ResponseModel(
            false, model.message?.tr ?? LocalStrings.serverError.tr, '');
      } else {
        return ResponseModel(
            false, model.message?.tr ?? LocalStrings.somethingWentWrong.tr, '');
      }
    } on SocketException {
      return ResponseModel(false, LocalStrings.somethingWentWrong.tr, '');
    } catch (e) {
      return ResponseModel(false, e.toString(), '');
    }
  }

  String token = '';

  initToken() {
    if (sharedPreferences.containsKey(SharedPreferenceHelper.accessTokenKey)) {
      String? t =
          sharedPreferences.getString(SharedPreferenceHelper.accessTokenKey);
      // Ensure the token has the "Bearer " prefix if it's not already there.
      // Some backends require "Bearer <token>", others just "<token>".
      // Given the 401, trying standard Bearer format is a strong potential fix.
      if (t != null && t.isNotEmpty) {
        token = t.startsWith('Bearer ') ? t : 'Bearer $t';
      } else {
        token = '';
      }
    } else {
      token = '';
    }
  }

  void _handleAppUpdateRequired(Map<String, dynamic> responseJson) {
    final updateUrl = responseJson['update_url']?.toString();

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Update Required'),
          content: Text(
            responseJson['message']?.toString() ??
                responseJson['error']?.toString() ??
                'Please update the app to continue.',
          ),
          actions: [
            TextButton(
              onPressed: updateUrl == null
                  ? null
                  : () async {
                      final uri = Uri.parse(updateUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
