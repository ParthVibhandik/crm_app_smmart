import 'package:flutex_admin/common/components/glass_container.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.currentValue,
    required this.totalValue,
    required this.percent,
    required this.icon,
    required this.title,
  });

  final String currentValue;
  final String totalValue;
  final String percent;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GlassContainer(
        opacity: isDark ? 0.1 : 0.8,
        blur: 10,
        margin: const EdgeInsets.all(Dimensions.space5),
        padding: const EdgeInsets.all(Dimensions.space20),
        borderRadius: BorderRadius.circular(Dimensions.cardRadius),
        color: isDark ? ColorResources.glassBlack : Colors.white,
        child: SizedBox(
          height: 140, // GlassContainer wraps child, but we want Fixed Height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).primaryColor,
                    backgroundColor: isDark ? Colors.white12 : ColorResources.colorLightGrey,
                    value: double.parse(percent) / 100,
                  ),
                  Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.space5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currentValue.toString(), style: regularOverLarge.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                  )),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: Dimensions.space5),
                    child: Text(
                      LocalStrings.of.tr,
                      style: regularDefault.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                  Text(
                    totalValue.toString(),
                    style: regularDefault.copyWith(
                        color: ColorResources.colorlighterGrey),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.space5),
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style:
                    lightSmall.copyWith(color: ColorResources.colorlighterGrey),
              )
            ],
          ),
        ),
      ),
    );
  }
}
