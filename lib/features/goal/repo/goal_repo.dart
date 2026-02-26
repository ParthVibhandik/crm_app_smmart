import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';

class GoalRepo {
  final ApiClient apiClient;
  GoalRepo({required this.apiClient});

  Future<ResponseModel> getStaffGoals(String staffId) async {
    // Assuming the API endpoint is flutex_admin_api/goals?staff_id=X
    // Or maybe we send it in body. The user said "send his id... flutex_admin_api/goals"
    // Usually fetching list is GET.
    String url = "${UrlContainer.baseUrl}goals";
    // I will try passing it as a query parameter 'staff_id'
    // If not, I'll try 'id'.
    // If it's a POST, I need to know. Assuming GET with query param based on typical pattern.
    // If it's specific endpoint "goals", it might be get all goals.
    // I'll try adding staff_id query param.
    // The user said "send his id to backend on api flutex_admin_api/goals".

    // Attempt 1: GET with query param
    url += "?staff_id=$staffId";

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    print('Goal Route: $url');
    print('Goal Response: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> getGoalDetails(String goalId) async {
    String url = "${UrlContainer.baseUrl}goals/id/$goalId";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    print('Goal Details Route: $url');
    print('Goal Details Response: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> createGoal(Map<String, dynamic> body) async {
    String url = "${UrlContainer.baseUrl}goals/create";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      body,
      passHeader: true,
    );
    print('Create Goal Route: $url');
    print('Create Goal Response: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> updateGoal(Map<String, dynamic> body) async {
    String url = "${UrlContainer.baseUrl}goals/create";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      body,
      passHeader: true,
    );
    print('Update Goal Route: $url');
    print('Update Goal Response: ${responseModel.responseJson}');
    return responseModel;
  }
}
