import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/features/lead/model/lead_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoardCard extends StatelessWidget {
  final Lead lead;

  const BoardCard({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteHelper.leadDetailsScreen, arguments: lead.id!);
      },
      child: Container(
        margin: const EdgeInsets.only(
            top: Dimensions.space8,
            right: Dimensions.space5,
            left: Dimensions.space5),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${lead.name}',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${lead.title} - ${lead.company}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  color: ColorResources.blueGreyColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lead.leadValue ?? '-',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    lead.sourceName ?? '-',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                   Icon(Icons.calendar_month,
                      size: 14, color: Theme.of(context).hintColor),
                   const SizedBox(width: 6),
                   Text(
                     DateConverter.formatValidityDate(lead.dateAdded ?? ''),
                     style: TextStyle(
                       fontSize: 12,
                       color: Theme.of(context).hintColor,
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
