import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/text/text_icon.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
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
    final proposal = proposalModel.data![index];

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          RouteHelper.proposalDetailsScreen,
          arguments: proposal.id!,
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              left: BorderSide(
                width: 5,
                color: ColorResources.proposalStatusColor(proposal.status!),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.space15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// -------------------- TOP ROW --------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// LEFT (TITLE)
                    Expanded(
                      child: Text(
                        proposal.subject ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),

                    const SizedBox(width: Dimensions.space10),

                    /// RIGHT (AMOUNT + STATUS)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            '${proposal.total} ${proposal.currencyName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: Dimensions.space5),
                        Text(
                          Converter.proposalStatusString(proposal.status ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: lightDefault.copyWith(
                            color: ColorResources.proposalStatusColor(
                                proposal.status!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const CustomDivider(space: Dimensions.space8),

                /// -------------------- BOTTOM ROW --------------------
                Row(
                  children: [
                    Expanded(
                      child: TextIcon(
                        text: proposal.proposalTo ?? '',
                        icon: Icons.account_box_rounded,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: Dimensions.space10),
                    TextIcon(
                      text: proposal.date ?? '',
                      icon: Icons.calendar_month,
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
