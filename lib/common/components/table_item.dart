import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/common/models/items_model.dart';
import 'package:flutter/material.dart';

class TableItem extends StatelessWidget {
  const TableItem({super.key, required this.item, this.currency});

  final Item item;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    final double rate = double.tryParse(item.rate ?? '0') ?? 0;
    final double qty = double.tryParse(item.qty ?? '0') ?? 0;
    final double total = rate * qty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ---------------- LEFT SIDE (DESCRIPTION + RATE) ----------------
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.description ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: regularDefault,
              ),
              const SizedBox(height: Dimensions.space5),
              Text(
                '${currency ?? ''}${item.rate} × ${item.qty?.replaceAll('.00', '')} ${item.unit ?? ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: regularDefault.copyWith(
                  color: ColorResources.blueGreyColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: Dimensions.space10),

        /// ---------------- RIGHT SIDE (TOTAL PRICE) ----------------
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Text(
            '${currency ?? ''}${total.toStringAsFixed(2)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: regularLarge,
          ),
        ),
      ],
    );
  }
}
