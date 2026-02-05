import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/core/utils/url_container.dart';
import 'package:flutex_admin/features/lead/controller/lead_details_controller.dart';
import 'package:flutex_admin/features/lead/model/kanban_lead_model.dart';
import 'package:flutex_admin/features/lead/model/lead_create_model.dart';
import 'package:flutex_admin/features/lead/model/lead_details_model.dart';
import 'package:flutex_admin/features/lead/model/lead_model.dart';
import 'package:flutex_admin/features/lead/model/sources_model.dart';
import 'package:flutex_admin/features/lead/model/statuses_model.dart';
import 'package:flutex_admin/features/lead/repo/lead_repo.dart';
import 'package:flutex_admin/features/staff/model/staff_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class LeadController extends GetxController {
  LeadRepo leadRepo;
  LeadController({required this.leadRepo});

  bool isLoading = true;
  bool isSubmitLoading = false;
  bool showFab = true;
  ScrollController scrollController = ScrollController();
  LeadsModel leadsModel = LeadsModel();
  final leads = <Lead>[].obs;
  int page = 0;
  String? sortBy;
  String? source;
  String? status;
  bool hasMoreData = true;
  LeadDetailsModel leadDetailsModel = LeadDetailsModel();
  KanbanLeadModel kanbanLeadModel = KanbanLeadModel();

  StatusesModel statusesModel = StatusesModel();
  SourcesModel sourcesModel = SourcesModel();
  StaffsModel staffsModel = StaffsModel();
  SourcesModel industriesModel = SourcesModel();
  SourcesModel designationsModel = SourcesModel();
  SourcesModel interestedInModel = SourcesModel();

  void handleScroll() async {
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (showFab) {
          showFab = false;
          update();
        }
      }
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!showFab) {
          showFab = true;
          update();
        }
      }
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        // Load more data when the user reaches the bottom of the list
        if (hasMoreData) {
          loadLeads(page: ++page);
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  Future<void> initialData({bool shouldLoad = true}) async {
    isLoading = shouldLoad ? true : false;
    update();
    leads.clear();
    page = 0;
    hasMoreData = true;
    await loadLeads();
    isLoading = false;
    update();
  }

  Future<void> loadLeads({int page = 0}) async {
    ResponseModel responseModel = await leadRepo.getAllLeads(
      page: page,
      sort: sortBy,
      source: source,
      status: status,
    );
    final raw = responseModel.responseJson;

    if (raw.isEmpty) {
      hasMoreData = false;
      isLoading = false;
      update();
      return;
    }

    try {
      leadsModel = LeadsModel.fromJson(jsonDecode(raw));
      if (responseModel.status) {
        leads.addAll(leadsModel.data ?? []);
        if ((leadsModel.data?.length ?? 0) < int.parse(UrlContainer.limit)) {
          hasMoreData = false;
        }
      } else {
        hasMoreData = false;
      }
    } catch (e) {
      hasMoreData = false;
      CustomSnackBar.error(errorList: [LocalStrings.somethingWentWrong.tr]);
    }

    isLoading = false;
    update();
  }

  Future<void> loadKanbanLeads() async {
    ResponseModel responseModel = await leadRepo.getKanbanLeads();
    if (responseModel.status) {
      kanbanLeadModel = KanbanLeadModel.fromJson(
        jsonDecode(responseModel.responseJson),
      );
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  Future<StatusesModel> loadLeadStatuses() async {
    ResponseModel responseModel = await leadRepo.getLeadStatuses();
    return statusesModel = StatusesModel.fromJson(
      jsonDecode(responseModel.responseJson),
    );
  }

  Future<SourcesModel> loadLeadSources() async {
    ResponseModel responseModel = await leadRepo.getLeadSources();
    return sourcesModel = SourcesModel.fromJson(
      jsonDecode(responseModel.responseJson),
    );
  }

  Future<StaffsModel> loadStaff() async {
    ResponseModel responseModel = await leadRepo.getStaff();
    return staffsModel = StaffsModel.fromJson(
      jsonDecode(responseModel.responseJson),
    );
  }

  Future<SourcesModel> loadIndustries() async {
    ResponseModel responseModel = await leadRepo.getLeadIndustries();
    return industriesModel = SourcesModel.fromJson(
      jsonDecode(responseModel.responseJson),
    );
  }

  Future<SourcesModel> loadDesignations() async {
    ResponseModel responseModel = await leadRepo.getLeadDesignations();
    return designationsModel = SourcesModel.fromJson(
      jsonDecode(responseModel.responseJson),
    );
  }

  Future<SourcesModel> loadInterestedIn() async {
    ResponseModel responseModel = await leadRepo.getLeadInterestedIn();
    return interestedInModel = SourcesModel.fromJson(
      jsonDecode(responseModel.responseJson),
    );
  }

  Future<void> loadLeadUpdateData(leadId) async {
    ResponseModel responseModel = await leadRepo.getLeadDetails(leadId);
    if (responseModel.status) {
      leadDetailsModel = LeadDetailsModel.fromJson(
        jsonDecode(responseModel.responseJson),
      );
      sourceController.text = leadDetailsModel.data?.source ?? '';
      statusController.text = leadDetailsModel.data?.status ?? '';
      nameController.text = leadDetailsModel.data?.name ?? '';
      assignedController.text = leadDetailsModel.data?.assigned ?? '';
      valueController.text = leadDetailsModel.data?.leadValue ?? '';
      titleController.text = leadDetailsModel.data?.title ?? '';
      emailController.text = leadDetailsModel.data?.email ?? '';
      websiteController.text = leadDetailsModel.data?.website ?? '';
      phoneNumberController.text = leadDetailsModel.data?.phoneNumber ?? '';
      companyController.text = leadDetailsModel.data?.company ?? '';
      addressController.text = leadDetailsModel.data?.address ?? '';
      cityController.text = leadDetailsModel.data?.city ?? '';
      stateController.text = leadDetailsModel.data?.state ?? '';
      countryController.text = leadDetailsModel.data?.country ?? '';
      defaultLanguageController.text =
          leadDetailsModel.data?.defaultLanguage ?? '';
      descriptionController.text = leadDetailsModel.data?.description ?? '';
      isPublicController.text = leadDetailsModel.data?.isPublic ?? '';
      
      companyIndustryController.text = leadDetailsModel.data?.companyIndustry ?? '';
      campaignController.text = leadDetailsModel.data?.campaign ?? '';
      designationController.text = leadDetailsModel.data?.designation ?? leadDetailsModel.data?.title ??  '';
      zipController.text = leadDetailsModel.data?.zip ?? '';
      alternatePhoneNumberController.text = leadDetailsModel.data?.alternatePhoneNumber ?? '';
      // Use names for display if available, otherwise just keep it empty to let UI update it later or use fallback
      interestedInController.text = leadDetailsModel.data?.interestedIn ?? ''; 
      
      print("Update Data - Raw InterestedIn: ${leadDetailsModel.data?.interestedIn}");
      print("Update Data - Raw InterestedInId: ${leadDetailsModel.data?.interestedInId}");

      if (leadDetailsModel.data?.interestedInId != null && leadDetailsModel.data!.interestedInId!.isNotEmpty) {
        selectedInterestedInIds = leadDetailsModel.data!.interestedInId!.split(',');
      } else {
        selectedInterestedInIds = [];
      }
      print("Update Data - Parsed Ids: $selectedInterestedInIds");
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }
    isLoading = false;
    update();
  }

  TextEditingController sourceController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController assignedController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController defaultLanguageController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController isPublicController = TextEditingController();
  
  TextEditingController companyIndustryController = TextEditingController();
  TextEditingController campaignController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController alternatePhoneNumberController = TextEditingController();
  TextEditingController interestedInController = TextEditingController();

  FocusNode nameFocusNode = FocusNode();
  FocusNode assignedFocusNode = FocusNode();
  FocusNode tagsFocusNode = FocusNode();
  FocusNode valueFocusNode = FocusNode();
  FocusNode titleFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode websiteFocusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode companyFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();
  FocusNode defaultLanguageFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  FocusNode isPublicFocusNode = FocusNode();
  
  FocusNode campaignFocusNode = FocusNode();
  FocusNode zipFocusNode = FocusNode();
  FocusNode alternatePhoneNumberFocusNode = FocusNode();

  List<String> selectedInterestedInIds = [];

  Future<void> submitLead({String? leadId, bool isUpdate = false}) async {
    String source = sourceController.text.toString();
    String status = statusController.text.toString();
    String name = nameController.text.toString();
    String assigned = assignedController.text.toString();
    String tags = tagsController.text.toString();
    String value = valueController.text.toString();
    String title = titleController.text.toString();
    String email = emailController.text.toString();
    String website = websiteController.text.toString();
    String phoneNumber = phoneNumberController.text.toString().replaceAll(RegExp(r'\D'), '');
    String company = companyController.text.toString();
    String address = addressController.text.toString();
    String city = cityController.text.toString();
    String state = stateController.text.toString();
    String country = countryController.text.toString();
    String defaultLanguage = defaultLanguageController.text.toString();
    String description = descriptionController.text.toString();
    String isPublic = isPublicController.text.toString();
    
    String companyIndustry = companyIndustryController.text.toString();
    String campaign = campaignController.text.toString();
    String designation = designationController.text.toString();
    String zip = zipController.text.toString();
    String alternatePhoneNumber = alternatePhoneNumberController.text.toString().replaceAll(RegExp(r'\D'), '');
    // String interestedIn = selectedInterestedInIds.join(',');

    if (source.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.pleaseSelectSource.tr]);
      return;
    }
    if (status.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterStatus.tr]);
      return;
    }
    if (assigned.isEmpty) {
      CustomSnackBar.error(errorList: ["Please select assigned staff"]);
      return;
    }
    if (name.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterName.tr]);
      return;
    }
    if (company.isEmpty) {
      CustomSnackBar.error(errorList: ["Please enter company name"]);
      return;
    }
    if (companyIndustry.isEmpty) {
      CustomSnackBar.error(errorList: ["Please select company industry"]);
      return;
    }
    if (designation.isEmpty) {
      CustomSnackBar.error(errorList: ["Please select designation"]);
      return;
    }
    if (email.isEmpty) {
      CustomSnackBar.error(errorList: [LocalStrings.enterEmail.tr]);
      return;
    }
    if (!GetUtils.isEmail(email)) {
      CustomSnackBar.error(errorList: ["Please enter a valid email address"]);
      return;
    }
    if (address.isEmpty) {
      CustomSnackBar.error(errorList: ["Please enter address"]);
      return;
    }
    if (phoneNumber.isEmpty) {
      CustomSnackBar.error(errorList: ["Please enter phone number"]);
      return;
    }
    if (phoneNumber.length < 10) {
      CustomSnackBar.error(errorList: ["Phone number must be at least 10 digits"]);
      return;
    }
    if (phoneNumber.length > 15) {
      CustomSnackBar.error(errorList: ["Phone number cannot be more than 15 digits"]);
      return;
    }
    if (alternatePhoneNumber.isNotEmpty) {
      if (alternatePhoneNumber.length < 10) {
        CustomSnackBar.error(errorList: ["Alternate phone number must be at least 10 digits"]);
        return;
      }
      if (alternatePhoneNumber.length > 15) {
        CustomSnackBar.error(errorList: ["Alternate phone number cannot be more than 15 digits"]);
        return;
      }
    }
    if (selectedInterestedInIds.isEmpty) {
      print("Validation Failed. Selected IDs: $selectedInterestedInIds");
      CustomSnackBar.error(errorList: ["Please select interested in"]);
      return;
    }

    isSubmitLoading = true;
    update();

    LeadCreateModel leadModel = LeadCreateModel(
      source: source,
      status: status,
      name: name,
      assigned: assigned,
      tags: tags,
      value: value,
      title: title,
      email: email,
      website: website,
      phoneNumber: phoneNumber,
      company: company,
      address: address,
      city: city,
      state: state,
      country: country,
      defaultLanguage: defaultLanguage,
      description: description,
      isPublic: isPublic,
      companyIndustry: companyIndustry,
      campaign: campaign,
      designation: designation,
      zip: zip,
      alternatePhoneNumber: alternatePhoneNumber,
      interestedIn: selectedInterestedInIds,
    );

    ResponseModel responseModel = await leadRepo.createLead(
      leadModel,
      leadId: leadId,
      isUpdate: isUpdate,
    );
    if (responseModel.status) {
      clearData();
      Get.back();
      if (isUpdate) {
        await Get.find<LeadDetailsController>().loadLeadDetails(leadId);
      }
      await initialData();
      CustomSnackBar.success(successList: [responseModel.message.tr]);
    } else {
      CustomSnackBar.error(errorList: [responseModel.message.tr]);
    }

    isSubmitLoading = false;
    update();
  }

  // Search Leads
  TextEditingController searchController = TextEditingController();
  String keysearch = "";

  Future<void> searchLead() async {
    keysearch = searchController.text;
    ResponseModel responseModel = await leadRepo.searchLead(keysearch);
    leadsModel = LeadsModel.fromJson(jsonDecode(responseModel.responseJson));
    leads.assignAll(leadsModel.data ?? []);
    hasMoreData = false;
    isLoading = false;
    update();
  }

  bool isSearch = false;
  void changeSearchIcon() {
    isSearch = !isSearch;
    update();

    if (!isSearch) {
      searchController.clear();
      keysearch = "";
      initialData();
    }
  }

  Future<void> fetchAddressFromPincode(String pincode) async {
    if (pincode.length != 6) return;

    try {
      final response = await http.get(Uri.parse('https://api.postalpincode.in/pincode/$pincode'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty && data[0]['Status'] == 'Success') {
          final postOffice = data[0]['PostOffice'][0];
          
          cityController.text = postOffice['District'] ?? postOffice['Block'] ?? '';
          stateController.text = postOffice['State'] ?? '';
          countryController.text = postOffice['Country'] ?? '';
          
          if (countryController.text.toLowerCase() == 'india') {
            String code = "+91 ";
            if (!phoneNumberController.text.trim().startsWith('+91')) {
                 phoneNumberController.text = code + phoneNumberController.text;
            }
             if (alternatePhoneNumberController.text.isNotEmpty && !alternatePhoneNumberController.text.trim().startsWith('+91')) {
                 alternatePhoneNumberController.text = code + alternatePhoneNumberController.text;
             }
          }
          update();
        }
      }
    } catch (e) {
      print('Error fetching pincode: $e');
    }
  }

  void clearData() {
    isLoading = false;
    isSubmitLoading = false;
    sourceController.text = '';
    statusController.text = '';
    nameController.text = '';
    assignedController.text = '';
    tagsController.text = '';
    valueController.text = '';
    titleController.text = '';
    emailController.text = '';
    websiteController.text = '';
    phoneNumberController.text = '';
    companyController.text = '';
    addressController.text = '';
    cityController.text = '';
    stateController.text = '';
    countryController.text = '';
    defaultLanguageController.text = '';
    descriptionController.text = '';
    isPublicController.text = '';
    companyIndustryController.text = '';
    campaignController.text = '';
    designationController.text = '';
    zipController.text = '';
    alternatePhoneNumberController.text = '';
    interestedInController.text = '';
    selectedInterestedInIds.clear();
  }
}
