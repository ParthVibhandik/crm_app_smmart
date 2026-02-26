import 'package:flutex_admin/common/components/buttons/rounded_button.dart';
import 'package:flutex_admin/common/components/buttons/rounded_loading_button.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/lead/controller/lead_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConvertToCustomerSheet extends StatefulWidget {
  final String leadId;
  const ConvertToCustomerSheet({super.key, required this.leadId});

  @override
  State<ConvertToCustomerSheet> createState() => _ConvertToCustomerSheetState();
}

class _ConvertToCustomerSheetState extends State<ConvertToCustomerSheet> {
  @override
  void initState() {
    super.initState();
    Get.find<LeadDetailsController>().initConversionForm();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space15, vertical: Dimensions.space20),
      child: GetBuilder<LeadDetailsController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Convert to Customer',
                      style: regularLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),
                const SizedBox(height: Dimensions.space20),
                CustomTextField(
                  labelText: 'First Name',
                  controller: controller.firstNameController,
                  onChanged: (v) {},
                ),
                const SizedBox(height: Dimensions.space15),
                CustomTextField(
                  labelText: 'Last Name',
                  controller: controller.lastNameController,
                  onChanged: (v) {},
                ),
                const SizedBox(height: Dimensions.space15),
                CustomTextField(
                  labelText: 'Email',
                  controller: controller.emailController,
                  onChanged: (v) {},
                ),
                const SizedBox(height: Dimensions.space15),
                CustomTextField(
                  labelText: 'Company',
                  controller: controller.companyController,
                  onChanged: (v) {},
                ),
                const SizedBox(height: Dimensions.space15),
                CustomTextField(
                  labelText: 'Phone Number',
                  controller: controller.phoneNumberController,
                  onChanged: (v) {},
                ),
                const SizedBox(height: Dimensions.space15),
                CustomTextField(
                  labelText: 'Website',
                  controller: controller.websiteController,
                  onChanged: (v) {},
                ),
                const SizedBox(height: Dimensions.space15),
                CustomTextField(
                  labelText: 'Designation',
                  controller: controller.designationController,
                  onChanged: (v) {},
                ),
                const SizedBox(height: Dimensions.space15),
                CustomTextField(
                  labelText: 'Address',
                  controller: controller.addressController,
                  onChanged: (v) {},
                ),
                const SizedBox(height: Dimensions.space15),
                CustomTextField(
                  labelText: 'City',
                  controller: controller.cityController,
                  onChanged: (v) {},
                ),
                const SizedBox(height: Dimensions.space15),
                CustomTextField(
                  labelText: 'State',
                  controller: controller.stateController,
                  onChanged: (v) {},
                ),
                const SizedBox(height: Dimensions.space15),
                CustomTextField(
                  labelText: 'Country (ID)',
                  controller: controller.countryController,
                  onChanged: (v) {},
                ),
                const SizedBox(height: Dimensions.space15),
                CustomTextField(
                  labelText: 'Zip Code',
                  controller: controller.zipController,
                  onChanged: (v) {},
                ),
                const SizedBox(height: Dimensions.space15),
                CustomTextField(
                  labelText: 'Password',
                  controller: controller.passwordController,
                  onChanged: (v) {},
                  isPassword: true,
                  isShowSuffixIcon: true,
                ),
                const SizedBox(height: Dimensions.space25),
                controller.isConvertLoading
                    ? const RoundedLoadingBtn()
                    : RoundedButton(
                        text: 'Convert',
                        press: () {
                          controller.convertLead(widget.leadId);
                        },
                      ),
                const SizedBox(height: Dimensions.space20),
              ],
            ),
          );
        },
      ),
    );
  }
}
