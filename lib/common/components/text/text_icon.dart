import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/style.dart';

class TextIcon extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final double space;
  final MainAxisAlignment alignment;
  final int maxLines;

  const TextIcon({
    super.key,
    required this.text,
    this.textStyle,
    required this.icon,
    this.iconColor = ColorResources.secondaryColor,
    this.iconSize = 14,
    this.space = Dimensions.space5,
    this.alignment = MainAxisAlignment.start,
    this.maxLines = 1, // 👈 default single line
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
        SizedBox(width: space),
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            text.tr,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: textStyle ??
                lightDefault.copyWith(
                  color: ColorResources.blueGreyColor,
                ),
          ),
        ),
      ],
    );
  }
}
