import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class TelecallingRepo {
  final ApiClient apiClient;

  TelecallingRepo({required this.apiClient});

  Future<ResponseModel> searchLeads(String keyword) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.salesTrackerSearchLeadUrl}";
    Map<String, String> params = {"keyword": keyword};

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getAssignedLeads() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.salesTrackerGetLeadsUrl}";
    // Body should be empty map {}
    Map<String, dynamic> params = {};

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> recordTelecall({
    required String leadId,
    required String duration,
    required String status,
    required String remarks,
    String? invoiceId,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.telecallUrl}/record";
    Map<String, String> params = {
      "lead_id": leadId,
      "duration": duration,
      "current_status": status,
      "remarks": remarks,
      if (invoiceId != null) "invoice_id": invoiceId,
    };

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );
    return responseModel;
  }
}
