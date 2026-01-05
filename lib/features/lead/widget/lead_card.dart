
import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/features/lead/model/lead_model.dart';
import 'package:flutex_admin/core/helper/url_launcher_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadCard extends StatelessWidget {
  const LeadCard({
    super.key,
    required this.lead,
  });
  final Lead lead;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteHelper.leadDetailsScreen, arguments: lead.id!);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), // Add spacing between cards
        decoration: BoxDecoration(
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
                color: Converter.hexStringToColor(lead.color ?? ''),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                   Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         // Main Info
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 '${lead.name}',
                                 overflow: TextOverflow.ellipsis,
                                 maxLines: 1,
                                 style: const TextStyle(
                                   fontWeight: FontWeight.bold,
                                   fontSize: 16,
                                 ),
                               ),
                               const SizedBox(height: 4),
                               Text(
                                 '${lead.title} - ${lead.company}',
                                 overflow: TextOverflow.ellipsis,
                                 maxLines: 1,
                                 style: TextStyle(
                                   color: Theme.of(context).textTheme.bodySmall?.color,
                                   fontSize: 12,
                                 ),
                               ),
                             ],
                           ),
                         ),
                         
                         // Value & Status
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.end,
                           children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Converter.hexStringToColor(lead.color ?? '').withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  lead.statusName ?? '',
                                  style: TextStyle(
                                    color: Converter.hexStringToColor(lead.color ?? ''),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                lead.leadValue ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                           ],
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
                       Row(
                         children: [
                           const Icon(Icons.calendar_today_rounded, size: 14, color: ColorResources.hintColor),
                           const SizedBox(width: 6),
                           Text(
                             DateConverter.formatValidityDate(lead.dateAdded ?? ''),
                             style: const TextStyle(fontSize: 12, color: ColorResources.hintColor),
                           ),
                         ],
                       ),
                       Row(
                         children: [
                            if (lead.phoneNumber != null && lead.phoneNumber!.isNotEmpty)
                              InkWell(
                                onTap: () => UrlLauncherHelper.call(lead.phoneNumber),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: ColorResources.screenBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.call, size: 16, color: ColorResources.primaryColor),
                                ),
                              ),
                            const SizedBox(width: 10),
                            Text(
                              lead.sourceName ?? '-',
                              style: const TextStyle(fontSize: 12, color: ColorResources.hintColor),
                            ),
                         ],
                       ),
                     ],
                   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
