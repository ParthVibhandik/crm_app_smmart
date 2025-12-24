import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/features/attendance/attendance_service.dart';
import 'package:flutex_admin/features/attendance/attendance_status.dart';
import 'package:flutex_admin/features/lead/model/lead_model.dart';
import 'package:flutex_admin/features/sales_tracker/repo/sales_tracker_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

import 'package:flutex_admin/features/sales_tracker/view/continue_trip_screen.dart';

class SalesTrackerController extends GetxController {
  final SalesTrackerRepo salesTrackerRepo;
  SalesTrackerController({required this.salesTrackerRepo});

  bool isLoading = true;
  bool isPunchedIn = false;
  List<Lead> leads = [];
  List<Marker> markers = [];
  TextEditingController searchController = TextEditingController();
  final MapController mapController = MapController();
  LatLng currentCenter = const LatLng(20.5937, 78.9629); // Default India

  @override
  void onInit() {
    super.onInit();
    checkAttendanceStatus();
  }

  Future<void> checkAttendanceStatus() async {
    isLoading = true;
    update();

    try {
      final apiClient = Get.find<ApiClient>();
      String token = apiClient.sharedPreferences.getString(SharedPreferenceHelper.accessTokenKey) ?? '';
      
      if (token.isEmpty) {
        isPunchedIn = false;
      } else {
        AttendanceService attendanceService = AttendanceService(token);
        AttendanceStatus status = await attendanceService.getTodayStatus();
        
        // Check if there is an active session
        isPunchedIn = status.punchedIn && !status.punchedOut;
      }
    } catch (e) {
      print('Error checking attendance: $e');
      isPunchedIn = false;
    }

    if (isPunchedIn) {
      await _getCurrentLocation();
      loadLeads();
    }
    
    isLoading = false;
    update();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      currentCenter = LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  // Map to store item type (lead/customer) by ID.
  Map<String, String> itemTypes = {};

  Future<void> loadLeads({String? query}) async {
    isLoading = true;
    update();
    
    leads.clear();
    markers.clear();
    itemTypes.clear(); // Clear types

    try {
      ResponseModel responseModel;
      if (query != null && query.isNotEmpty) {
        responseModel = await salesTrackerRepo.searchAssignedLeads(query);
      } else {
        responseModel = await salesTrackerRepo.getAssignedLeads();
      }

      print("SalesTracker Response Status: ${responseModel.status}");
      print("SalesTracker Response Body: ${responseModel.responseJson}");

      if (responseModel.status) {
        try {
            var decoded = jsonDecode(responseModel.responseJson);
            
            List<dynamic> leadsList = [];
            List<dynamic> customersList = [];
            
            if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
                 var dataObj = decoded['data'];
                 if (dataObj is Map<String, dynamic>) {
                   if (dataObj.containsKey('leads') && dataObj['leads'] is List) {
                     leadsList = dataObj['leads'];
                   }
                   if (dataObj.containsKey('customers') && dataObj['customers'] is List) {
                     customersList = dataObj['customers'];
                   }
                 } else if (dataObj is List) {
                   // Fallback if structure is just a list (assume leads)
                   leadsList = dataObj;
                 }
            } else if (decoded is List) {
                 leadsList = decoded;
            }

            // Process Leads
            for (var item in leadsList) {
                Lead lead = Lead.fromJson(item);
                leads.add(lead);
                if (lead.id != null) itemTypes[lead.id.toString()] = 'lead';
            }

            // Process Customers
            for (var item in customersList) {
                Lead lead = Lead.fromJson(item); // reusing Lead model for simplicity if compatible
                leads.add(lead);
                if (lead.id != null) itemTypes[lead.id.toString()] = 'customer';
            }

            if (leads.isNotEmpty) {
              print("Parsed ${leads.length} items (${leadsList.length} leads, ${customersList.length} customers).");
              await _geocodeAndCreateMarkers();
            } else {
               print("No lead/customer data found in response.");
            }

        } catch(e) {
            print("Parsing error in loadLeads: $e");
            CustomSnackBar.error(errorList: ["Failed to parse data"]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message.tr]);
      }
    } catch (e) {
      print('Error loading leads: $e');
    }

    isLoading = false;
    update();
  }

  // ... (existing _geocodeAndCreateMarkers and _getCoordinates methods remain same, but I need to include them to keep file integrity if I'm replacing a block, or just replace the specific methods. I will replace the methods to be safe and clean)
  
