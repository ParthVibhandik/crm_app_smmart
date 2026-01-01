import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/card/custom_card.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/common/components/dialog/warning_dialog.dart';
import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/common/components/table_item.dart';
import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/images.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/proposal/controller/proposal_controller.dart';
import 'package:flutex_admin/features/proposal/repo/proposal_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProposalDetailsScreen extends StatefulWidget {
  const ProposalDetailsScreen({super.key, required this.id});
  final String id;

  @override
  State<ProposalDetailsScreen> createState() => _ProposalDetailsScreenState();
}

class _ProposalDetailsScreenState extends State<ProposalDetailsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProposalRepo(apiClient: Get.find()));
    final controller = Get.put(ProposalController(proposalRepo: Get.find()));
    controller.isLoading = true;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProposalDetails(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: LocalStrings.proposalDetails.tr,
        isShowActionBtn: true,
        isShowActionBtnTwo: true,
        actionWidget: IconButton(
          onPressed: () {
            Get.toNamed(
              RouteHelper.updateProposalScreen,
              arguments: widget.id,
            );
          },
          icon: const Icon(Icons.edit, size: 20),
        ),
        actionWidgetTwo: IconButton(
          onPressed: () {
            const WarningAlertDialog().warningAlertDialog(
              context,
              () {
                Get.back();
                Get.find<ProposalController>().deleteProposal(widget.id);
                Navigator.pop(context);
              },
              title: LocalStrings.deleteProposal.tr,
              subTitle: LocalStrings.deleteProposalWarningMSg.tr,
              image: MyImages.exclamationImage,
            );
          },
          icon: const Icon(Icons.delete, size: 20),
        ),
      ),
      body: GetBuilder<ProposalController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const CustomLoader();
          }

          final data = controller.proposalDetailsModel.data!;

          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).cardColor,
            onRefresh: () async {
              await controller.loadProposalDetails(widget.id);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.space15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ---------------- HEADER ----------------
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.subject ?? '',
                            style: mediumLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          Converter.proposalStatusString(data.status ?? ''),
                          style: lightDefault.copyWith(
                            color: ColorResources.proposalStatusColor(
                              data.status ?? '',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: Dimensions.space10),

                    /// ---------------- COMPANY CARD ----------------
                    CustomCard(
                      child: Column(
                        children: [
                          _labelRow(
                            LocalStrings.company.tr,
                            LocalStrings.email.tr,
                          ),
                          _valueRow(
                            data.proposalTo ?? '',
                            data.email ?? '-',
                          ),
                          const CustomDivider(space: Dimensions.space10),
                          _labelRow(
                            LocalStrings.date.tr,
                            LocalStrings.openTill.tr,
                          ),
                          _valueRow(
                            data.date ?? '',
                            data.openTill ?? '-',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: Dimensions.space10),

                    /// ---------------- ITEMS ----------------
                    Text(
                      LocalStrings.items.tr,
                      style: mediumLarge.copyWith(
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),

                    const SizedBox(height: Dimensions.space10),

                    CustomCard(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.space5,
                        ),
                        itemBuilder: (context, index) {
                          return TableItem(
                            item: data.items![index],
                            currency: data.symbol,
                          );
                        },
                        separatorBuilder: (_, __) =>
                            const CustomDivider(space: Dimensions.space10),
                        itemCount: data.items!.length,
                      ),
                    ),

                    const SizedBox(height: Dimensions.space10),

                    /// ---------------- TOTALS ----------------
                    CustomCard(
                      child: Column(
                        spacing: Dimensions.space10,
                        children: [
                          _amountRow(
                            LocalStrings.subtotal.tr,
                            '${data.symbol ?? ''}${data.subtotal ?? ''}',
                          ),
                          _amountRow(
                            LocalStrings.discount.tr,
                            data.discountTotal ?? '',
                          ),
                          _amountRow(
                            LocalStrings.tax.tr,
                            data.totalTax ?? '',
                          ),
                          _amountRow(
                            LocalStrings.total.tr,
                            '${data.symbol ?? ''}${data.total ?? ''}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ---------------- HELPERS ----------------

  Widget _labelRow(String left, String right) {
    return Row(
      children: [
        Expanded(child: Text(left, style: lightSmall)),
        Expanded(
          child: Text(
            right,
            style: lightSmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _valueRow(String left, String right) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: regularDefault,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            right,
            style: regularDefault,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _amountRow(String label, String value, {bool isBold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: isBold ? regularLarge : lightDefault,
          ),
        ),
        Text(
          value,
          style: isBold ? mediumLarge : regularDefault,
        ),
      ],
    );
  }
}
