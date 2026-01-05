import 'package:flutex_admin/core/helper/date_converter.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/project/model/project_discussions_model.dart';
import 'package:flutter/material.dart';

class DiscussionCard extends StatelessWidget {
  const DiscussionCard({super.key, required this.discussion});
  final Discussion discussion;

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
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    discussion.subject ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: Dimensions.space10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Icon(
                      discussion.showToCustomer == '1'
                        ? Icons.visibility
                        : Icons.visibility_off,
                      size: 14,
                      color: discussion.showToCustomer == '1'
                        ? Colors.green
                        : Colors.red,
                     ),
                    const SizedBox(width: 6),
                    Text(
                      discussion.showToCustomer == '1'
                          ? LocalStrings.visible
                          : LocalStrings.notVisible,
                      style: TextStyle(
                        fontSize: 12,
                        color: discussion.showToCustomer == '1'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
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
                    Icon(Icons.comment,
                        size: 16, color: Theme.of(context).hintColor),
                    const SizedBox(width: 6),
                    Text(
                      '${LocalStrings.totalComments}: ${discussion.totalComments}',
                       style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
                 Row(
                   children: [
                     Icon(Icons.calendar_today,
                        size: 14, color: Theme.of(context).hintColor),
                     const SizedBox(width: 6),
                     Text(
                      DateConverter.formatValidityDate(
                        discussion.lastActivity ?? '',
                      ),
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
