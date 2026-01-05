import 'package:flutex_admin/common/components/circle_image_button.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/staff/model/staff_model.dart';
import 'package:flutex_admin/core/helper/url_launcher_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffsCard extends StatelessWidget {
  const StaffsCard({super.key, required this.staffModel});
  final Staff staffModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteHelper.staffDetailsScreen, arguments: staffModel.id!);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: ColorResources.blueGreyColor,
                radius: 24,
                child: CircleImageWidget(
                  imagePath: staffModel.profileImage ?? '',
                  isAsset: false,
                  isProfile: true,
                  width: 48,
                  height: 48,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${staffModel.firstName ?? ''} ${staffModel.lastName ?? ''}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => UrlLauncherHelper.mail(staffModel.email),
                      child: Text(
                        staffModel.email ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorResources.blueColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (staffModel.phoneNumber != null &&
                      staffModel.phoneNumber!.isNotEmpty)
                    InkWell(
                      onTap: () =>
                          UrlLauncherHelper.call(staffModel.phoneNumber),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Icon(Icons.call,
                            size: 20, color: ColorResources.primaryColor),
                      ),
                    ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          (staffModel.active == '1' ? ColorResources.greenColor : ColorResources.blueGreyColor)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      staffModel.active == '1'
                          ? LocalStrings.active.tr
                          : LocalStrings.disabled.tr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: staffModel.active == '1'
                            ? ColorResources.greenColor
                            : ColorResources.blueGreyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
