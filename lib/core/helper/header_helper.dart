import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HeaderHelper {
  static String _appVersion = '';
  static String _buildNumber = '';
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    final info = await PackageInfo.fromPlatform();
    _appVersion = info.version;
    _buildNumber = info.buildNumber;
    _initialized = true;
  }

  static Future<Map<String, String>> getBaseHeaders() async {
    await ensureInitialized();
    final platform = Platform.isAndroid ? 'android' : 'ios';

    return {
      'X-Platform': platform,
      'X-App-Version': _appVersion,
      'X-Build-Number': _buildNumber,
    };
  }

  static Future<Map<String, String>> getAuthHeaders(String token) async {
    final baseHeaders = await getBaseHeaders();
    return {
      ...baseHeaders,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Future<Map<String, String>> getJsonHeaders() async {
    final baseHeaders = await getBaseHeaders();
    return {
      ...baseHeaders,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Future<Map<String, String>> getFormHeaders(String token) async {
    final baseHeaders = await getBaseHeaders();
    return {
      ...baseHeaders,
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  static void logHeaders(Map<String, String> headers) {
    if (kDebugMode) {
      debugPrint('====> Headers: $headers');
    }
  }
}
