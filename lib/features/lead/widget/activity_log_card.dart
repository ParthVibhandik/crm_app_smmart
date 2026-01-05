import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/lead/model/activity_log_model.dart';
import 'package:flutter/material.dart';

class ActivityLogCard extends StatelessWidget {
  const ActivityLogCard({
    super.key,
    required this.index,
    required this.activityLog,
  });
  final int index;
  final List<ActivityLog> activityLog;

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
            Text(
              '${LocalStrings.date}: ${activityLog[index].date}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Text(
              activityLog[index].staffId != '0'
                  ? '${activityLog[index].fullName} - ${Converter.parseHtmlString(activityLog[index].additionalData ?? '')}'
                  : Converter.parseHtmlString(
                      activityLog[index].additionalData ?? ''),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
