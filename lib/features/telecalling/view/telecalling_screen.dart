import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/buttons/rounded_button.dart';
import 'package:flutex_admin/common/components/buttons/rounded_loading_button.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/route/route.dart';
import 'package:flutex_admin/features/telecalling/controller/telecalling_controller.dart';
import 'package:flutex_admin/features/telecalling/repo/telecalling_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutex_admin/features/lead/model/lead_model.dart';

class TelecallingScreen extends StatefulWidget {
  const TelecallingScreen({super.key});

  @override
  State<TelecallingScreen> createState() => _TelecallingScreenState();
}

class _TelecallingScreenState extends State<TelecallingScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(TelecallingRepo(apiClient: Get.find()));
    Get.put(TelecallingController(telecallingRepo: Get.find()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Manual Telecalling"),
      body: GetBuilder<TelecallingController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.space15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lead Name",
                  style: regularDefault.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Dimensions.space10),
                if (controller.isLoadingAssignedLeads)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ))
                else if (controller.assignedLeads.isEmpty)
                   Container(
                     padding: const EdgeInsets.all(12),
                     width: double.infinity,
                     decoration: BoxDecoration(
                       border: Border.all(color: Colors.grey.shade300),
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: const Text("No assigned leads found."),
                   )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Lead>(
                        isExpanded: true,
                        hint: const Text("Select Lead"),
                        value: controller.selectedLead,
                        items: controller.assignedLeads.map((Lead lead) {
                          return DropdownMenuItem<Lead>(
                            value: lead,
                            child: Text(
                              "${lead.name ?? 'Unknown'} ${lead.company != null ? '(${lead.company})' : ''}",
                              overflow: TextOverflow.ellipsis,
                              style: regularDefault,
                            ),
                          );
                        }).toList(),
                        onChanged: (Lead? newValue) {
                          if (newValue != null) {
                            controller.selectLead(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: Dimensions.space20),
                Text(
                  "Duration (Minutes)",
                  style: regularDefault.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Dimensions.space10),
                CustomTextField(
                    controller: controller.durationController,
                    hintText: "Enter duration in mins",
                    onChanged: (value) {},
                    textInputType: TextInputType.number),
                const SizedBox(height: Dimensions.space20),
                Text(
                  "Lead Status",
                  style: regularDefault.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Dimensions.space10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: controller.selectedStatus,
                      items: controller.statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.capitalizeFirst!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) controller.setStatus(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.space20),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.description),
                        label: const Text('Proposals'),
                        onPressed: () {
                          Get.toNamed(RouteHelper.proposalScreen);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.receipt),
                        label: const Text('Invoices'),
                        onPressed: () {
                          Get.toNamed(RouteHelper.invoiceScreen);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.space20),

                if (controller.isLoadingInvoices)
                   const Center(child: LinearProgressIndicator())
                else if (controller.invoices.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Link Created Invoice (Optional)", style: regularDefault.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: Dimensions.space10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: controller.selectedInvoiceId,
                            hint: const Text("Select Invoice"),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text("None (Do not send any invoice)"),
                              ),
                              ...controller.invoices.take(50).map((inv) {
                                return DropdownMenuItem<String>(
                                  value: inv.id,
                                  child: Text(
                                    "${inv.prefix ?? ''}${inv.number ?? ''} - ${inv.clientName ?? 'Unknown'} - ${inv.total ?? ''} (${inv.date ?? ''})",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              }),
                            ].toList(),
                            onChanged: (val) {
                               controller.setInvoiceId(val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.space20),
                    ],
                  ),
                Text(
                  "Remarks",
                  style: regularDefault.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Dimensions.space10),
                CustomTextField(
                  controller: controller.remarksController,
                  hintText: "Enter call remarks...",
                  onChanged: (value) {},
                  maxLines: 3,
                ),
                const SizedBox(height: Dimensions.space30),
                controller.isSubmitLoading
                    ? const RoundedLoadingBtn()
                    : RoundedButton(
                        text: "Submit Record",
                        press: () {
                          controller.submitTelecall();
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
