import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/invoice/model/invoice_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoicePaymentCard extends StatelessWidget {
  const InvoicePaymentCard({
    super.key,
    required this.payment,
    required this.currency,
  });
  final Payments payment;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${LocalStrings.payment.tr} #${payment.paymentId ?? ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$currency${payment.amount ?? ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            if (payment.transactionId?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              Text(
                '${LocalStrings.transactionId.tr}: ${payment.transactionId ?? ''}',
                style: TextStyle(
                  fontSize: 13,
                  color: ColorResources.blueGreyColor,
                ),
              ),
            ],
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
                      Icon(Icons.payments_outlined,
                          size: 16, color: Theme.of(context).hintColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          payment.methodName ?? '',
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
                    Icon(Icons.calendar_month,
                        size: 14, color: Theme.of(context).hintColor),
                    const SizedBox(width: 6),
                    Text(
                      payment.date ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
