import 'package:flutex_admin/common/components/buttons/rounded_button.dart';
import 'package:flutex_admin/common/components/buttons/rounded_loading_button.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/common/components/text/default_text.dart';
import 'package:flutex_admin/common/components/will_pop_widget.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/auth/controller/login_controller.dart';
import 'package:flutex_admin/features/auth/repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(AuthRepo(apiClient: Get.find()));
    Get.put(LoginController(loginRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LoginController>().remember = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: '',
      child: Scaffold(
        body: GetBuilder<LoginController>(
          builder: (controller) => Stack(
            children: [
              // Background Animation
              Positioned.fill(
                child: RepaintBoundary(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 15),
                    builder: (context, value, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor, // Deep Blue
                              ColorResources.secondaryColor.withValues(alpha: 0.3), // Solar Orange Splash
                              Theme.of(context).primaryColor.withValues(alpha: 0.8),
                              Theme.of(context).primaryColor,
                            ],
                            stops: [
                              0.0,
                              (value * 0.5 + 0.1),
                              (value * 0.8 + 0.2),
                              1.0,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Main Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: Dimensions.space50),
                        Image.asset(
                          MyImages.smmartLogo,
                          height: 80,
                        ),
                        const SizedBox(height: Dimensions.space30),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.space30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocalStrings.login.tr,
                                style: mediumMegaLarge.copyWith(
                                  color: ColorResources.getHeadingTextColor(),
                                ),
                              ),
                              Text(
                                LocalStrings.loginDesc.tr,
                                style: regularDefault.copyWith(
                                  color: ColorResources.getContentTextColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.space20),
                        Container(
                          padding: const EdgeInsets.all(Dimensions.space30),
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                CustomTextField(
                                  labelText: LocalStrings.email.tr,
                                  controller: controller.emailController,
                                  onChanged: (value) {},
                                  focusNode: controller.emailFocusNode,
                                  nextFocus: controller.passwordFocusNode,
                                  textInputType: TextInputType.emailAddress,
                                  inputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return LocalStrings.fieldErrorMsg.tr;
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                const SizedBox(height: Dimensions.space20),
                                CustomTextField(
                                  labelText: LocalStrings.password.tr,
                                  controller: controller.passwordController,
                                  onChanged: (value) {},
                                  focusNode: controller.passwordFocusNode,
                                  isShowSuffixIcon: true,
                                  isPassword: true,
                                  textInputType: TextInputType.text,
                                  inputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return LocalStrings.fieldErrorMsg.tr;
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                const SizedBox(height: Dimensions.space20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: Checkbox(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                Dimensions.defaultRadius,
                                              ),
                                            ),
                                            activeColor:
                                                ColorResources.primaryColor,
                                            checkColor:
                                                ColorResources.colorWhite,
                                            value: controller.remember,
                                            onChanged: (value) {
                                              controller.changeRememberMe();
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        DefaultText(
                                          text: LocalStrings.rememberMe.tr,
                                          textColor: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color!
                                              .withValues(alpha: 0.5),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Get.toNamed(
                                          RouteHelper.forgotPasswordScreen,
                                        );
                                      },
                                      child: DefaultText(
                                        text: LocalStrings.forgotPassword.tr,
                                        textColor:
                                            ColorResources.secondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.space20),
                                controller.isSubmitLoading
                                    ? const RoundedLoadingBtn()
                                    : RoundedButton(
                                        text: LocalStrings.signIn.tr,
                                        press: () {
                                          if (formKey.currentState!
                                              .validate()) {
                                            controller.loginUser();
                                          }
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.space20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
