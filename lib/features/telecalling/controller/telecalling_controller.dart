import 'dart:convert';
import 'package:flutex_admin/common/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutex_admin/common/models/response_model.dart';
import 'package:flutex_admin/features/lead/model/lead_model.dart';
import 'package:flutex_admin/features/telecalling/repo/telecalling_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutex_admin/features/telecalling/widget/success_dialog.dart';
import 'package:flutex_admin/features/invoice/model/invoice_model.dart';
import 'package:flutex_admin/features/invoice/repo/invoice_repo.dart';
import 'package:flutex_admin/core/service/api_service.dart';

class TelecallingController extends GetxController {
  final TelecallingRepo telecallingRepo;
  late InvoiceRepo invoiceRepo;
  
  TelecallingController({required this.telecallingRepo}) {
     _ensureInvoiceRepo();
     _loadInvoices();
     loadAssignedLeads();
  }
  
  void _ensureInvoiceRepo() {
    try {
      invoiceRepo = Get.find<InvoiceRepo>();
    } catch (_) {
      invoiceRepo = InvoiceRepo(apiClient: Get.find<ApiClient>());
    }
  }

  bool isLoading = false;
  bool isSubmitLoading = false;
  
  List<Lead> searchResultLeads = [];
  Lead? selectedLead;
  
  TextEditingController searchController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  
  String selectedStatus = 'hot';
  List<String> statusOptions = ['hot', 'warm', 'cold', 'converted', 'lost'];
  
  List<Invoice> invoices = [];
  String? selectedInvoiceId;
  bool isLoadingInvoices = false;

  Future<void> _loadInvoices() async {
    isLoadingInvoices = true;
    update();
    try {
      final response = await invoiceRepo.getAllInvoices();
      if (response.status) {
        final model = InvoicesModel.fromJson(jsonDecode(response.responseJson));
        if (model.data != null) {
          List<Invoice> sortedInvoices = model.data!;
          // Sort by ID descending (newest first)
          sortedInvoices.sort((a, b) {
             return (int.tryParse(b.id ?? '0') ?? 0).compareTo(int.tryParse(a.id ?? '0') ?? 0);
          });
          invoices = sortedInvoices;
        }
      }
    } catch (e) {
      print('Error loading invoices in telecalling: $e');
    }
    isLoadingInvoices = false;
    update();
  }
  
  void setInvoiceId(String? id) {
    selectedInvoiceId = id;
    update();
  }

  List<Lead> assignedLeads = [];
  bool isLoadingAssignedLeads = false;

  Future<void> loadAssignedLeads() async {
    isLoadingAssignedLeads = true;
    update();

    try {
      final responseModel = await telecallingRepo.getAssignedLeads();
      if (responseModel.status) {
        var decoded = jsonDecode(responseModel.responseJson);
        List<dynamic> leadsList = [];
        
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          var dataObj = decoded['data'];
          if (dataObj is Map<String, dynamic>) {
             if (dataObj.containsKey('leads') && dataObj['leads'] is List) {
               leadsList = dataObj['leads'];
             }
          } else if (dataObj is List) {
            leadsList = dataObj;
          }
        } else if (decoded is List) {
          leadsList = decoded;
        }

        assignedLeads = leadsList.map((item) => Lead.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading assigned leads: $e');
    }

    isLoadingAssignedLeads = false;
    update();
  }

  Future<void> searchLeads(String keyword) async {
    if (keyword.isEmpty) {
      searchResultLeads = [];
      update();
      return;
    }

    isLoading = true;
    update();

    try {
      ResponseModel responseModel = await telecallingRepo.searchLeads(keyword);
      if (responseModel.status) {
        var decoded = jsonDecode(responseModel.responseJson);
        List<dynamic> leadsList = [];
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          var dataObj = decoded['data'];
          if (dataObj is Map<String, dynamic> && dataObj.containsKey('leads')) {
            leadsList = dataObj['leads'];
          } else if (dataObj is List) {
            leadsList = dataObj;
          }
        }
        
        searchResultLeads = leadsList.map((item) => Lead.fromJson(item)).toList();
      } else {
        CustomSnackBar.error(errorList: [responseModel.message.tr]);
      }
    } catch (e) {
      print('Error searching leads: $e');
    }

    isLoading = false;
    update();
  }

  void selectLead(Lead lead) {
    selectedLead = lead;
    searchController.text = lead.name ?? '';
    searchResultLeads = [];
    update();
  }

  void setStatus(String status) {
    selectedStatus = status;
    update();
  }

  Future<void> submitTelecall() async {
    if (selectedLead == null) {
      CustomSnackBar.error(errorList: ['Please select a lead']);
      return;
    }
    if (durationController.text.isEmpty) {
      CustomSnackBar.error(errorList: ['Please enter duration']);
      return;
    }
    if (remarksController.text.isEmpty) {
      CustomSnackBar.error(errorList: ['Please enter remarks']);
      return;
    }

    isSubmitLoading = true;
    update();

    try {
      ResponseModel responseModel = await telecallingRepo.recordTelecall(
        leadId: selectedLead!.id.toString(),
        duration: durationController.text,
        status: selectedStatus,
        remarks: remarksController.text,
        invoiceId: selectedInvoiceId,
      );

      if (responseModel.status) {
        Get.dialog(
          SuccessDialog(
            message: "Telecall record has been saved successfully.",
            onOkPress: () {
              clearData();
              Get.back(); // Close dialog
              Get.back(); // Go back from telecalling screen
            },
          ),
          barrierDismissible: false,
        );
      } else {
        CustomSnackBar.error(errorList: [responseModel.message.tr]);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: ['Error recording telecall: $e']);
    }

    isSubmitLoading = false;
    update();
  }

  void clearData() {
    selectedLead = null;
    searchController.clear();
    durationController.clear();
    remarksController.clear();
    selectedStatus = 'hot';
    selectedInvoiceId = null;
    searchResultLeads = [];
    update();
  }
}
