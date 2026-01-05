import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutex_admin/features/dashboard/widget/custom_linerprogress.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeProposalsCard extends StatelessWidget {
  const HomeProposalsCard({
    super.key,
    required this.proposals,
  });
  final List<DataField>? proposals;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Get.toNamed(RouteHelper.proposalScreen),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.document_scanner_outlined, size: 20, color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${LocalStrings.proposals.tr} ${LocalStrings.overview.tr}',
                        style: const TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Theme.of(context).hintColor),
                ],
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            
            Expanded(
              child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return CustomLinerProgress(
                      name: proposals![index].status?.tr ?? '',
                      color: ColorResources.proposalTextStatusColor(
                          proposals![index].status.toString()),
                      value: double.parse(proposals![index].percent!) / 100,
                      data: proposals![index].total.toString(),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: proposals!.length),
            ),
          ],
        ),
      ),
    );
  }
}
