import 'package:flutex_admin/common/components/circle_image_button.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/features/customer/model/contact_model.dart';
import 'package:flutex_admin/core/helper/url_launcher_helper.dart';
import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.index,
    required this.contactModel,
  });
  final int index;
  final ContactsModel contactModel;

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
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: ColorResources.blueGreyColor,
              radius: 24,
              child: CircleImageWidget(
                imagePath: contactModel.data![index].profileImage ?? '',
                isAsset: false,
                isProfile: true,
                width: 48,
                height: 48,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${contactModel.data![index].firstName} ${contactModel.data![index].lastName}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () =>
                        UrlLauncherHelper.mail(contactModel.data![index].email),
                    child: Text(
                      '${contactModel.data![index].email}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: ColorResources.blueColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => UrlLauncherHelper.call(
                        contactModel.data![index].phoneNumber),
                    child: Text(
                      '${contactModel.data![index].phoneNumber}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              activeThumbColor: Colors.white,
              activeTrackColor: Theme.of(context).primaryColor,
              onChanged: (value) {},
              value: true,
            ),
          ],
        ),
      ),
    );
  }
}
