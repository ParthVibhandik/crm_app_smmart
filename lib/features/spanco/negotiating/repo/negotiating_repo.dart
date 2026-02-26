import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class NegotiatingRepo {
  ApiClient apiClient;
  NegotiatingRepo({required this.apiClient});

  Future<ResponseModel> getData() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.spancoUrl}negotiation";
    return await apiClient.request(url, Method.getMethod, null,
        passHeader: true);
  }

  Future<ResponseModel> getRowData(String opportunityId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.spancoUrl}row?id=$opportunityId";
    return await apiClient.request(url, Method.getMethod, null,
        passHeader: true);
  }

  Future<ResponseModel> updateData(Map<String, dynamic> body) async {
    String url =
        "\${UrlContainer.baseUrl}\${UrlContainer.spancoUrl}update-negotiation";
    return await apiClient.request(url, Method.postMethod, body,
        passHeader: true);
  }

  Future<ResponseModel> getIndustries() async {
    String url = "\${UrlContainer.baseUrl}\${UrlContainer.industriesUrl}";
    return await apiClient.request(url, Method.getMethod, null,
        passHeader: true);
  }

  Future<ResponseModel> getSources() async {
    String url =
        "\${UrlContainer.baseUrl}\${UrlContainer.miscellaneousUrl}/leads_sources";
    return await apiClient.request(url, Method.getMethod, null,
        passHeader: true);
  }
}
