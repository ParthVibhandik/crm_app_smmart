import 'package:flutex_admin/common/components/divider/custom_divider.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutex_admin/features/dashboard/widget/custom_linerprogress.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeInvoicesCard extends StatelessWidget {
  const HomeInvoicesCard({
    super.key,
    required this.invoices,
  });
  final List<DataField>? invoices;

  @override
  Widget build(BuildContext context) {
    // Use a safe local list to avoid null issues when invoices is absent
    final data = invoices ?? const <DataField>[];

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space5, vertical: Dimensions.space5),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.space15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.cardRadius),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              label: Text(
                '${LocalStrings.invoices.tr} ${LocalStrings.overview.tr}',
                style: regularLarge.copyWith(
                    color: Theme.of(context).primaryColor),
              ),
              icon: Icon(Icons.assignment_outlined,
                  size: 20, color: Theme.of(context).primaryColor),
              onPressed: () {},
            ),
            const CustomDivider(space: Dimensions.space5),
            const SizedBox(height: Dimensions.space15),
            ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final invoice = data[index];
                  final percentValue =
                      (double.tryParse(invoice.percent ?? '0') ?? 0) / 100;

                  return CustomLinerProgress(
                    name: invoice.status?.tr ?? '',
                    color: ColorResources.invoiceTextStatusColor(
                        invoice.status?.toString() ?? ''),
                    value: percentValue,
                    data: invoice.total?.toString() ?? '0',
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: Dimensions.space2),
                itemCount: data.length),
          ],
        ),
      ),
    );
  }
}
