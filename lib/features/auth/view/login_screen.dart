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
              // Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorResources.primaryColor,
                      ColorResources.secondaryColor,
                      const Color(0xFF0F172A), // Deep Midnight
                    ],
                  ),
                ),
              ),
              
              // Abstract Circles
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
               Positioned(
                bottom: -50,
                right: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
        
              // Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          boxShadow: [
                             BoxShadow(
                               color: Colors.black.withValues(alpha: 0.2),
                               blurRadius: 20,
                               offset: const Offset(0, 10),
                             )
                          ],
                        ),
                        child: Image.asset(
                          MyImages.appLogo, 
                          height: 60,
                          width: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                       Text(
                        LocalStrings.login.tr,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        LocalStrings.loginDesc.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                           color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
        
                      // Glassmorphic Card
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              // Email
                              CustomTextField(
                                labelText: LocalStrings.email.tr,
                                controller: controller.emailController,
                                onChanged: (value) {},
                                focusNode: controller.emailFocusNode,
                                nextFocus: controller.passwordFocusNode,
                                textInputType: TextInputType.emailAddress,
                                inputAction: TextInputAction.next,
                                fillColor: Colors.white.withValues(alpha: 0.1),
                                animatedLabel: false, 
                                hintText: 'Enter your email',
                                prefix: const Icon(Icons.email_outlined, color: Colors.white70),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return LocalStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              // Password
                              CustomTextField(
                                labelText: LocalStrings.password.tr,
                                controller: controller.passwordController,
                                focusNode: controller.passwordFocusNode,
                                onChanged: (value) {},
                                isShowSuffixIcon: true,
                                isPassword: true,
                                fillColor: Colors.white.withValues(alpha: 0.1),
                                animatedLabel: false,
                                hintText: 'Enter your password',
                                 prefix: const Icon(Icons.lock_outline_rounded, color: Colors.white70),
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
                              const SizedBox(height: 20),
                              
                               Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Checkbox(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          side: const BorderSide(color: Colors.white70, width: 1.5),
                                          activeColor: ColorResources.secondaryColor,
                                          value: controller.remember,
                                          onChanged: (value) => controller.changeRememberMe(),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        LocalStrings.rememberMe.tr,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () => Get.toNamed(RouteHelper.forgotPasswordScreen),
                                    child: Text(
                                      LocalStrings.forgotPassword.tr,
                                       style: const TextStyle(
                                          color: ColorResources.secondaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 32),
                              
                              SizedBox(
                                width: double.infinity,
                                child: controller.isSubmitLoading
                                    ? const RoundedLoadingBtn()
                                    : ElevatedButton(
                                        onPressed: () {
                                           if (formKey.currentState!.validate()) {
                                            controller.loginUser();
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: ColorResources.secondaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 8,
                                          shadowColor: ColorResources.secondaryColor.withValues(alpha: 0.5),
                                        ),
                                        child: Text(
                                          LocalStrings.signIn.tr.toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
