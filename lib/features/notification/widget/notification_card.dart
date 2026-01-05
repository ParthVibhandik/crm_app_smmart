import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/features/notification/model/notifications_model.dart';
import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
  });
  final Notifications notification;

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
              if (notification.fromFullName?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    notification.fromFullName ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                notification.formattedDescription ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Icon(Icons.calendar_month_outlined,
                      size: 14, color: Theme.of(context).hintColor),
                  const SizedBox(width: 6),
                  Text(
                    notification.date ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                    ),
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
