import 'dart:convert';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/dcr/model/dcr_model.dart';
import 'package:flutex_admin/features/dcr/repo/dcr_repo.dart';
import 'package:get/get.dart';

class DCRController extends GetxController {
  final DCRRepo dcrRepo;
  DCRController({required this.dcrRepo});

  bool isLoading = true;
  List<DCRModel> dcrList = [];
  int totalCalls = 0;
  int f2fCalls = 0;
  int telecallCount = 0;

  @override
  void onInit() {
    super.onInit();
    loadDCR();
  }

  Future<void> loadDCR() async {
    isLoading = true;
    update();

    try {
      ResponseModel responseModel = await dcrRepo.getDCR();
      if (responseModel.status) {
        var decoded = jsonDecode(responseModel.responseJson);
        if (decoded['status'] == true && decoded['data'] != null) {
          var data = decoded['data'];
          if (data is Map<String, dynamic> && data.containsKey('items')) {
            List<dynamic> dataList = data['items'];
            dcrList = dataList.map((item) => DCRModel.fromJson(item)).toList();

            if (data.containsKey('summary')) {
              var summary = data['summary'];
              totalCalls =
                  int.tryParse(summary['total_calls']?.toString() ?? '0') ?? 0;
              f2fCalls = int.tryParse(summary['f2f']?.toString() ?? '0') ?? 0;
              telecallCount =
                  int.tryParse(summary['telecall']?.toString() ?? '0') ?? 0;
            }
          } else if (data is List) {
            dcrList = data.map((item) => DCRModel.fromJson(item)).toList();
          }
        }
      }
    } catch (e) {
      print('Error loading DCR: $e');
    }

    isLoading = false;
    update();
  }
}
