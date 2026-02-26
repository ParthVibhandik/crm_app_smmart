import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouteObserver extends GetObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      _saveRoute(route.settings.name!);
    }
  }

  void _saveRoute(String routeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_route', routeName);
  }
}
