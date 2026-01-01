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
                Stack(
                  children: [
                    CustomTextField(
                      controller: controller.searchController,
                      hintText: "Search lead by name...",
                      onChanged: (value) {
                        controller.searchLeads(value);
                      },
                    ),
                    if (controller.searchResultLeads.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                            )
                          ],
                        ),
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.searchResultLeads.length,
                          itemBuilder: (context, index) {
                            final lead = controller.searchResultLeads[index];
                            return ListTile(
                              title: Text(lead.name ?? ''),
                              subtitle: Text(lead.company ?? ''),
                              onTap: () {
                                controller.selectLead(lead);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
                if (controller.selectedLead != null) ...[
                  const SizedBox(height: Dimensions.space5),
                  Chip(
                    label: Text("Selected: ${controller.selectedLead!.name}"),
                    onDeleted: () {
                      controller.clearData();
                    },
                  ),
                ],
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
