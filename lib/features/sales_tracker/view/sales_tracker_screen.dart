import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/features/sales_tracker/controller/sales_tracker_controller.dart';
import 'package:flutex_admin/features/sales_tracker/repo/sales_tracker_repo.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';

class SalesTrackerScreen extends StatefulWidget {
  const SalesTrackerScreen({super.key});

  @override
  State<SalesTrackerScreen> createState() => _SalesTrackerScreenState();
}

class _SalesTrackerScreenState extends State<SalesTrackerScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure dependencies are available
    if (!Get.isRegistered<ApiClient>()) {
      try {
        Get.put(ApiClient(sharedPreferences: Get.find()));
      } catch (e) {
        print("Error finding SharedPreferences: $e");
      }
    }

    // Using SalesTrackerRepo now
    if (!Get.isRegistered<SalesTrackerRepo>()) {
      try {
        Get.put(SalesTrackerRepo(apiClient: Get.find()));
      } catch (e) {
        print("Error finding ApiClient for SalesTrackerRepo: $e");
      }
    }

    Get.put(SalesTrackerController(salesTrackerRepo: Get.find()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Sales Trip Tracker"),
      body: GetBuilder<SalesTrackerController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const CustomLoader();
          }

          if (!controller.isPunchedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_off_outlined,
                      size: 80, color: Colors.orange),
                  const SizedBox(height: 20),
                  const Text(
                    "You are not punched in!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text("Please punch in to use the Sales Trip Tracker."),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      controller.checkAttendanceStatus();
                    },
                    child: const Text("Refresh Status"),
                  )
                ],
              ),
            );
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: controller.currentCenter,
                  initialZoom: 13.0,
                  onMapReady: () => controller.setMapReady(),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.smmart.crm',
                  ),
                  MarkerLayer(
                    markers: controller.markers,
                  ),
                ],
              ),
              Positioned(
                top: 10,
                left: 15,
                right: 15,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: "Search Assigned Leads...",
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            controller
                                .searchLeads(controller.searchController.text);
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        controller.searchLeads(value);
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
