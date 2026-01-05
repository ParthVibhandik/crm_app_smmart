import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutter/material.dart';

class CustomLinerProgress extends StatelessWidget {
  const CustomLinerProgress(
      {super.key,
      required this.color,
      required this.value,
      required this.name,
      required this.data});
  final Color color;
  final double value;
  final String name;
  final String data;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Dimensions.space50,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  name,
                  style: regularSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  data,
                  style: regularSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space10),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              minHeight: Dimensions.space8,
              value: value,
              color: color,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}
