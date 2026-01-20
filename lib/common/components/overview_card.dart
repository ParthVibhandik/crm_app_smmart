import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutter/material.dart';

class OverviewCard extends StatelessWidget {
  const OverviewCard(
      {super.key,
      required this.name,
      required this.number,
      required this.color});
  final String name;
  final String number;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.space100,
      width: 200,
      padding: const EdgeInsets.all(10),
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: mediumExtraLarge.copyWith(color: color),
          ),
          const SizedBox(height: Dimensions.space5),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.fade,
            softWrap: true,
            style: regularSmall.copyWith(
                color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
        ],
      ),
    );
  }
}
