import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/features/auth/repo/auth_repo.dart';

class ForgetPasswordController extends GetxController {
  AuthRepo loginRepo;

  ForgetPasswordController({required this.loginRepo});

  bool submitLoading = false;
  TextEditingController emailController = TextEditingController();
}
