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
import 'package:flutex_admin/features/goal/model/goal_detail_model.dart';
import 'package:flutex_admin/features/goal/view/goal_details_screen.dart';

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

  String? editingGoalId;

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

     Map<String, dynamic> body = {
       'subject': subject,
       'description': description,
       'achievement': achievement,
       'start_date': startDate,
       'end_date': endDate,
       'staff_id': selectedStaffId,
       'goal_type': selectedGoalType,
       'recurring': selectedRecurring, // Assuming recurring is handled if needed
       'type': selectedPeriod, 
       'notify_when_fail': '1', // Default per requirement/observation
       'notify_when_achieve': '1', // Default
       'contract_type': '0', // Default
     };

     ResponseModel response;
     if (editingGoalId != null) {
       body['id'] = editingGoalId;
       response = await goalRepo.updateGoal(body);
     } else {
       response = await goalRepo.createGoal(body);
     }

     if(response.status) {
       Get.back();
       CustomSnackBar.success(successList: [response.message ?? (editingGoalId != null ? 'Goal updated successfully' : 'Goal created successfully')]);
       if (selectedStaffId != null) {
          staffGoalsMap.remove(selectedStaffId!); // clear cache to reload
          loadStaffGoals(selectedStaffId!);
       }
       // If we were editing, we might want to refresh the details page too if we are still there, 
       // but typically we pop back. 
       // If we popped from AddGoalScreen, we are back at StaffGoalsScreen or GoalDetailsScreen.
       // If we navigated to AddGoalScreen from GoalDetailsScreen, we are back at GoalDetailsScreen.
       // We should refresh that too if possible.
       if (editingGoalId != null) {
          // Trigger a reload of details if we are viewing them
          // But since we navigate back, we might just want to reload the previous screen.
          // For now, let's just clear data.
       }
       clearData();
     } else {
       CustomSnackBar.error(errorList: [response.message ?? 'Failed to save goal']);
     }
     
     isSubmitLoading = false;
     update();
  }
  
  void setGoalForEdit(GoalDetailData goal) {
    editingGoalId = goal.id;
    subjectController.text = goal.subject ?? '';
    descriptionController.text = goal.description ?? '';
    achievementController.text = goal.target ?? '';
    startDateController.text = goal.startDate ?? '';
    endDateController.text = goal.endDate ?? '';
    selectedGoalType = goal.goalType;
    selectedStaffId = goal.staffId;
    selectedPeriod = goal.type ?? 'custom'; 
    // We might need to handle other fields like recurring if strictly required
    // but the prompt focused on basics.
  }

  void clearData() {
    editingGoalId = null;
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
    print('Loading Goal Screen (Fetching Staff List)...');
    ResponseModel responseModel = await staffRepo.getAllStaffs();
    if (!responseModel.status) {
      print('getAllStaffs failed, trying getSubordinates...');
      responseModel = await staffRepo.getSubordinates();
    }
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

  Future<void> loadGoalDetails(String goalId) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    
    ResponseModel responseModel = await goalRepo.getGoalDetails(goalId);
    Get.back(); // close loading

    if(responseModel.status){
       try {
         var decoded = jsonDecode(responseModel.responseJson);
         // Use the new GoalDetailModel
         GoalDetailModel model = GoalDetailModel.fromJson(decoded);
         
         if (model.data != null) {
            Get.to(() => GoalDetailsScreen(goal: model.data!, goalTypes: goalTypes));
         } else {
             CustomSnackBar.error(errorList: ['No goal data found']);
         }
       } catch (e) {
         print("Error parsing goal detail: $e");
         CustomSnackBar.error(errorList: ['Failed to parse goal details']);
       }
    } else {
       CustomSnackBar.error(errorList: [responseModel.message ?? 'Failed to load details']);
    }
  }

  Future<void> refreshGoalDetails(String goalId) async {
    ResponseModel responseModel = await goalRepo.getGoalDetails(goalId);
    if(responseModel.status){
       try {
         var decoded = jsonDecode(responseModel.responseJson);
         GoalDetailModel model = GoalDetailModel.fromJson(decoded);
         
         if (model.data != null) {
            // Replace current route with new data
            Get.off(() => GoalDetailsScreen(goal: model.data!, goalTypes: goalTypes), preventDuplicates: false);
         }
       } catch (e) {
         print("Error refreshing goal detail: $e");
         CustomSnackBar.error(errorList: ['Failed to refresh goal details']);
       }
    }
  }
}
