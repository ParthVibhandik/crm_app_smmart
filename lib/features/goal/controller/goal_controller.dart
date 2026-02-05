import 'dart:convert';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/staff/model/staff_model.dart';
import 'package:flutex_admin/features/staff/repo/staff_repo.dart';
import 'package:flutex_admin/features/goal/repo/goal_repo.dart';
import 'package:flutex_admin/features/goal/model/staff_goals_model.dart';
import 'package:flutex_admin/features/dashboard/model/dashboard_model.dart';
import 'package:flutex_admin/features/goal/model/create_goal_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';

class GoalController extends GetxController {
  final StaffRepo staffRepo;
  GoalRepo goalRepo;
  GoalController({required this.staffRepo, required this.goalRepo});

  StaffsModel staffsModel = StaffsModel();
  Map<String, List<Goal>> staffGoalsMap = {};
  Map<String, bool> staffLoadingMap = {};
  bool isLoading = true;
  bool isSubmitLoading = false;

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController achievementController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  
  String? selectedGoalType;
  String? selectedStaffId;
  String? selectedRecurring = '0'; 
  String selectedPeriod = 'custom';

  // Common Perfex Goal Types
  final Map<String, String> goalTypes = {
    '1': 'Total Income',
    '8': 'Invoiced Amount',
    '2': 'Leads Converted',
    '3': 'Customers Without Leads Conversions',
    '4': 'Customers With Leads Conversions',
    '5': 'Make Contracts By Type',
    '7': 'Make Contracts By Type Date',
    '6': 'Total Estimates Converted',
  };

  final Map<String, String> goalPeriods = {
    'custom': 'Custom',
    'ytd': 'YTD (Year To Date)',
    'mtd': 'MTD (Month To Date)',
  };

  Future<void> createGoal() async {
     String subject = subjectController.text;
     String description = descriptionController.text;
     String achievement = achievementController.text;
     String startDate = startDateController.text;
     String endDate = endDateController.text;

     if(subject.isEmpty || selectedGoalType == null || selectedStaffId == null || startDate.isEmpty || endDate.isEmpty) {
       CustomSnackBar.error(errorList: ['Please fill all required fields']);
       return;
     }

     isSubmitLoading = true;
     update();

     CreateGoalModel model = CreateGoalModel(
       subject: subject,
       description: description,
       achievement: achievement,
       startDate: startDate,
       endDate: endDate,
       staffId: selectedStaffId,
       goalType: selectedGoalType,
       recurring: selectedRecurring,
       type: selectedPeriod, 
     );

     ResponseModel response = await goalRepo.createGoal(model.toJson());
     if(response.status) {
       Get.back();
       CustomSnackBar.success(successList: [response.message ?? 'Goal created successfully']);
       if (selectedStaffId != null) {
          staffGoalsMap.remove(selectedStaffId!); // clear cache to reload
          loadStaffGoals(selectedStaffId!);
       }
       clearData();
     } else {
       CustomSnackBar.error(errorList: [response.message ?? 'Failed to create goal']);
     }
     
     isSubmitLoading = false;
     update();
  }

  void clearData() {
    subjectController.clear();
    descriptionController.clear();
    achievementController.clear();
    startDateController.clear();
    endDateController.clear();
    selectedGoalType = null;
    selectedStaffId = null;
    selectedRecurring = '0';
    selectedPeriod = 'custom';
  }

  Future<void> loadGoals() async {
    isLoading = true;
    update();
    ResponseModel responseModel = await staffRepo.getAllStaffs();
    if(responseModel.status){
       staffsModel = StaffsModel.fromJson(jsonDecode(responseModel.responseJson));
    }
    isLoading = false;
    update();
  }

  Future<void> loadStaffGoals(String staffId) async {
    if (staffGoalsMap.containsKey(staffId)) return; // Already loaded

    staffLoadingMap[staffId] = true;
    update();
    
    ResponseModel responseModel = await goalRepo.getStaffGoals(staffId);
    if(responseModel.status){
       StaffGoalsModel model = StaffGoalsModel.fromJson(jsonDecode(responseModel.responseJson));
       if (model.goals != null) {
         staffGoalsMap[staffId] = model.goals!;
       }
    }
    
    staffLoadingMap[staffId] = false;
    update();
  }
}
