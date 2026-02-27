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
  List<IndustryItem> programList = [];
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
            details = Map<String, dynamic>.from(decoded['data'][0]);
            editableDetails = Map<String, dynamic>.from(decoded['data'][0]);
          } else if (decoded['data'] is Map) {
            details = Map<String, dynamic>.from(decoded['data']);
            editableDetails = Map<String, dynamic>.from(decoded['data']);
          }
          // Translate source ID → name for the dropdown to pre-select correctly
          _normalizeSourceField();
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

    loadDropdowns();
  }

  /// After dropdowns load, also translate source ID → name if still numeric
  void _normalizeSourceField() {
    if (editableDetails == null) return;
    final rawSource = editableDetails!['source']?.toString() ?? '';
    if (rawSource.isNotEmpty) {
      try {
        final matched = sourceList.firstWhere(
            (s) => s.id?.toString() == rawSource || s.name == rawSource);
        editableDetails!['source'] = matched.name ?? rawSource;
      } catch (_) {
        // Will retry after sourceList loads
      }
    }
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
      } catch (e) {}
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
      } catch (e) {}
    }

    ResponseModel progResponseModel = await repo.getPrograms();
    if (progResponseModel.status == true) {
      try {
        final decoded = jsonDecode(progResponseModel.responseJson);
        if (decoded['status'] == true && decoded['data'] != null) {
          programList.clear();
          decoded['data'].forEach((v) {
            programList.add(IndustryItem.fromJson(v));
          });
        }
      } catch (e) {}
    }

    // Normalize source ID → name now that sourceList is loaded
    _normalizeSourceField();

    isIndustriesLoading = false;
    update();
  }

  void toggleEditing() {
    isEditing = !isEditing;
    if (!isEditing && details != null) {
      editableDetails = Map<String, dynamic>.from(details!);
      _normalizeSourceField();
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

  /// Toggle a program in recommended_programs list
  void toggleProgram(IndustryItem prog, bool selected) {
    if (editableDetails == null) return;
    List current = editableDetails!['recommended_programs'] is List
        ? List.from(editableDetails!['recommended_programs'])
        : [];
    if (selected) {
      bool already = current.any((p) =>
          p is Map &&
          (p['program_id']?.toString() == prog.id?.toString() ||
              p['id']?.toString() == prog.id?.toString()));
      if (!already) {
        current.add({'program_id': prog.id, 'name': prog.name});
      }
    } else {
      current.removeWhere((p) =>
          p is Map &&
          (p['program_id']?.toString() == prog.id?.toString() ||
              p['id']?.toString() == prog.id?.toString()));
    }
    editableDetails!['recommended_programs'] = current;
    update();
  }

  bool isUpdateLoading = false;

  Future<void> updateData() async {
    if (editableDetails == null) return;

    isUpdateLoading = true;
    update();

    // Resolve source name → ID for API
    String sourceId = editableDetails!['source']?.toString() ?? '';
    try {
      final matched = sourceList.firstWhere(
          (s) => s.name == sourceId || s.id?.toString() == sourceId);
      sourceId = matched.id?.toString() ?? sourceId;
    } catch (_) {}

    // Resolve industry name → ID
    String industryId = editableDetails!['company_industry']?.toString() ?? '';
    try {
      final matched = industryList.firstWhere(
          (i) => i.name == industryId || i.id?.toString() == industryId);
      industryId = matched.id?.toString() ?? industryId;
    } catch (_) {}

    Map<String, dynamic> body = {
      'opportunity_id': editableDetails!['opportunity_id']?.toString() ?? '',
      'lead_id': editableDetails!['id']?.toString() ?? '',
      'name': editableDetails!['name']?.toString() ?? '',
      'company': editableDetails!['company']?.toString() ?? '',
      'company_industry': industryId,
      'phonenumber': editableDetails!['phonenumber']?.toString() ?? '',
      'email': editableDetails!['email']?.toString() ?? '',
      'source': sourceId,
      'city': editableDetails!['city']?.toString() ?? '',
    };

    // Send recommended_programs IDs
    if (editableDetails!['recommended_programs'] is List) {
      List progs = editableDetails!['recommended_programs'];
      for (int i = 0; i < progs.length; i++) {
        var p = progs[i];
        String pId = p is Map
            ? p['program_id']?.toString() ?? p['id']?.toString() ?? ''
            : p.toString();
        body['recommended_programs[$i]'] = pId;
      }
    }

    if (editableDetails!['stage_data'] is Map) {
      Map? sd = editableDetails!['stage_data'];
      // proposal_sent → 1 or 0
      body['proposal_sent'] = (sd?['proposal_sent']?.toString() == 'true' ||
              sd?['proposal_sent']?.toString() == '1')
          ? '1'
          : '0';
      body['discovery_summary'] = sd?['discovery_summary']?.toString() ?? '';
      body['appointment'] = sd?['appointment']?.toString() ?? '';
      body['three_year_vision'] = sd?['three_year_vision']?.toString() ?? '';
      body['top_3_challenges'] = sd?['top_3_challenges']?.toString() ?? '';
      body['rmi_mode'] = sd?['rmi_mode']?.toString() ?? 'manual';
      // Arrays sent as JSON strings: ["Budget","Timeline"]
      body['roadblocks'] = _toJsonArray(sd?['roadblocks']);
      body['opportunities'] = _toJsonArray(sd?['opportunities']);
      body['capabilities'] = _toJsonArray(sd?['capabilities']);
    }

    print('DEBUG Approaching Body Payload: $body');
    ResponseModel responseModel = await repo.updateData(body);
    print('DEBUG Approaching API Response: ${responseModel.responseJson}');

    isUpdateLoading = false;
    update();

    if (responseModel.status == true) {
      Get.back();
      Get.snackbar('Success', 'Updated successfully.',
          snackPosition: SnackPosition.BOTTOM);
      loadData();
    } else {
      Get.snackbar('Error', responseModel.message,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Converts a List or comma-separated string into a JSON array string.
  /// e.g. ["Budget","Team","Marketing"]
  String _toJsonArray(dynamic raw) {
    if (raw == null) return '[]';
    List<String> items = [];
    if (raw is List) {
      items = raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      final str = raw.toString().trim();
      if (str.isEmpty) return '[]';
      // If it's already a JSON array string, return as-is
      if (str.startsWith('[')) return str;
      items = str
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    // Build JSON array string: ["item1","item2"]
    final encoded = items.map((e) => '"${e.replaceAll('"', '\\"')}"').join(',');
    return '[$encoded]';
  }

  bool isMoveLoading = false;

  Future<void> moveToNegotiation() async {
    if (details == null || details!['opportunity_id'] == null) return;

    isMoveLoading = true;
    update();

    ResponseModel responseModel =
        await repo.moveToNegotiation(details!['opportunity_id'].toString());

    isMoveLoading = false;
    update();

    if (responseModel.status == true) {
      Get.back();
      Get.snackbar('Success', 'Moved to Negotiation successfully.',
          snackPosition: SnackPosition.BOTTOM);
      loadData();
    } else {
      Get.snackbar('Error', responseModel.message,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
