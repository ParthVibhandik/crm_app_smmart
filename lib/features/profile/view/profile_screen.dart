import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/circle_image_button.dart';
import 'package:flutex_admin/common/components/column_widget/card_column.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/image/circle_shape_image.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/profile/controller/profile_controller.dart';
import 'package:flutex_admin/features/profile/repo/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/helper/url_launcher_helper.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    final controller = Get.put(ProfileController(profileRepo: Get.find()));
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: LocalStrings.profile.tr,
          isShowActionBtn: true,
          actionWidget: IconButton(
            onPressed: () => Get.toNamed(RouteHelper.editProfileScreen),
            icon: const Icon(Icons.edit),
          ),
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : Stack(
                children: [
                  Positioned(
                    top: -10,
                    child: Container(
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      color: Theme.of(context).appBarTheme.backgroundColor!,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: Dimensions.space15,
                        right: Dimensions.space15,
                        top: Dimensions.space20,
                        bottom: Dimensions.space20,
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.space15,
                          horizontal: Dimensions.space30,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                    border: Border.all(
                                      width: .3,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  child: CircleImageWidget(
                                    isProfile: true,
                                    imagePath: controller
                                            .profileModel.data?.profileImage ??
                                        '',
                                    height: 90,
                                    width: 90,
                                    isAsset: false,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    '${controller.profileModel.data?.firstName ?? ''} ${controller.profileModel.data?.lastName ?? ''}',
                                    style: regularExtraLarge.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.color,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.space20),
                            Row(
                              children: [
                                CircleShapeImage(
                                  imageColor: Theme.of(
                                    context,
                                  ).appBarTheme.backgroundColor,
                                  image: MyImages.email,
                                ),
                                const SizedBox(width: Dimensions.space15),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => UrlLauncherHelper.mail(
                                        controller.profileModel.data?.email),
                                    child: CardColumn(
                                      header: LocalStrings.email.tr,
                                      body:
                                          controller.profileModel.data?.email ??
                                              '',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const CustomDivider(space: Dimensions.space15),
                            Row(
                              children: [
                                CircleShapeImage(
                                  imageColor: Theme.of(
                                    context,
                                  ).appBarTheme.backgroundColor,
                                  image: MyImages.phone,
                                ),
                                const SizedBox(width: Dimensions.space15),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => UrlLauncherHelper.call(
                                        controller
                                            .profileModel.data?.phoneNumber),
                                    child: CardColumn(
                                      header: LocalStrings.phone.tr,
                                      body: controller
                                              .profileModel.data?.phoneNumber ??
                                          '',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
