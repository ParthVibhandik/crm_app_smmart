import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/features/auth/repo/auth_repo.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';

class ForgetPasswordController extends GetxController {
  AuthRepo loginRepo;

  ForgetPasswordController({required this.loginRepo});

  bool submitLoading = false;
  TextEditingController emailController = TextEditingController();

  
}
