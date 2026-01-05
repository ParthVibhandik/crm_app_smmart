import 'package:flutex_admin/core/helper/string_format_helper.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/features/lead/controller/lead_details_controller.dart';
import 'package:flutex_admin/features/lead/model/lead_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttachmentCard extends StatelessWidget {
  const AttachmentCard({
    super.key,
    required this.index,
    required this.attachment,
  });
  final int index;
  final List<Attachments> attachment;

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
      child: ListTile(
        leading: Icon(Converter.fileType(attachment[index].fileType ?? '')),
        title: Text(
          '${attachment[index].fileName}',
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${attachment[index].fileType}',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            fontSize: 12,
            color: ColorResources.blueGreyColor,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download, size: 20),
          onPressed: () => Get.find<LeadDetailsController>()
              .downloadAttachment(attachment[index].fileType ?? '',
                  attachment[index].attachmentKey ?? ''),
        ),
      ),
    );
  }
}
