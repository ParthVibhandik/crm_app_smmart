import 'dart:convert';
import 'dart:io';

import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/method.dart';

class ApiClient extends GetxService {
  SharedPreferences sharedPreferences;
  ApiClient({required this.sharedPreferences});

  Future<ResponseModel> request(
      String uri, String method, Map<String, dynamic>? params,
      {bool passHeader = false}) async {
    Uri url = Uri.parse(uri);
    http.Response response;

    try {
      if (method == Method.postMethod) {
        if (passHeader) {
          initToken();
          response = await http.post(url,
              body: params,
              headers: {'Accept': 'application/json', 'Authorization': token});
        } else {
          response = await http.post(url, body: params);
        }
      } else if (method == Method.putMethod) {
        initToken();
        response = await http.put(url, body: params, headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': token
        });
      } else if (method == Method.deleteMethod) {
        initToken();
        response = await http.delete(url,
            headers: {'Accept': 'application/json', 'Authorization': token});
      } else {
        if (passHeader) {
          initToken();
          response = await http.get(url,
              headers: {'Accept': 'application/json', 'Authorization': token});
        } else {
          response = await http.get(url);
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

      // Handle non-200 status codes before attempting JSON parsing
      if (response.statusCode == 500) {
        return ResponseModel(false, LocalStrings.serverError.tr, response.body);
      } else if (response.statusCode == 404) {
        try {
          StatusModel model = StatusModel.fromJson(jsonDecode(response.body));
          return ResponseModel(false, model.message!.tr, response.body);
        } catch (e) {
          return ResponseModel(
              false, LocalStrings.somethingWentWrong.tr, response.body);
        }
      } else if (response.statusCode == 401) {
        try {
          StatusModel model = StatusModel.fromJson(jsonDecode(response.body));
          sharedPreferences.setBool(
              SharedPreferenceHelper.rememberMeKey, false);
          Get.offAllNamed(RouteHelper.loginScreen);
          return ResponseModel(false, model.message!.tr, response.body);
        } catch (e) {
          sharedPreferences.setBool(
              SharedPreferenceHelper.rememberMeKey, false);
          Get.offAllNamed(RouteHelper.loginScreen);
          return ResponseModel(
              false, LocalStrings.somethingWentWrong.tr, response.body);
        }
      }

      // Try to parse JSON response for 200 status
      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);
          // Some endpoints return {status: bool, message: ...}
          if (decoded is Map && decoded['status'] is bool) {
            StatusModel model = StatusModel.fromJson(decoded);
            // If backend says unauthenticated, log out
            if (model.status == false) {
              sharedPreferences.setBool(
                  SharedPreferenceHelper.rememberMeKey, false);
              sharedPreferences.remove(SharedPreferenceHelper.token);
              Get.offAllNamed(RouteHelper.loginScreen);
            }
            return ResponseModel(true, model.message?.tr ?? '', response.body);
          }

          // Fallback: when status is not a bool (e.g., numeric task status like "5")
          return ResponseModel(true, '', response.body);
        } catch (e) {
          // If parsing fails, still return success with raw body
          return ResponseModel(true, '', response.body);
        }
      } else {
        // Should not reach here because non-200 handled above, keep safe fallback
        return ResponseModel(
            false, LocalStrings.somethingWentWrong.tr, response.body);
      }
    } on SocketException {
      return ResponseModel(false, LocalStrings.somethingWentWrong.tr, '');
    } on FormatException {
      sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
      Get.offAllNamed(RouteHelper.loginScreen);
      return ResponseModel(false, LocalStrings.badResponseMsg.tr, '');
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
}
