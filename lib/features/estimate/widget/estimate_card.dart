import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/text/text_icon.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/features/estimate/model/estimate_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EstimateCard extends StatelessWidget {
  const EstimateCard({
    super.key,
    required this.index,
    required this.estimateModel,
  });
  final int index;
  final EstimatesModel estimateModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteHelper.estimateDetailsScreen,
            arguments: estimateModel.data![index].id!);
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
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.cardRadius),
            border: Border(
              left: BorderSide(
                width: 5.0,
                color: ColorResources.estimateStatusColor(
                    estimateModel.data![index].status ?? ''),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        estimateModel.data![index].formattedNumber ??
                            '${estimateModel.data![index].prefix ?? ''}${estimateModel.data![index].number ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${estimateModel.data![index].currencySymbol}${estimateModel.data![index].total}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                    ),
                  ],
                ),
                 const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                     Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: ColorResources.estimateStatusColor(
                                estimateModel.data![index].status ?? '')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        Converter.estimateStatusString(
                            estimateModel.data![index].status ?? '1'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ColorResources.estimateStatusColor(
                              estimateModel.data![index].status ?? ''),
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Expanded(
                       child: Row(
                        children: [
                           Icon(Icons.business,
                              size: 16, color: Theme.of(context).hintColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              estimateModel.data![index].clientName ?? '',
                               style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).hintColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                                           ),
                     ),
                     const SizedBox(width: 8), // Add some spacing between name and date
                     Row(
                      children: [
                         Icon(Icons.calendar_today,
                            size: 14, color: Theme.of(context).hintColor),
                        const SizedBox(width: 6),
                        Text(
                          estimateModel.data![index].expiryDate ?? '',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
