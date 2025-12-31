import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/features/lead/model/lead_model.dart';
import 'package:flutex_admin/features/sales_tracker/repo/sales_tracker_repo.dart';
import 'package:flutex_admin/features/sales_tracker/model/trip_session.dart';
import 'package:flutex_admin/features/sales_tracker/view/trip_flow_screen.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart' as geo;

class ContinueTripScreen extends StatefulWidget {
  final Lead lead;
  final bool isCustomer;
  const ContinueTripScreen(
      {super.key, required this.lead, this.isCustomer = false});

  @override
  State<ContinueTripScreen> createState() => _ContinueTripScreenState();
}

class _ContinueTripScreenState extends State<ContinueTripScreen> {
  final TextEditingController _manualAddressController =
      TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool isManualAddress = false;
  bool isLoading = false;
  late SalesTrackerRepo _salesTrackerRepo;
  late ApiClient _apiClient;
  final List<String> _transportModes = const [
    'bike',
    'car',
    'bus',
    'train',
    'flight',
    'walk',
    'other',
  ];
  String _modeOfTransport = 'bike';

  @override
  void initState() {
    super.initState();
    _apiClient = Get.find<ApiClient>();
    _salesTrackerRepo = SalesTrackerRepo(apiClient: _apiClient);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(RouteHelper.dashboardScreen);
        return false;
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: "Trip Details"),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.assignment_outlined,
                                size: 24, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              widget.isCustomer
                                  ? "Customer Details"
                                  : "Lead Details",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoCard("Name", widget.lead.name ?? 'Unknown'),
                const SizedBox(height: 10),
                _buildInfoCard("Address", widget.lead.address ?? 'No Address'),
                const SizedBox(height: 10),
                _buildInfoCard("Phone", widget.lead.phoneNumber ?? 'No Phone'),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: isManualAddress,
                      onChanged: (val) {
                        setState(() {
                          isManualAddress = val ?? false;
                        });
                      },
                    ),
                    const Text("Enter Manual Address"),
                  ],
                ),
                if (isManualAddress) ...<Widget>[
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _manualAddressController,
                    labelText: "New Address",
                    hintText: "Enter alternate address",
                    maxLines: 2,
                    onChanged: (val) {},
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _reasonController,
                    labelText: "Reason",
                    hintText: "Why are you changing the address?",
                    maxLines: 2,
                    onChanged: (val) {},
                  ),
                ],
                const SizedBox(height: 24),
                // Mode of Transport Dropdown
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: const <Widget>[
                            Icon(Icons.directions_transit_filled_outlined,
                                size: 24, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text(
                              "Mode of Transport",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _modeOfTransport,
                          items: _transportModes
                              .map((m) => DropdownMenuItem<String>(
                                    value: m,
                                    child: Text(m.toUpperCase()),
                                  ))
                              .toList(),
                          onChanged: isLoading
                              ? null
                              : (val) {
                                  if (val == null) return;
                                  setState(() => _modeOfTransport = val);
                                },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: const <Widget>[
                            Icon(Icons.directions_walk_outlined,
                                size: 24, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              "Trip Actions",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _startTrip,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text("Start Trip"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _startTrip() async {
    // Validation
    if (isManualAddress && _manualAddressController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter the manual address");
      return;
    }
    if (isManualAddress && _reasonController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a reason for changing the address");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition();

      // Determine if it's a lead or customer
      int? leadId;
      int? customerId;

      if (widget.isCustomer) {
        customerId =
            widget.lead.id != null ? int.tryParse(widget.lead.id!) : null;
      } else {
        leadId = widget.lead.id != null ? int.tryParse(widget.lead.id!) : null;
      }

      // Get destination coordinates (from the lead/customer address)
      // For now, using placeholder values - these should be geocoded from the address
      double destinationLat = 22.3039; // Placeholder
      double destinationLng = 70.8022; // Placeholder

      // Get alternate address coordinates if provided
      if (isManualAddress) {
        // TODO: Geocode the manual address to get coordinates
        destinationLat = 22.3105; // Placeholder
        destinationLng = 70.8152; // Placeholder
      }

      // Resolve human-readable start address via reverse geocoding
      String startAddress = await _getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      // Prepare trip data
      String? altAddress =
          isManualAddress ? _manualAddressController.text.trim() : null;
      String? altAddressReason =
          isManualAddress ? _reasonController.text.trim() : null;

      print("Starting trip with:");
      print("  Lead ID: $leadId");
      print("  Customer ID: $customerId");
      print("  Start Location: ${position.latitude}, ${position.longitude}");
      print("  Destination: $destinationLat, $destinationLng");
      print("  Alt Address: $altAddress");
      print("  Alt Reason: $altAddressReason");

      // Call API
      final response = await _salesTrackerRepo.startTrip(
        leadId: leadId,
        customerId: customerId,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        startLat: position.latitude,
        startLng: position.longitude,
        startAddress: startAddress,
        altAddress: altAddress,
        altAddressReason: altAddressReason,
        modeOfTransport: _modeOfTransport,
      );

      if (response.status) {
        // Success
        // Extract trip ID from response and store it
        var responseData = response.responseJson;
        try {
          var decodedData = jsonDecode(responseData);
          if (decodedData['data'] != null &&
              decodedData['data']['id'] != null) {
            String tripId = decodedData['data']['id'].toString();
            // Store trip ID in secure storage
            await TripSession.setActiveTrip(tripId, tripData: responseData);
            print('Trip ID stored: $tripId');
          }
        } catch (e) {
          print('Error storing trip ID: $e');
        }

        CustomSnackBar.success(successList: ["Trip started successfully"]);
        Get.to(() => const TripFlowScreen());
      } else {
        // Error response from API
        CustomSnackBar.error(errorList: [response.message.tr]);
      }
    } catch (e) {
      print("Error starting trip: $e");
      CustomSnackBar.error(errorList: ["Error starting trip: $e"]);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        // Construct a readable address string with available parts
        final parts = <String?>[
          p.name,
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.postalCode,
          p.country,
        ];
        final filtered = parts
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty);
        final address = filtered.join(', ');
        return address.isNotEmpty ? address : 'Current Location';
      }
    } catch (_) {
      // Swallow errors and fallback to placeholder to avoid blocking startTrip
    }
    return 'Current Location';
  }

  // ignore: unused_element
  Future<void> _endTrip() async {
    // TODO: Implement end trip functionality
    // For now, just a placeholder button with snackbar
    CustomSnackBar.success(
        successList: ["End trip functionality coming soon!"]);
  }
}
