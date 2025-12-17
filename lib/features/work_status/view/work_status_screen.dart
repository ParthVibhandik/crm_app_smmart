import 'package:flutex_admin/common/components/buttons/rounded_button.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkStatusScreen extends StatefulWidget {
  const WorkStatusScreen({super.key});

  @override
  State<WorkStatusScreen> createState() => _WorkStatusScreenState();
}

class _WorkStatusScreenState extends State<WorkStatusScreen> {
  bool? isWorking;
  final TextEditingController reasonController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.space20),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.cardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.space20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                    "Are you working today Or Not?",
                    style: semiBoldLarge.copyWith(
                      color: ColorResources.getHeadingTextColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.space20),
                  if (isWorking == null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: RoundedButton(
                            text: "YES",
                            press: () {
                              Get.offAllNamed(RouteHelper.dashboardScreen);
                            },
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: Dimensions.space10),
                        Expanded(
                          child: RoundedButton(
                            text: "NO",
                            press: () {
                              setState(() {
                                isWorking = false;
                              });
                            },
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            labelText: "Reason for not working",
                            controller: reasonController,
                            onChanged: (v) {},
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please provide a reason";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: Dimensions.space20),
                          Row(
                            children: [
                              Expanded(
                                child: RoundedButton(
                                  text: "Back",
                                  press: () {
                                    setState(() {
                                      isWorking = null;
                                    });
                                  },
                                  isOutlined: true,
                                ),
                              ),
                              const SizedBox(width: Dimensions.space10),
                              Expanded(
                                child: RoundedButton(
                                  text: "Submit",
                                  press: () {
                                    if (formKey.currentState!.validate()) {
                                      // Here you would typically save the reason to backend/prefs
                                      print("Reason: ${reasonController.text}");
                                      Get.offAllNamed(RouteHelper.dashboardScreen);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
