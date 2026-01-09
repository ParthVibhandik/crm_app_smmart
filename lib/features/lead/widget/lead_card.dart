import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/text/text_icon.dart';
import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
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
      child: Card(
        margin: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                left: BorderSide(
                  width: 5.0,
                  color: Converter.hexStringToColor(lead.color ?? ''),
                ),
              ),
            ),
            child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${lead.name}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: regularLarge,
                              ),
                              Text(
                                '${lead.title} - ${lead.company}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: lightSmall.copyWith(
                                    color: ColorResources.blueGreyColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Dimensions.space10),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (lead.phoneNumber != null &&
                                      lead.phoneNumber!.isNotEmpty)
                                    IconButton(
                                      onPressed: () =>
                                          UrlLauncherHelper.call(lead.phoneNumber),
                                      icon: const Icon(Icons.call,
                                          size: 20,
                                          color: ColorResources.primaryColor),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  const SizedBox(width: Dimensions.space10),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 120),
                                    child: Text(
                                      lead.leadValue ?? '-',
                                      style: regularDefault,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 160),
                                child: Text(
                                  lead.sourceName ?? '-',
                                  style: lightSmall,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const CustomDivider(space: Dimensions.space10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextIcon(
                          text: lead.statusName ?? '',
                          icon: Icons.check_circle_outline_rounded,
                          iconColor:
                              Converter.hexStringToColor(lead.color ?? ''),
                        ),
                        TextIcon(
                          text: DateConverter.formatValidityDate(
                              lead.dateAdded ?? ''),
                          icon: Icons.calendar_month,
                        ),
                      ],
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
