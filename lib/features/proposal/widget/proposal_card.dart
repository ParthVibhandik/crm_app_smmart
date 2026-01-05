import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/text/text_icon.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/features/proposal/model/proposal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProposalCard extends StatelessWidget {
  const ProposalCard({
    super.key,
    required this.index,
    required this.proposalModel,
  });
  final int index;
  final ProposalsModel proposalModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteHelper.proposalDetailsScreen,
            arguments: proposalModel.data![index].id!);
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
                color: ColorResources.proposalStatusColor(
                    proposalModel.data![index].status!),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                 Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        proposalModel.data![index].subject ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.space10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${proposalModel.data![index].total} ${proposalModel.data![index].currencyName}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ColorResources.proposalStatusColor(
                                    proposalModel.data![index].status!)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            Converter.proposalStatusString(
                                proposalModel.data![index].status ?? ''),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: ColorResources.proposalStatusColor(
                                  proposalModel.data![index].status!),
                            ),
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
                     Expanded(
                       child: Row(
                        children: [
                           Icon(Icons.business,
                              size: 16, color: Theme.of(context).hintColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              proposalModel.data![index].proposalTo ?? '',
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
                     const SizedBox(width: 8),
                     Row(
                      children: [
                         Icon(Icons.calendar_today,
                            size: 14, color: Theme.of(context).hintColor),
                        const SizedBox(width: 6),
                        Text(
                          proposalModel.data![index].date ?? '',
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
