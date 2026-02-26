import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/lead/model/lead_create_model.dart';
import 'package:flutex_admin/features/lead/model/reminder_create_model.dart';

class LeadRepo {
  ApiClient apiClient;
  LeadRepo({required this.apiClient});

  Future<ResponseModel> getAllLeads({
    int page = 0,
    String? sort,
    String? source,
    String? status,
  }) async {
    // Calculate offset based on page number
    int offset = page * int.parse(UrlContainer.limit);
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}?limit=${UrlContainer.limit}&offset=$offset";
    sort != null ? url += "&sort=$sort" : null;
    status != null ? url += "&status=$status" : null;
    source != null ? url += "&source=$source" : null;
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getKanbanLeads() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.kanbanLeadsUrl}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getLeadDetails(leadId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/id/$leadId";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    print("DEBUG_LEAD_DETAILS: ${responseModel.responseJson}");
    return responseModel;
  }

  Future<ResponseModel> getLeadNotes(leadId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/notes/id/$leadId";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> postLeadNote(
    leadId,
    String note,
    String dateContacted,
  ) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/notes/id/$leadId";

    Map<String, String> params = {
      "description": note,
      "date_contacted": dateContacted,
    };

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getLeadReminders(leadId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/reminders/id/$leadId";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> postLeadReminder(
    leadId,
    ReminderCreateModel reminderCreateModel,
  ) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/reminders/id/$leadId";

    Map<String, String> params = {
      "date": reminderCreateModel.date,
      "staff": reminderCreateModel.staff,
      "description": reminderCreateModel.description,
      "notify_by_email": reminderCreateModel.emailReminder,
    };

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getLeadActivityLog(leadId) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/activity_log/id/$leadId";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> attachmentDownload(String attachmentKey) async {
    String url = "${UrlContainer.leadAttachmentUrl}/$attachmentKey";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getLeadStatuses() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/leads_statuses";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getLeadSources() async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.miscellaneousUrl}/leads_sources";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getLeadIndustries() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.industriesUrl}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getLeadDesignations() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.designationsUrl}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getLeadInterestedIn() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.interestedInUrl}";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> getStaff() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/staffs";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> createLead(
    LeadCreateModel leadModel, {
    String? leadId,
    bool isUpdate = false,
  }) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}";

    Map<String, dynamic> params = {
      "source": leadModel.source,
      "status": leadModel.status,
      "name": leadModel.name,
      "assigned": leadModel.assigned,
      "tags": leadModel.tags,
      "lead_value": leadModel.value,
      "title": leadModel.designation ?? leadModel.title,
      "email": leadModel.email,
      "website": leadModel.website,
      "phonenumber": leadModel.phoneNumber,
      "company": leadModel.company,
      "address": leadModel.address,
      "city": leadModel.city,
      "state": leadModel.state,
      "country": leadModel.country,
      "default_language": leadModel.defaultLanguage,
      "company_industry": leadModel.companyIndustry,
      "description": leadModel.description,
      "is_public": leadModel.isPublic,
      "designation": leadModel.designation,
    };

    if (leadModel.interestedIn != null && leadModel.interestedIn!.isNotEmpty) {
      int index = 0;
      for (var item in leadModel.interestedIn!) {
        if (item.isNotEmpty && item != "null") {
          params["interested_in[$index]"] = item;
          index++;
        }
      }
    }

    if (isUpdate) {
      params['id'] = leadId;
    }

    print('Create Lead Params: $params');

    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      params,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> deleteLead(leadId) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/id/$leadId";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.deleteMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> searchLead(keysearch) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/search/$keysearch";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.getMethod,
      null,
      passHeader: true,
    );
    return responseModel;
  }

  Future<ResponseModel> convertLeadToCustomer(Map<String, dynamic> body) async {
    String url =
        "${UrlContainer.baseUrl}${UrlContainer.leadsUrl}/convert-to-customer";
    ResponseModel responseModel = await apiClient.request(
      url,
      Method.postMethod,
      body,
      passHeader: true,
    );
    return responseModel;
  }
}
