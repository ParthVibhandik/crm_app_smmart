import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/text/text_icon.dart';
import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/lead/model/lead_details_model.dart';
import 'package:flutex_admin/core/helper/url_launcher_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadProfile extends StatelessWidget {
  const LeadProfile({
    super.key,
    required this.leadModel,
  });
  final LeadDetails leadModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.space10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.space15),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.cardRadius),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width / 1.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${leadModel.name}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            '${leadModel.title}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: lightSmall.copyWith(
                                color: ColorResources.blueGreyColor),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          leadModel.leadValue ?? '-',
                          style: regularDefault,
                        ),
                        Text(
                          leadModel.sourceName ?? '-',
                          style: lightSmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const CustomDivider(space: Dimensions.space10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextIcon(
                      text: leadModel.statusName ?? '',
                      icon: Icons.check_circle_outline_rounded,
                      iconColor:
                          Converter.hexStringToColor(leadModel.color ?? ''),
                    ),
                    TextIcon(
                      text: DateConverter.formatValidityDate(
                          leadModel.dateAdded ?? ''),
                      icon: Icons.calendar_month,
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: Dimensions.space20),
          Container(
            padding: const EdgeInsets.all(Dimensions.space15),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.cardRadius),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LocalStrings.company.tr, style: lightDefault),
                    Text(LocalStrings.vatNumber.tr, style: lightDefault),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(leadModel.company ?? ''),
                    Text(leadModel.vat ?? '-'),
                  ],
                ),
                const SizedBox(height: Dimensions.space10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Company Industry", style: lightDefault),
                    Text("Interested Product", style: lightDefault),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(leadModel.companyIndustry ?? '-'),
                    Text(leadModel.interestedIn ?? '-'),
                  ],
                ),
                const CustomDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LocalStrings.phone.tr, style: lightDefault),
                    Text("Alt Phone", style: lightDefault),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            UrlLauncherHelper.call(leadModel.phoneNumber),
                        child: Text(
                          leadModel.phoneNumber ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: regularDefault.copyWith(
                              color: ColorResources.primaryColor,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.space10),
                    Expanded(
                      child: InkWell(
                        onTap: () => UrlLauncherHelper.call(
                            leadModel.alternatePhoneNumber),
                        child: Text(
                          leadModel.alternatePhoneNumber ?? '-',
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                           style: regularDefault.copyWith(
                              color: ColorResources.primaryColor,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.space10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LocalStrings.email.tr, style: lightDefault),
                    Text(LocalStrings.website.tr, style: lightDefault),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            UrlLauncherHelper.mail(leadModel.email),
                        child: Text(
                          leadModel.email ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: regularDefault.copyWith(
                              color: ColorResources.primaryColor,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.space10),
                    Expanded(
                      child: Text(
                        leadModel.website ?? '-',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.space20),
          Container(
            padding: const EdgeInsets.all(Dimensions.space15),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.cardRadius),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(LocalStrings.address.tr),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(leadModel.address ?? '-'),
                      ],
                    ),
                  ],
                ),
                const CustomDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LocalStrings.city.tr),
                    Text(LocalStrings.state.tr),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(leadModel.city ?? '-'),
                    Text(leadModel.state ?? '-'),
                  ],
                ),
                const CustomDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LocalStrings.zipCode.tr),
                    Text(LocalStrings.country.tr),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(leadModel.zip ?? '-'),
                    Text(leadModel.country ?? '-'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
