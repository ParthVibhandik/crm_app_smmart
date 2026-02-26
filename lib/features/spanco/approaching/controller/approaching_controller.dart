import 'dart:convert';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/spanco/model/spanco_model.dart';
import 'package:flutex_admin/features/spanco/suspecting/model/industry_model.dart';
import 'package:flutex_admin/features/spanco/approaching/repo/approaching_repo.dart';
import 'package:flutex_admin/features/spanco/approaching/view/approaching_details_screen.dart';
import 'package:get/get.dart';

class ApproachingController extends GetxController {
  ApproachingRepo repo;
  ApproachingController({required this.repo});

  bool isLoading = false;
  List<SpancoItemModel> list = [];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    update();

    list.clear();
    ResponseModel responseModel = await repo.getData();
    if (responseModel.status == true) {
      SpancoModel model =
          SpancoModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status == true && model.data != null) {
        list.addAll(model.data!);
      } else {
        Get.snackbar('Error', model.message ?? 'Failed to load data',
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      if (responseModel.message.toLowerCase() != 'no data found!') {
        Get.snackbar('Error', responseModel.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    }

    isLoading = false;
    update();
  }

  bool isDetailsLoading = false;
  Map<String, dynamic>? details;
  Map<String, dynamic>? editableDetails;
  bool isEditing = false;

  List<IndustryItem> industryList = [];
  List<IndustryItem> sourceList = [];
  bool isIndustriesLoading = false;

  Future<void> onItemTap(String opportunityId) async {
    isDetailsLoading = true;
    update();

    Get.to(() => const ApproachingDetailsScreen());

    ResponseModel responseModel = await repo.getRowData(opportunityId);
    if (responseModel.status == true) {
      try {
        final decoded = jsonDecode(responseModel.responseJson);
        if (decoded['status'] == true && decoded['data'] != null) {
          if (decoded['data'] is List && decoded['data'].isNotEmpty) {
            details = decoded['data'][0];
            editableDetails = Map<String, dynamic>.from(decoded['data'][0]);
          } else if (decoded['data'] is Map) {
            details = decoded['data'];
            editableDetails = Map<String, dynamic>.from(decoded['data']);
          }
        } else {
          Get.snackbar('Error', decoded['message'] ?? 'Failed to load details',
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (e) {
        Get.snackbar('Error', 'Invalid response format',
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar('Error', responseModel.message,
          snackPosition: SnackPosition.BOTTOM);
    }

    isDetailsLoading = false;
    isEditing = false;
    update();

    // Fetch dropdowns in background if needed
    loadDropdowns();
  }

  Future<void> loadDropdowns() async {
    isIndustriesLoading = true;
    update();

    ResponseModel responseModel = await repo.getIndustries();
    if (responseModel.status == true) {
      try {
        final decoded = jsonDecode(responseModel.responseJson);
        if (decoded['status'] == true && decoded['data'] != null) {
          industryList.clear();
          decoded['data'].forEach((v) {
            industryList.add(IndustryItem.fromJson(v));
          });
        }
      } catch (e) {
        // Safe to ignore
      }
    }

    ResponseModel srcResponseModel = await repo.getSources();
    if (srcResponseModel.status == true) {
      try {
        final decoded = jsonDecode(srcResponseModel.responseJson);
        if (decoded['status'] == true && decoded['data'] != null) {
          sourceList.clear();
          decoded['data'].forEach((v) {
            sourceList.add(IndustryItem.fromJson(v));
          });
        }
      } catch (e) {
        // Safe to ignore
      }
    }

    isIndustriesLoading = false;
    update();
  }

  void toggleEditing() {
    isEditing = !isEditing;
    if (!isEditing && details != null) {
      // Reset on cancel
      editableDetails = Map<String, dynamic>.from(details!);
    }
    update();
  }

  void updateEditableField(String key, String value) {
    if (editableDetails != null) {
      editableDetails![key] = value;
      update();
    }
  }

  void updateStageDataField(String key, dynamic value) {
    if (editableDetails != null && editableDetails!['stage_data'] is Map) {
      editableDetails!['stage_data'][key] = value;
      update();
    }
  }

  bool isUpdateLoading = false;

  Future<void> updateData() async {
    if (editableDetails == null) return;

    isUpdateLoading = true;
    update();

    Map<String, dynamic> body = {
      'lead_id': editableDetails!['id']?.toString() ?? '',
      'name': editableDetails!['name']?.toString() ?? '',
      'company': editableDetails!['company']?.toString() ?? '',
      'company_industry':
          editableDetails!['company_industry']?.toString() ?? '',
      'phonenumber': editableDetails!['phonenumber']?.toString() ?? '',
      'email': editableDetails!['email']?.toString() ?? '',
      'source': editableDetails!['source']?.toString() ?? '',
      'city': editableDetails!['city']?.toString() ?? '',
    };

    if (editableDetails!['stage_data'] is Map) {
      Map? sd = editableDetails!['stage_data'];
      body['man_identified'] = sd?['man_identified']?.toString() ?? 'false';
      body['money_identified'] = sd?['money_identified']?.toString() ?? 'false';
      body['money_value'] = sd?['money_value']?.toString() ?? '';
      body['authority_identified'] =
          sd?['authority_identified']?.toString() ?? 'false';
      body['need_identified'] = sd?['need_identified']?.toString() ?? 'false';
      body['need_description'] = sd?['need_description']?.toString() ?? '';
      body['appointment'] = sd?['appointment']?.toString() ?? '';
    }

    ResponseModel responseModel = await repo.updateData(body);

    isUpdateLoading = false;
    update();

    if (responseModel.status == true) {
      Get.back(); // close details
      Get.snackbar('Success', 'Updated successfully.',
          snackPosition: SnackPosition.BOTTOM);
      loadData(); // Refresh list
    } else {
      Get.snackbar('Error', responseModel.message,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
