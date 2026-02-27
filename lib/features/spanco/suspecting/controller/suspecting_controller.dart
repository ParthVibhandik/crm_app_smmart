import 'dart:convert';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/spanco/model/spanco_model.dart';
import 'package:flutex_admin/features/spanco/suspecting/model/industry_model.dart';
import 'package:flutex_admin/features/spanco/suspecting/repo/suspecting_repo.dart';
import 'package:flutex_admin/features/spanco/suspecting/view/suspecting_details_screen.dart';
import 'package:get/get.dart';

class SuspectingController extends GetxController {
  SuspectingRepo repo;
  SuspectingController({required this.repo});

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

    Get.to(() => const SuspectingDetailsScreen());

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

  void updateEditableField(String key, dynamic value) {
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
      'opportunity_id': editableDetails!['opportunity_id']?.toString() ?? '',
      'name': editableDetails!['name']?.toString() ?? '',
      'company': editableDetails!['company']?.toString() ?? '',
      'company_industry': industryList
              .any((e) => e.name == editableDetails!['company_industry'])
          ? industryList
              .firstWhere((e) => e.name == editableDetails!['company_industry'])
              .id
          : editableDetails!['company_industry']?.toString() ?? '',
      'phonenumber': editableDetails!['phonenumber']?.toString() ?? '',
      'email': editableDetails!['email']?.toString() ?? '',
      'source': sourceList.any((e) => e.name == editableDetails!['source'])
          ? sourceList
              .firstWhere((e) => e.name == editableDetails!['source'])
              .id
          : editableDetails!['source']?.toString() ?? '',
      'city': editableDetails!['city']?.toString() ?? '',
    };

    if (editableDetails!['recommended_programs'] is List) {
      List progs = editableDetails!['recommended_programs'];
      for (int i = 0; i < progs.length; i++) {
        var p = progs[i];
        String pId = p is Map
            ? p['id']?.toString() ?? p['program_id']?.toString() ?? ''
            : p.toString();
        body['recommended_programs[$i]'] = pId;
      }
    }

    if (editableDetails!['stage_data'] is Map) {
      Map? sd = editableDetails!['stage_data'];
      body['proposal_sent'] = sd?['proposal_sent']?.toString() ?? 'false';
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

  bool isMoveLoading = false;

  Future<void> moveToProspecting() async {
    if (details == null || details!['opportunity_id'] == null) return;

    isMoveLoading = true;
    update();

    ResponseModel responseModel =
        await repo.moveToProspecting(details!['opportunity_id'].toString());

    isMoveLoading = false;
    update();

    if (responseModel.status == true) {
      Get.back(); // close details
      Get.snackbar('Success', 'Moved to Prospecting successfully.',
          snackPosition: SnackPosition.BOTTOM);
      loadData(); // Refresh list
    } else {
      Get.snackbar('Error', responseModel.message,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
