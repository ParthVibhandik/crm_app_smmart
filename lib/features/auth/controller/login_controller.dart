import 'dart:convert';

import 'package:flutex_admin/features/auth/model/login_model.dart';
import 'package:flutex_admin/features/auth/repo/auth_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';

class LoginController extends GetxController {
  AuthRepo loginRepo;

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? email;
  String? password;
  bool remember = false;

  LoginController({required this.loginRepo});

  Future<void> checkAndGotoNextStep(LoginModel responseModel) async {
    await Future.wait([
      loginRepo.apiClient.sharedPreferences.setBool(
        SharedPreferenceHelper.rememberMeKey,
        remember,
      ),
      loginRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.userIdKey,
        responseModel.data?.staffId.toString() ?? '-1',
      ),
      loginRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.accessTokenKey,
        responseModel.data?.accessToken.toString() ?? '',
      ),
    ]);
    String? token = responseModel.data?.accessToken.toString() ?? '';
    print('Access Token: $token');
    Get.offAndToNamed(RouteHelper.dashboardScreen);

    if (remember) {
      changeRememberMe();
    }
  }

  bool isSubmitLoading = false;

  void loginUser() async {
    isSubmitLoading = true;
    update();

    ResponseModel responseModel = await loginRepo.loginUser(
      emailController.text.toString(),
      passwordController.text.toString(),
    );

    if (responseModel.status) {
      LoginModel loginModel = LoginModel.fromJson(
        jsonDecode(responseModel.responseJson),
      );
      checkAndGotoNextStep(loginModel);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isSubmitLoading = false;
    update();
  }

  changeRememberMe() {
    remember = !remember;
    update();
  }

  void clearTextField() {
    passwordController.text = '';
    emailController.text = '';
    if (remember) {
      remember = false;
    }
    update();
  }
}
