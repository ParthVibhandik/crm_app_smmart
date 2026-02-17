import 'dart:convert';

import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/staff/model/staff_post_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class StaffRepo {
  ApiClient apiClient;
  StaffRepo({required this.apiClient});

  Future<ResponseModel> getAllStaffs() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.staffsUrl}?limit=1000&offset=0";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    print('Staff List Route: $url');
    print('Staff List Response: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> getSubordinates() async {
    String url = "${UrlContainer.baseUrl}get-subs";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    print('Staff (Subordinates) List Route: $url');
    print('Staff (Subordinates) List Response: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> getStaffDetails(staffId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.staffsUrl}/id/$staffId";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<StatusModel> submitStaff(
    StaffPostModel staffModel, {
    String? staffId,
    bool isUpdate = false,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.staffsUrl}";

    Map<String, String> params = {
      "firstname": staffModel.firstName,
      "lastname": staffModel.lastName,
      "email": staffModel.email,
      "phonenumber": staffModel.phoneNumber ?? '',
      "hourly_rate": staffModel.hourlyRate ?? '',
      "facebook": staffModel.facebook ?? '',
      "skype": staffModel.skype ?? '',
      "linkedin": staffModel.linkedIn ?? '',
      "password": staffModel.password,
      "is_not_staff": staffModel.isNotStaff ?? '',
      "admin": staffModel.admin ?? '',
      "send_welcome_email": staffModel.sendWelcomeEmail ?? '',
    };

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(<String, String>{'Authorization': apiClient.token});
    if (staffModel.image != null) {
      request.files.add(
        http.MultipartFile(
          'profile_image',
          staffModel.image!.readAsBytes().asStream(),
          staffModel.image!.lengthSync(),
          filename: staffModel.image!.path.split('/').last,
        ),
      );
    }

    request.fields.addAll(params);
    http.StreamedResponse response = await request.send();

    String jsonResponse = await response.stream.bytesToString();
    StatusModel responseModel = StatusModel.fromJson(jsonDecode(jsonResponse));

    if (kDebugMode) {
      print(response.statusCode);
      print(params);
      print(jsonResponse);
      print(url.toString());
    }

    //ResponseModel responseModel = await apiClient.request(
    //  isUpdate ? '$url/id/$staffId' : url,
    //  isUpdate ? Method.putMethod : Method.postMethod,
    //  params,
    //  passHeader: true,
    //);
    return responseModel;
  }

  Future<ResponseModel> deleteStaff(staffId, transferDataTo) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.staffsUrl}/id/$staffId/transfer_data_to/$transferDataTo";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.deleteMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> searchStaff(keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.staffsUrl}/search/$keysearch";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }
}
