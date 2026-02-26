import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/task/model/task_create_model.dart';

class TaskRepo {
  ApiClient apiClient;
  TaskRepo({required this.apiClient});

  Future<ResponseModel> getAllTasks({
    int page = 0,
    String? sort,
    String? priority,
    String? status,
  }) async {
    // Calculate offset based on page number
    int offset = page * int.parse(UrlContainer.limit);
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}?limit=${UrlContainer.limit}&offset=$offset";
    sort != null ? url += "&sort=$sort" : null;
    status != null ? url += "&status=$status" : null;
    priority != null ? url += "&priority=$priority" : null;
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    print('Task List Route: $url');
    print('Task List Response: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> getTaskDetails(taskId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}?id=$taskId";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    print('Task Details Route: $url');
    print('Task Details Response: ${responseModel.responseJson}');
    return responseModel;
  }

  Future<ResponseModel> getAllCustomers() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.customersUrl}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getAllProjects() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.projectsUrl}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getAllInvoices() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.invoicesUrl}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getAllLeads() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getAllContracts() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.contractsUrl}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getAllEstimates() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.estimatesUrl}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getAllProposals() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.proposalsUrl}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> createTask(
    TaskCreateModel taskModel, {
    String? taskId,
    bool isUpdate = false,
  }) async {
    String url = "${UrlContainer.baseUrl}create-task";

    Map<String, dynamic> params = {
      "subject": taskModel.subject,
      "description": taskModel.description,
      "assigned_to": taskModel.assignedTo,
      "priority": int.tryParse(taskModel.priority ?? '1') ?? 1,
      "startdate": taskModel.startDate,
      "duedate": taskModel.dueDate,
      "status": int.tryParse(taskModel.status ?? '1') ?? 1,
    };

    ResponseModel responseModel = await apiClient.request(
      isUpdate ? '$url/id/$taskId' : url,
      isUpdate ? Method.putMethod : Method.postMethod,
      params,
      passHeader: true,
      isJson: true,
    );
    print('Create/Update Task Route: $url');
    print('Create/Update Task Response: ${responseModel.responseJson}');
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
    return responseModel;
  }

  Future<ResponseModel> deleteTask(taskId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/id/$taskId";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.deleteMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> searchTask(keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.tasksUrl}/search/$keysearch";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> updateTaskStatus(String taskId, String status) async {
    String url = "${UrlContainer.baseUrl}update-task-status";
    Map<String, dynamic> params = {
      "taskid": taskId,
      "status": status,
    };
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
      isJson: true,
    );
    return responseModel;
  }
}
