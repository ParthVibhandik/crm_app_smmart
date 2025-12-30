import 'dart:convert';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:geolocator/geolocator.dart';

class SalesTrackerRepo {
  final ApiClient apiClient;

  SalesTrackerRepo({required this.apiClient});

  Future<ResponseModel> getAssignedLeads() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.salesTrackerGetLeadsUrl}";
    print('--- [SalesTrackerRepo] Request: getAssignedLeads ---');
    print('URL: $url');
    // Body should be empty map {}
    Map<String, dynamic> params = {};

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );
    print('--- [SalesTrackerRepo] Response: getAssignedLeads ---');
    print('Response Body: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> searchAssignedLeads(String keyword) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.salesTrackerSearchLeadUrl}";
    Map<String, String> params = {"keyword": keyword};
    print('--- [SalesTrackerRepo] Request: searchAssignedLeads ---');
    print('URL: $url');
    print('Params: $params');

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );
    print('--- [SalesTrackerRepo] Response: searchAssignedLeads ---');
    print('Response Body: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> startTrip({
    required int? leadId,
    required int? customerId,
    required double destinationLat,
    required double destinationLng,
    required double startLat,
    required double startLng,
    required String startAddress,
    String? altAddress,
    String? altAddressReason,
    String? modeOfTransport,
  }) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.salesTrackerStartTripUrl}";

    // Convert all values to strings for form data
    Map<String, String> params = {
      "lead_id": leadId?.toString() ?? "",
      "customer_id": customerId?.toString() ?? "",
      "destination_lat": destinationLat.toString(),
      "destination_lng": destinationLng.toString(),
      "start_lat": startLat.toString(),
      "start_lng": startLng.toString(),
      "start_address": startAddress,
      "alt_address": altAddress ?? "",
      "alt_address_reason": altAddressReason ?? "",
      "mode_of_transport": modeOfTransport ?? "",
    };

    print('--- [SalesTrackerRepo] Request: startTrip ---');
    print('URL: $url');
    print('Params: ${jsonEncode(params)}');

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );

    print('--- [SalesTrackerRepo] Response: startTrip ---');
    print('Response Status: ${responseModel.status}');
    print('Response Message: ${responseModel.message}');
    print('Response Body: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> getActiveTrip() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.salesTrackerGetActiveTripUrl}";
    print('--- [SalesTrackerRepo] Request: getActiveTrip ---');
    print('URL: $url');

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      {},
      passHeader: true,
    );

    print('--- [SalesTrackerRepo] Response: getActiveTrip ---');
    print('Response Status: ${responseModel.status}');
    print('Response Message: ${responseModel.message}');
    print('Response Body: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> markReachedDestination() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.salesTrackerReachedUrl}";
    print('--- [SalesTrackerRepo] Request: markReachedDestination ---');
    print('URL: $url');

    // getting lat and lng from device should be handled in controller
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    final lat = position.latitude;
    final lng = position.longitude;

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      {
        "latitude": lat.toString(),
        "longitude": lng.toString(),
      },
      passHeader: true,
    );

    print('--- [SalesTrackerRepo] Response: markReachedDestination ---');
    print(
      'Response Status: ${responseModel.status}',
    );
    print('Response Message: ${responseModel.message}');
    print('Response Body: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> updateAddress({
    required String altAddress,
    required String altReason,
  }) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.salesTrackerUpdateAddressUrl}";

    Map<String, String> params = {
      "alt_address": altAddress,
      "alt_address_reason": altReason,
    };

    print('--- [SalesTrackerRepo] Request: updateAddress ---');
    print('URL: $url');
    print('Params: $params');

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );

    print('--- [SalesTrackerRepo] Response: updateAddress ---');
    print('Response Status: ${responseModel.status}');
    print('Response Message: ${responseModel.message}');
    print('Response Body: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> callStart() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.salesTrackerCallStartUrl}";
    print('--- [SalesTrackerRepo] Request: callStart ---');
    print('URL: $url');

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      {},
      passHeader: true,
    );

    print('--- [SalesTrackerRepo] Response: callStart ---');
    print('Response Status: ${responseModel.status}');
    print('Response Message: ${responseModel.message}');
    print('Response Body: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> endTrip({String? callRemark, String? invoiceId}) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.salesTrackerEndTripUrl}";
    print('--- [SalesTrackerRepo] Request: endTrip ---');
    print('URL: $url');

    Map<String, String> params = {};
    if (callRemark != null && callRemark.isNotEmpty) {
      params['call_remark'] = callRemark;
    }
    if (invoiceId != null && invoiceId.isNotEmpty) {
      params['invoice_id'] = invoiceId;
    }

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );

    print('--- [SalesTrackerRepo] Response: endTrip ---');
    print('Response Status: ${responseModel.status}');
    print('Response Message: ${responseModel.message}');
    print('Response Body: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> getTripStatus() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.salesTrackerGetStatusUrl}";
    print('--- [SalesTrackerRepo] Request: getTripStatus ---');
    print('URL: $url');

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      {},
      passHeader: true,
    );

    print('--- [SalesTrackerRepo] Response: getTripStatus ---');
    print('Response Status: ${responseModel.status}');
    print('Response Message: ${responseModel.message}');
    print('Response Body: ${responseModel.responseJson}');
    return responseModel;
  }
}
