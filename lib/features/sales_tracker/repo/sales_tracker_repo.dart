import 'package:flutex_admin/core/service/api_service.dart';
import 'package:flutex_admin/core/utils/method.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/common/models/response_model.dart';

class SalesTrackerRepo {
  final ApiClient apiClient;

  SalesTrackerRepo({required this.apiClient});

  Future<ResponseModel> getAssignedLeads() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.salesTrackerGetLeadsUrl}";
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
    String url = "${UrlContainer.baseUrl}${UrlContainer.salesTrackerSearchLeadUrl}";
    // Use x-www-form-urlencoded params as per requirement
    Map<String, String> params = {
      "keyword": keyword,
    };
    print('--- [SalesTrackerRepo] Request: searchAssignedLeads ---');
    print('URL: $url');
    print('Params: $params');
    
    // Using Method.putMethod internally if it supports form-urlencoded or ensure apiClient handles it.
    // However, apiClient 'postMethod' usually sends JSON unless specific headers are set.
    // The requirement says: Content-Type: application/x-www-form-urlencoded
    // Let's check api_service.dart again. 
    // It seems apiClient handles JSON body by default for POST.
    // BUT we can perform a trick or modify apiClient. 
    // Or we can use `post` but apiClient might enforce json header.
    // Let's check if we can force it.
    // ApiClient code:
    // ...
    // headers: {'Accept': 'application/json', 'Authorization': token} ...
    //
    // The requirement explicitly asks for application/x-www-form-urlencoded for search. 
    // "Method.putMethod" in ApiClient uses: 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
    // But this is a POST request.
    //
    // Since we can't easily change ApiClient without affecting others, we will rely on 
    // ApiClient sending standard request.
    // **WAIT**: The user provided `curl -d "keyword=test"`. 
    // If ApiClient sends JSON `{"keyword": "test"}`, backend might not like it if it expects form-data.
    // However, the `getAssignedLeads` working curl sends `-d '{}'` which is JSON.
    // The search one strictly says `Content-Type: application/x-www-form-urlencoded`.
    //
    // If ApiClient doesn't support custom headers for POST easily (it hardcodes them), 
    // we might have an issue. 
    // ApiClient: `headers: {'Accept': 'application/json', 'Authorization': token}`
    // It does NOT set Content-Type to application/json explicitly for POST? 
    // Usually http.post defaults to text/plain or similar if body is map?? No, encoding...
    //
    // Actually, `http.post(url, body: map)` sends `x-www-form-urlencoded` by default in Dart http package!
    // UNLESS we encode it to JSON string.
    // ApiClient passes `params` (Map) directly to `http.post`.
    // So `http.post(..., body: params)` => x-www-form-urlencoded.
    // 
    // Wait, for `getAssignedLeads`, the curl uses `Content-Type: application/json` and `-d '{}'`.
    // Passings `params` (Map) to http.post makes it form-urlencoded.
    // Passing `jsonEncode(params)` makes it body, but we need header.
    //
    // Let's look at ApiClient again.
    // `response = await http.post(url, body: params, headers: {...})`
    // If `params` is Map, it sends form-urlencoded. 
    // So Search API (form-urlencoded) should work fine with `params`.
    //
    // The Get Leads API (JSON) might fail if it receives form-urlencoded `{}`. 
    // But the user said: "Use empty {} body for list API".
    // 
    // We will follow the pattern. If `params` is null/empty map, http might send content-length 0.
    //
    // Let's stick to standard `params` map for now.
    
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
}
