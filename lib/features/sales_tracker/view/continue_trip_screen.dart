import 'package:flutex_admin/common/components/app-bar/custom_appbar.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_text_field.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:flutex_admin/features/lead/model/lead_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContinueTripScreen extends StatefulWidget {
  final Lead lead;
  const ContinueTripScreen({super.key, required this.lead});

  @override
  State<ContinueTripScreen> createState() => _ContinueTripScreenState();
}

class _ContinueTripScreenState extends State<ContinueTripScreen> {
  final TextEditingController _manualAddressController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool isManualAddress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Trip Details"), // Simplified title
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard("Name", widget.lead.name ?? 'Unknown'),
            const SizedBox(height: 10),
            _buildInfoCard("Address", widget.lead.address ?? 'No Address'),
            const SizedBox(height: 10),
            _buildInfoCard("Phone", widget.lead.phoneNumber ?? 'No Phone'),
            const SizedBox(height: 20),
            
            // Manual Address Toggle
            Row(
              children: [
                Checkbox(
                  value: isManualAddress,
                  onChanged: (val) {
                    setState(() {
                      isManualAddress = val ?? false;
                    });
                  },
                ),
                const Text("Enter Manual Address"),
              ],
            ),

            if (isManualAddress) ...[
              const SizedBox(height: 10),
              CustomTextField(
                controller: _manualAddressController,
                labelText: "New Address",
                hintText: "Enter alternate address",
                maxLines: 2,
                onChanged: (val) {},
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _reasonController,
                labelText: "Reason",
                hintText: "Why are you changing the address?",
                maxLines: 2,
                onChanged: (val) {},
              ),
            ],

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isManualAddress && _manualAddressController.text.trim().isEmpty) {
                    Get.snackbar("Error", "Please enter the manual address");
                    return;
                  }
                   if (isManualAddress && _reasonController.text.trim().isEmpty) {
                    Get.snackbar("Error", "Please enter a reason for changing the address");
                    return;
                  }
                  
                  // Proceed with trip start
                  Get.back();
                  Get.snackbar("Success", "Trip started for ${widget.lead.name}");
                  // TODO: Call controller to actually start logic/API
                },
                child: const Text("Start Trip"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
