import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/helper/shared_preference_helper.dart';
import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';

class DCRRepo {
  final ApiClient apiClient;

  DCRRepo({required this.apiClient});

  Future<ResponseModel> getDCR() async {
    String staffId = apiClient.sharedPreferences
            .getString(SharedPreferenceHelper.userIdKey) ??
        "";
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.dcrUrl}?staff_id=$staffId";

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }
}
