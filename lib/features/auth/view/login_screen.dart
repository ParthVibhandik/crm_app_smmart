import 'package:flutex_admin/common/components/animated_background.dart';
import 'package:flutex_admin/common/components/buttons/neon_button.dart';
import 'package:flutex_admin/common/components/glass_container.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/common/components/will_pop_widget.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/auth/controller/login_controller.dart';
import 'package:flutex_admin/features/auth/repo/auth_repo.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

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
  Widget build(BuildContext context) {
    // Theme references
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    // Dynamic width for the card based on screen width
    // On tablet/desktop, we cap it. On mobile, we give it some margin.
    double cardWidth = size.width > 600 ? 500 : size.width * 0.9;

    return WillPopWidget(
      nextRoute: '',
      child: Scaffold(
        // Ensure background is correct even if AnimatedBackground fails or loads slow
        backgroundColor: ColorResources.voidBackground,
        body: Stack(
          children: [
            // 1. Background Animation layer
            const Positioned.fill(child: AnimatedBackground()),

            // 2. Main Scrollable Content
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(), // Prevent bounce on empty space
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo Animation
                            Image.asset(
                              MyImages.smmartLogo,
                              height: 80,
                              color: Colors.white,
                            )
                                .animate()
                                .fadeIn(duration: 800.ms)
                                .slideY(begin: -0.2, end: 0, curve: Curves.easeOutBack),

                            const SizedBox(height: 50),

                            // Glass Login Card
                            GlassContainer(
                              width: cardWidth,
                              // No fixed height -> lets content expand freely
                              blur: 20,
                              opacity: 0.08,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.all(32),
                              child: GetBuilder<LoginController>(
                                builder: (controller) => Form(
                                  key: formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Logo
                                      Image.asset(
                                        MyImages.smmartLogo,
                                        height: 60,
                                      ).animate().scale(delay: 200.ms),

                                      const SizedBox(height: 20),

                                      // Header
                                      Text(
                                        LocalStrings.login.tr,
                                        style: theme.textTheme.displayLarge?.copyWith(
                                          fontSize: 28,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ).animate().fadeIn(delay: 300.ms),

                                      const SizedBox(height: 8),

                                      Text(
                                        LocalStrings.loginDesc.tr,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white70,
                                        ),
                                        textAlign: TextAlign.center,
                                      ).animate().fadeIn(delay: 350.ms),

                                      const SizedBox(height: 40),

                                      // Email Field
                                      CustomTextField(
                                        controller: controller.emailController,
                                        labelText: LocalStrings.email.tr,
                                        hintText: LocalStrings.enterEmail.tr,
                                        textInputType: TextInputType.emailAddress,
                                        prefix: const Icon(Icons.email_outlined),
                                        fillColor: ColorResources.glassBlack,
                                        onChanged: (val) {},
                                      ).animate().fadeIn(delay: 400.ms).moveX(begin: -20),

                                      const SizedBox(height: 20),

                                      // Password Field
                                      CustomTextField(
                                        controller: controller.passwordController,
                                        labelText: LocalStrings.password.tr,
                                        hintText: LocalStrings.passwordHint.tr,
                                        isPassword: true,
                                        isShowSuffixIcon: true,
                                        prefix: const Icon(Icons.lock_outline),
                                        fillColor: ColorResources.glassBlack,
                                        onChanged: (val) {},
                                      ).animate().fadeIn(delay: 500.ms).moveX(begin: 20),

                                      const SizedBox(height: 20),

                                      // Remember Me / Forgot Password
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: Checkbox(
                                                  value: controller.remember,
                                                  activeColor: ColorResources.neonCyan,
                                                  checkColor: Colors.black,
                                                  side: BorderSide(
                                                    color: Colors.white.withOpacity(0.5),
                                                  ),
                                                  onChanged: (val) => controller.changeRememberMe(),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                LocalStrings.rememberMe.tr,
                                                style: theme.textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Add forgot password logic if needed
                                            },
                                            child: Text(
                                              LocalStrings.forgotPassword.tr,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: ColorResources.neonCyan,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        ],
                                      ).animate().fadeIn(delay: 600.ms),

                                      const SizedBox(height: 30),

                                      // Login Button
                                      controller.isSubmitLoading
                                          ? const Center(
                                              child: CircularProgressIndicator(
                                                color: ColorResources.neonCyan,
                                              ),
                                            )
                                          : NeonButton(
                                              text: LocalStrings.login.tr,
                                              onTap: () {
                                                if (formKey.currentState!.validate()) {
                                                  controller.loginUser();
                                                }
                                              },
                                            )
                                              .animate()
                                              .fadeIn(delay: 700.ms)
                                              .scale(
                                                begin: const Offset(0.9, 0.9),
                                                curve: Curves.elasticOut,
                                              ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            // Footer / Version
                            Text(
                              "v2.0.0 Future Edition",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
