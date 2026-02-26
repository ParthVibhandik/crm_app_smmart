import 'package:async/async.dart';
import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/buttons/rounded_button.dart';
import 'package:flutex_admin/common/components/buttons/rounded_loading_button.dart';
import 'package:flutex_admin/common/components/custom_drop_down_button_with_text_field.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_amount_text_field.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_drop_down_text_field.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/lead/controller/lead_controller.dart';
import 'package:flutex_admin/features/lead/model/sources_model.dart';
import 'package:flutex_admin/features/lead/model/statuses_model.dart';
import 'package:flutex_admin/features/staff/model/staff_model.dart';
import 'package:flutex_admin/common/components/custom_multi_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final AsyncMemoizer<SourcesModel> sourcesMemoizer = AsyncMemoizer();
  final AsyncMemoizer<StatusesModel> statusesMemoizer = AsyncMemoizer();
  final AsyncMemoizer<StaffsModel> assigneeMemoizer = AsyncMemoizer();
  final AsyncMemoizer<SourcesModel> industriesMemoizer = AsyncMemoizer();
  final AsyncMemoizer<SourcesModel> designationsMemoizer = AsyncMemoizer();
  final AsyncMemoizer<SourcesModel> interestedInMemoizer = AsyncMemoizer();

  @override
  void dispose() {
    Get.find<LeadController>().clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: LocalStrings.createNewLead.tr,
      ),
      body: GetBuilder<LeadController>(
        builder: (controller) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.space15),
              child: Column(
                spacing: Dimensions.space15,
                children: [
                  // 1. Source* (Existing)
                  FutureBuilder(
                      future:
                          sourcesMemoizer.runOnce(controller.loadLeadSources),
                      builder: (context, sourceList) {
                        if (sourceList.data?.status ?? false) {
                          return CustomDropDownTextField(
                            hintText: LocalStrings.selectSource.tr,
                            isRequired: true,
                            needLabel: false,
                            onChanged: (value) {
                              controller.sourceController.text =
                                  value.toString();
                            },
                            selectedValue: controller.sourceController.text,
                            items: controller.sourcesModel.data!.map((value) {
                              return DropdownMenuItem(
                                value: value.id,
                                child: Text(
                                  value.name?.tr ?? '',
                                  style: regularDefault.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color),
                                ),
                              );
                            }).toList(),
                          );
                        } else if (sourceList.data?.status == false) {
                          return CustomDropDownWithTextField(
                              selectedValue: LocalStrings.noSourceFound.tr,
                              list: [LocalStrings.noSourceFound.tr]);
                        } else {
                          return const CustomLoader(isFullScreen: false);
                        }
                      }),
                  // 2. Status* (Existing)
                  FutureBuilder(
                      future:
                          statusesMemoizer.runOnce(controller.loadLeadStatuses),
                      builder: (context, statusList) {
                        if (statusList.data?.status ?? false) {
                          return CustomDropDownTextField(
                            hintText: LocalStrings.selectStatus.tr,
                            isRequired: true,
                            needLabel: false,
                            onChanged: (value) {
                              controller.statusController.text =
                                  value.toString();
                            },
                            selectedValue: controller.statusController.text,
                            items: controller.statusesModel.data!.map((value) {
                              return DropdownMenuItem(
                                value: value.id,
                                child: Text(
                                  value.name?.tr ?? '',
                                  style: regularDefault.copyWith(
                                      color: Converter.hexStringToColor(
                                          value.color ?? '')),
                                ),
                              );
                            }).toList(),
                          );
                        } else if (statusList.data?.status == false) {
                          return CustomDropDownWithTextField(
                              selectedValue: LocalStrings.noStatusFound.tr,
                              list: [LocalStrings.noStatusFound.tr]);
                        } else {
                          return const CustomLoader(isFullScreen: false);
                        }
                      }),
                  // 3. Assigned* (Existing)
                  FutureBuilder(
                      future: assigneeMemoizer.runOnce(controller.loadStaff),
                      builder: (context, staffList) {
                        if (staffList.data?.status ?? false) {
                          return CustomDropDownTextField(
                            hintText: "Assigned",
                            isRequired: true,
                            needLabel: false,
                            onChanged: (value) {
                              controller.assignedController.text =
                                  value.toString();
                            },
                            selectedValue: controller.assignedController.text,
                            items: controller.staffsModel.data!.map((value) {
                              return DropdownMenuItem(
                                value: value.id, // Using correct ID now
                                child: Text(
                                  value.fullName ?? '-',
                                  style: regularDefault.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color),
                                ),
                              );
                            }).toList(),
                          );
                        } else if (staffList.data?.status == false) {
                          return CustomDropDownWithTextField(
                              selectedValue: LocalStrings.noStaffFound.tr,
                              list: [LocalStrings.noStaffFound.tr]);
                        } else {
                          return const CustomLoader(isFullScreen: false);
                        }
                      }),
                  // 4. Name (Existing)
                  CustomTextField(
                    hintText: LocalStrings.name.tr,
                    controller: controller.nameController,
                    focusNode: controller.nameFocusNode,
                    textInputType: TextInputType.text,
                    nextFocus: controller.companyFocusNode,
                    onChanged: (value) {},
                  ),
                  // 5. Company name (Existing)
                  CustomTextField(
                    hintText: LocalStrings.company.tr,
                    controller: controller.companyController,
                    focusNode: controller.companyFocusNode,
                    textInputType: TextInputType.text,
                    nextFocus: controller.campaignFocusNode,
                    onChanged: (value) {},
                  ),
                  // 6. Company Industry (dropdown) (NEW)
                  FutureBuilder(
                      future:
                          industriesMemoizer.runOnce(controller.loadIndustries),
                      builder: (context, list) {
                        if (list.data?.status ?? false) {
                          return CustomDropDownTextField(
                            hintText: "Company Industry",
                            needLabel: false,
                            onChanged: (value) {
                              controller.companyIndustryController.text =
                                  value.toString();
                            },
                            selectedValue:
                                controller.companyIndustryController.text,
                            items:
                                controller.industriesModel.data!.map((value) {
                              return DropdownMenuItem(
                                value: value.name,
                                child: Text(value.name ?? '',
                                    style: regularDefault.copyWith(
                                        color: Colors.black)),
                              );
                            }).toList(),
                          );
                        } else {
                          return const CustomLoader(isFullScreen: false);
                        }
                      }),
                  // 7. Campaign Name (NEW)
                  CustomTextField(
                    hintText: "Campaign Name",
                    controller: controller.campaignController,
                    focusNode: controller.campaignFocusNode,
                    textInputType: TextInputType.text,
                    onChanged: (value) {},
                  ),
                  // 8. Designation (dropdown) (NEW)
                  FutureBuilder(
                      future: designationsMemoizer
                          .runOnce(controller.loadDesignations),
                      builder: (context, list) {
                        if (list.data?.status ?? false) {
                          return CustomDropDownTextField(
                            hintText: "Designation",
                            needLabel: false,
                            onChanged: (value) {
                              controller.designationController.text =
                                  value.toString();
                            },
                            selectedValue:
                                controller.designationController.text,
                            items:
                                controller.designationsModel.data!.map((value) {
                              return DropdownMenuItem(
                                value: value.id,
                                child: Text(value.name ?? '',
                                    style: regularDefault.copyWith(
                                        color: Colors.black)),
                              );
                            }).toList(),
                          );
                        } else {
                          return const CustomLoader(isFullScreen: false);
                        }
                      }),
                  // 9. Email Address* (Existing)
                  CustomTextField(
                    labelText: LocalStrings.email.tr,
                    isRequired: true,
                    controller: controller.emailController,
                    focusNode: controller.emailFocusNode,
                    textInputType: TextInputType.emailAddress,
                    nextFocus: controller.websiteFocusNode,
                    onChanged: (value) {},
                  ),
                  // 10. Website (Existing)
                  CustomTextField(
                    hintText: LocalStrings.website.tr,
                    controller: controller.websiteController,
                    focusNode: controller.websiteFocusNode,
                    textInputType: TextInputType.url,
                    onChanged: (value) {},
                  ),
                  // 11. Lead value (Existing)
                  CustomAmountTextField(
                    controller: controller.valueController,
                    hintText: LocalStrings.leadValue.tr,
                    currency: '₹',
                    onChanged: (value) {},
                  ),
                  // 12. Zip Code (NEW)
                  CustomTextField(
                    hintText: "Zip Code",
                    controller: controller.zipController,
                    focusNode: controller.zipFocusNode,
                    textInputType: TextInputType.number,
                    nextFocus: controller.addressFocusNode,
                    onChanged: (value) {
                      controller.fetchAddressFromPincode(value);
                    },
                  ),
                  // 13. Address * (Existing)
                  CustomTextField(
                    labelText: LocalStrings.address.tr,
                    isRequired: true,
                    controller: controller.addressController,
                    focusNode: controller.addressFocusNode,
                    textInputType: TextInputType.text,
                    onChanged: (value) {},
                  ),
                  // 14. City (Existing)
                  CustomTextField(
                    hintText: "City",
                    controller: controller.cityController,
                    focusNode: controller.cityFocusNode,
                    textInputType: TextInputType.text,
                    onChanged: (value) {},
                  ),
                  // 15. State (Existing)
                  CustomTextField(
                    hintText: "State",
                    controller: controller.stateController,
                    focusNode: controller.stateFocusNode,
                    textInputType: TextInputType.text,
                    onChanged: (value) {},
                  ),
                  // 16. Country (Existing)
                  CustomTextField(
                    hintText: "Country",
                    controller: controller.countryController,
                    focusNode: controller.countryFocusNode,
                    textInputType: TextInputType.text,
                    onChanged: (value) {},
                  ),
                  // 17. Phone * (Existing)
                  CustomTextField(
                    labelText: LocalStrings.phone.tr,
                    isRequired: true,
                    controller: controller.phoneNumberController,
                    focusNode: controller.phoneNumberFocusNode,
                    textInputType: TextInputType.phone,
                    nextFocus: controller.alternatePhoneNumberFocusNode,
                    onChanged: (value) {},
                  ),
                  // 18. Alternate Phonenumber (NEW)
                  CustomTextField(
                    hintText: "Alternate Phonenumber",
                    controller: controller.alternatePhoneNumberController,
                    focusNode: controller.alternatePhoneNumberFocusNode,
                    textInputType: TextInputType.phone,
                    onChanged: (value) {},
                  ),
                  // 19. Description (Existing)
                  CustomTextField(
                    hintText: "Description",
                    controller: controller.descriptionController,
                    focusNode: controller.descriptionFocusNode,
                    textInputType: TextInputType.multiline,
                    onChanged: (value) {},
                  ),
                  // 20. Interested in (multi-select)
                  FutureBuilder(
                      future: interestedInMemoizer
                          .runOnce(controller.loadInterestedIn),
                      builder: (context, list) {
                        if (list.data?.status ?? false) {
                          return CustomMultiSelectDropDown(
                            hintText: "Interested In",
                            items: controller.interestedInModel.data ?? [],
                            initialSelectedIds:
                                controller.selectedInterestedInIds,
                            onChanged: (List<String> selectedIds) {
                              controller.selectedInterestedInIds = selectedIds;
                            },
                          );
                        } else {
                          return const CustomLoader(isFullScreen: false);
                        }
                      }),
                  const SizedBox(height: Dimensions.space5),
                  controller.isSubmitLoading
                      ? const RoundedLoadingBtn()
                      : RoundedButton(
                          text: LocalStrings.submit.tr,
                          press: () {
                            controller.submitLead();
                          },
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
