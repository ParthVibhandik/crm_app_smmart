import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/spanco/suspecting/controller/suspecting_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuspectingListScreen extends StatelessWidget {
  const SuspectingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SuspectingController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Suspecting Items',
                style: regularLarge.copyWith(color: Colors.white)),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          body: controller.isLoading
              ? const CustomLoader()
              : controller.list.isEmpty
                  ? Center(
                      child: Text(
                        'No items found',
                        style: regularDefault.copyWith(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(Dimensions.space15),
                      itemCount: controller.list.length,
                      itemBuilder: (context, index) {
                        final item = controller.list[index];
                        return InkWell(
                          onTap: () {
                            if (item.opportunityId != null) {
                              controller.onItemTap(item.opportunityId!);
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.only(
                                bottom: Dimensions.space10),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.space15,
                                  vertical: Dimensions.space10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.1),
                                    child: Text(
                                      item.name != null && item.name!.isNotEmpty
                                          ? item.name![0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.space15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name ?? 'Unknown',
                                          style: semiBoldLarge,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        if (item.company != null &&
                                            item.company!.isNotEmpty)
                                          Text(item.company!,
                                              style: regularSmall.copyWith(
                                                  color: Colors.grey[700]),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                        if (item.company == null ||
                                            item.company!.isEmpty)
                                          Text(item.email ?? '',
                                              style: regularSmall.copyWith(
                                                  color: Colors.grey[700]),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.space10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(item.source ?? '-',
                                        style: regularSmall.copyWith(
                                            color: Colors.blue[700],
                                            fontSize: 10)),
                                  ),
                                  const SizedBox(width: Dimensions.space10),
                                  Icon(Icons.arrow_forward_ios_rounded,
                                      size: 14, color: Colors.grey[400])
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