  // skipping _geocodeAndCreateMarkers and _getCoordinates in this Replace block for brevity if possible, 
  // BUT the user asked to change `_showLeadDetailsBottom`.
  // So I'll just replace `loadLeads` and `_showLeadDetailsBottom` logic.
  // Warning: I need to be careful with line numbers.
  // `loadLeads` starts at 76, ends at 141.
  // `_showLeadDetailsBottom` starts at 250.
  // I will make two separate edits.

  // 1. First edit: Update loadLeads to populate itemTypes.
  // 2. Second edit: Update _showLeadDetailsBottom to use itemTypes and add button.
  
  // This first tool call is for `loadLeads`.



  Future<void> _geocodeAndCreateMarkers() async {
    // Limit to first 20 to avoid rate limits for demo
    int count = 0;
    print("Starting geocoding for ${leads.length} items...");
    
    for (var lead in leads) {
      if (count >= 20) {
        print("Reached geocoding limit of 20.");
        break;
      }
      
      String address = [
        lead.address, 
        lead.city, 
        lead.state, 
        lead.country
      ].where((s) => s != null && s.trim().isNotEmpty).join(', ');

      print("Processing Item: ${lead.name}, Address: '$address'");

      if (address.isNotEmpty) {
        LatLng? coords = await _getCoordinates(address);
        if (coords != null) {
          print("Found coords for ${lead.name}: $coords");
          markers.add(
            Marker(
              point: coords,
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                   _showLeadDetailsBottom(lead);
                },
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ),
          );
        } else {
           print("Could not geocode address: $address");
        }
        // Small delay to respect Nominatim usage policy (1 sec per request recommended)
        await Future.delayed(const Duration(milliseconds: 1000));
      } else {
        print("Address is empty for: ${lead.name}");
      }
      count++;
    }
    update();
  }

  Future<LatLng?> _getCoordinates(String address) async {
    String? googleApiKey = dotenv.env['GOOGLE_API_KEY'];
    
    // 1. Try Google Geocoding API first
    if (googleApiKey != null && googleApiKey.isNotEmpty) {
      try {
        final response = await Dio().get(
          'https://maps.googleapis.com/maps/api/geocode/json', 
          queryParameters: {
            'address': address,
            'key': googleApiKey
          }
        );

        if (response.data['status'] == 'OK' && response.data['results'].isNotEmpty) {
           var location = response.data['results'][0]['geometry']['location'];
           return LatLng(location['lat'], location['lng']);
        } else {
           print("Google Geocoding failed: ${response.data['status']}");
        }
      } catch (e) {
        print('Google Geocoding error: $e');
      }
    }

    // 2. Fallback to Nominatim (OpenStreetMap)
    print("Falling back to Nominatim for address: $address");
    try {
       final response = await Dio().get(
         'https://nominatim.openstreetmap.org/search', 
         queryParameters: {
           'q': address,
           'format': 'json',
           'limit': 1
         },
         options: Options(
           headers: {
             'User-Agent': 'SmmartCRMApp/1.0', // Required by Nominatim
           }
         )
       );
       
       if (response.data is List && response.data.isNotEmpty) {
         var data = response.data[0];
         return LatLng(double.parse(data['lat']), double.parse(data['lon']));
       }
    } catch (e) {
      print('Nominatim Geocoding error: $e');
    }
    return null;
  }
  
  void _showLeadDetailsBottom(Lead lead) {
    String type = itemTypes[lead.id.toString()] ?? 'lead'; // Default to lead
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${lead.name ?? 'Unknown'} (${type.capitalizeFirst})",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text("Company: ${lead.company ?? 'N/A'}"),
            Text("Address: ${lead.address ?? 'N/A'}"),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Close bottom sheet
                  if (type == 'customer') {
                     Get.toNamed(RouteHelper.customerDetailsScreen, arguments: lead.id);
                  } else {
                     Get.toNamed(RouteHelper.leadDetailsScreen, arguments: lead.id);
                  }
                },
                child: const Text('View Details'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
                child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continue'),
                onPressed: () {
                   Get.back();
                   Get.to(() => ContinueTripScreen(lead: lead));
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  foregroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void searchLeads(String query) {
    loadLeads(query: query);
  }
}
