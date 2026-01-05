import 'package:flutex_admin/common/components/circle_avatar_with_letter.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/customer/model/customer_model.dart';
import 'package:flutex_admin/core/helper/url_launcher_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomersCard extends StatelessWidget {
  const CustomersCard({
    super.key,
    required this.index,
    required this.customerModel,
  });
  final int index;
  final CustomersModel customerModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteHelper.customerDetailsScreen,
            arguments: customerModel.data![index].userId!);
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
              CircleAvatarWithInitialLetter(
                initialLetter: customerModel.data![index].company ?? '',
                radius: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerModel.data![index].company ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => UrlLauncherHelper.call(
                          customerModel.data![index].phoneNumber),
                      child: Row(
                        children: [
                          Icon(Icons.phone_rounded,
                              size: 14, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              customerModel.data![index].phoneNumber ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (customerModel.data![index].active == '1'
                          ? ColorResources.greenColor
                          : ColorResources.redColor)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  customerModel.data![index].active == '1'
                      ? LocalStrings.active.tr
                      : LocalStrings.notActive.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: customerModel.data![index].active == '1'
                        ? ColorResources.greenColor
                        : ColorResources.redColor,
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
