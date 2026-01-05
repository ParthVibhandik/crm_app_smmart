import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/lead/model/reminders_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminder,
  });
  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Mark as read
      },
      child: Container(
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
                reminder.description ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(fontSize: 14),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Row(
                    children: [
                      Icon(Icons.calendar_month_outlined,
                          size: 14, color: Theme.of(context).hintColor),
                      const SizedBox(width: 6),
                      Text(
                        reminder.date ?? '',
                        style: TextStyle(
                            fontSize: 12, color: Theme.of(context).hintColor),
                      ),
                    ],
                   ),
                   Row(
                    children: [
                      Icon(
                        (reminder.isNotified == '0')
                          ? Icons.not_interested_outlined
                          : Icons.done,
                        size: 14, 
                        color: Theme.of(context).hintColor
                      ),
                      const SizedBox(width: 6),
                      Text(
                        (reminder.isNotified == '0')
                            ? LocalStrings.notNotified.tr
                            : LocalStrings.notified.tr,
                        style: TextStyle(
                            fontSize: 12, color: Theme.of(context).hintColor),
                      ),
                    ],
                   ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
