import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/dcr/controller/dcr_controller.dart';
import 'package:flutex_admin/features/dcr/repo/dcr_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DCRScreen extends StatefulWidget {
  const DCRScreen({super.key});

  @override
  State<DCRScreen> createState() => _DCRScreenState();
}

class _DCRScreenState extends State<DCRScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(DCRRepo(apiClient: Get.find()));
    Get.put(DCRController(dcrRepo: Get.find()));
  }

  String formatTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return "--:--";
    try {
      DateTime dt = DateTime.parse(dateTimeStr);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        appBar: const CustomAppBar(
          title: "Daily Call Report",
          isShowBackBtn: false,
        ),
        body: GetBuilder<DCRController>(
          builder: (controller) {
            if (controller.isLoading) {
              return const CustomLoader();
            }

            if (controller.dcrList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey),
                    const SizedBox(height: Dimensions.space20),
                    Text(
                      "No calls recorded today.",
                      style: regularLarge.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: Dimensions.space30),
                    ElevatedButton(
                      onPressed: () => Get.offAllNamed(RouteHelper.loginScreen),
                      child: const Text("Exit Application"),
                    )
                  ],
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space10),
                  margin: const EdgeInsets.all(Dimensions.space15),
                  decoration: BoxDecoration(
                    color: ColorResources.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorResources.primaryColor.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem("Total", controller.totalCalls.toString(), Icons.call),
                      _summaryItem("F2F", controller.f2fCalls.toString(), Icons.people),
                      _summaryItem("Tele", controller.telecallCount.toString(), Icons.phone_android),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                    itemCount: controller.dcrList.length,
                    itemBuilder: (context, index) {
                      final item = controller.dcrList[index];
                      String leadName = (item.leadName == null || item.leadName!.trim().isEmpty) ? 'Unknown Lead' : item.leadName!;
                      return Card(
                        margin: const EdgeInsets.only(bottom: Dimensions.space15),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.space15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      leadName,
                                      style: boldDefault.copyWith(fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (item.type?.toLowerCase() == 'f2f') 
                                          ? Colors.blue.withOpacity(0.1) 
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.type?.toUpperCase() ?? 'N/A',
                                      style: boldDefault.copyWith(
                                        fontSize: 10,
                                        color: (item.type?.toLowerCase() == 'f2f') ? Colors.blue : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: Dimensions.space10),
                              const Divider(),
                              const SizedBox(height: Dimensions.space5),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${formatTime(item.callStart)}  •  ${item.duration} mins",
                                    style: regularDefault.copyWith(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: Dimensions.space10),
                              Row(
                                children: [
                                  _statusBadge(item.prevStatus ?? 'N/A', "Previous"),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                                  ),
                                  _statusBadge(item.currentStatus ?? 'N/A', "Current", isCurrent: true),
                                ],
                              ),
                              if (item.remarks != null && item.remarks!.isNotEmpty) ...[
                                const SizedBox(height: Dimensions.space15),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(Dimensions.space10),
                                  decoration: BoxDecoration(
                                    color: ColorResources.colorGrey.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Remarks:", style: boldDefault.copyWith(fontSize: 12, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Text(item.remarks!, style: regularDefault.copyWith(fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(Dimensions.space20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorResources.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Get.offAllNamed(RouteHelper.loginScreen);
                      },
                      child: const Text("Finish Day & Logout"),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _statusBadge(String status, String label, {bool isCurrent = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: regularDefault.copyWith(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: isCurrent ? ColorResources.primaryColor : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status.capitalizeFirst!,
            style: regularDefault.copyWith(
              fontSize: 11,
              color: isCurrent ? ColorResources.primaryColor : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: ColorResources.primaryColor),
        const SizedBox(height: 4),
        Text(value, style: boldDefault.copyWith(fontSize: 14)),
        Text(label, style: regularDefault.copyWith(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
