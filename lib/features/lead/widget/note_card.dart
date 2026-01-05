import 'package:flutex_admin/common/components/circle_image_button.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/lead/model/notes_model.dart';
import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.index,
    required this.note,
  });
  final int index;
  final List<Note> note;

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
              children: [
                Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(
                          width: .3, color: Theme.of(context).primaryColor)),
                  child: CircleImageWidget(
                    isProfile: true,
                    imagePath: note[index].profileImage ?? '',
                    height: 35,
                    width: 35,
                    isAsset: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${note[index].firstName} ${note[index].lastName}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${LocalStrings.date}: ${note[index].dateAdded}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium!.color),
                      ),
                    ],
                  ),
                ),
                if (note[index].dateContacted != null)
                  Tooltip(
                    message: note[index].dateContacted,
                    child: const Icon(
                      Icons.call,
                      color: ColorResources.colorGreen,
                    ),
                  ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Text(
              '${note[index].description}',
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium!.color),
            ),
          ],
        ),
      ),
    );
  }
}
