import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/spanco/order/controller/order_controller.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_drop_down_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Details',
                style: regularLarge.copyWith(color: Colors.white)),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              if (controller.details != null && !controller.isDetailsLoading)
                IconButton(
                  icon: Icon(controller.isEditing ? Icons.close : Icons.edit,
                      color: Colors.white),
                  onPressed: () => controller.toggleEditing(),
                ),
            ],
          ),
          body: controller.isDetailsLoading
              ? const CustomLoader()
              : controller.details == null
                  ? Center(
                      child: Text(
                        'Details not available',
                        style: regularDefault.copyWith(color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(Dimensions.space15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...controller.editableDetails!.entries
                              .where((e) =>
                                  e.key != 'opportunity_id' &&
                                  e.key != 'id' &&
                                  e.key != 'stage_data')
                              .map((entry) {
                            String stringVal = entry.value?.toString() ?? '-';
                            if (entry.key == 'recommended_programs' &&
                                entry.value is List) {
                              stringVal = (entry.value as List)
                                  .map((e) => e is Map
                                      ? e['name']?.toString() ?? ''
                                      : '')
                                  .where((e) => e.isNotEmpty)
                                  .join(', ');
                              if (stringVal.isEmpty) stringVal = '-';
                            }
                            return _buildDetailRow(
                                context, controller, entry.key, stringVal);
                          }),
                          if (controller.editableDetails!['stage_data'] is Map) ...[
                            const SizedBox(height: Dimensions.space10),
                            ...(controller.editableDetails!['stage_data'] as Map)
                                .entries
                                .where((e) => !['roadblocks', 'opportunities', 'capabilities', 'rmi_mode', 'rmi_attachment', 'follow_up_date'].contains(e.key))
                                .map((e) {
                              return _buildStageDataRow(context, controller, e.key, e.value);
                            })
                          ],
                          const SizedBox(height: Dimensions.space20),
                          if (controller.isEditing)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.space15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.space10)),
                              ),
                              onPressed: () { controller.updateData(); },
                              child: controller.isUpdateLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Update', style: regularLarge.copyWith(color: Colors.white)),
                            ),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, OrderController controller,
      String key, String value) {
    bool isReadOnly = !controller.isEditing ||
        key == 'assigned' || key == 'dateadded' || key == 'id' ||
        key == 'status' || key == 'recommended_programs';

    Widget valueWidget;

    if (isReadOnly) {
      String displayValue = value.isEmpty ? '-' : value;
      if (key == 'source') {
        try {
          var matched = controller.sourceList.firstWhere((s) => s.id?.toString() == value || s.name == value);
          displayValue = matched.name ?? displayValue;
        } catch (e) {}
      } else if (key == 'company_industry') {
        try {
          var matched = controller.industryList.firstWhere((i) => i.id?.toString() == value || i.name == value);
          displayValue = matched.name ?? displayValue;
        } catch (e) {}
      }
      valueWidget = Text(displayValue, style: regularDefault.copyWith(color: Colors.black87));
    } else if (key == 'company_industry' && controller.industryList.isNotEmpty) {
      valueWidget = CustomDropDownTextField(
        hintText: "Select Industry",
        needLabel: false,
        onChanged: (newValue) { if (newValue != null) controller.updateEditableField(key, newValue.toString()); },
        selectedValue: controller.industryList.any((i) => i.name == value) ? value : null,
        items: controller.industryList.map((industry) {
          return DropdownMenuItem<String>(value: industry.name, child: Text(industry.name ?? '', overflow: TextOverflow.ellipsis, style: regularDefault.copyWith(color: Colors.black)));
        }).toList(),
      );
    } else if (key == 'source' && controller.sourceList.isNotEmpty) {
      valueWidget = CustomDropDownTextField(
        hintText: "Select Source",
        needLabel: false,
        onChanged: (newValue) { if (newValue != null) controller.updateEditableField(key, newValue.toString()); },
        selectedValue: controller.sourceList.any((s) => s.name == value) ? value : null,
        items: controller.sourceList.map((src) {
          return DropdownMenuItem<String>(value: src.name, child: Text(src.name ?? '', overflow: TextOverflow.ellipsis, style: regularDefault.copyWith(color: Colors.black)));
        }).toList(),
      );
    } else {
      valueWidget = TextFormField(
        initialValue: value,
        decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        onChanged: (newValue) { controller.updateEditableField(key, newValue); },
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 2, child: Text(_formatKey(key), style: semiBoldDefault.copyWith(color: Colors.grey[800]))),
          const SizedBox(width: Dimensions.space10),
          Expanded(flex: 3, child: valueWidget),
        ],
      ),
    );
  }

  Widget _buildStageDataRow(BuildContext context, OrderController controller, String key, dynamic value) {
    if (!controller.isEditing) {
      String displayValue = value?.toString() ?? '-';
      if (displayValue.toLowerCase() == 'true') displayValue = 'Yes';
      if (displayValue.toLowerCase() == 'false') displayValue = 'No';
      if (displayValue.isEmpty) displayValue = '-';
      if (displayValue.contains('T') && displayValue.length >= 15) displayValue = displayValue.replaceAll('T', ' ');
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: Text(_formatKey(key), style: semiBoldDefault.copyWith(color: Colors.grey[800]))),
            const SizedBox(width: Dimensions.space10),
            Expanded(flex: 3, child: Text(displayValue, style: regularDefault.copyWith(color: Colors.black87))),
          ],
        ),
      );
    }

    Widget valueWidget = const SizedBox();

    if (['man_identified', 'money_identified', 'authority_identified', 'need_identified', 'proposal_sent'].contains(key)) {
      bool isChecked = value?.toString().toLowerCase() == 'true';
      valueWidget = Align(alignment: Alignment.centerLeft, child: Checkbox(value: isChecked, activeColor: Theme.of(context).primaryColor, onChanged: (val) { controller.updateStageDataField(key, val); }));
    } else if (key == 'appointment') {
      valueWidget = InkWell(
        onTap: () async {
          DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime(2100));
          if (picked != null) {
            TimeOfDay? timePicked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            if (timePicked != null) {
              DateTime finalDate = DateTime(picked.year, picked.month, picked.day, timePicked.hour, timePicked.minute);
              String dateFormatted = finalDate.year.toString().padLeft(4, '0') + "-" + finalDate.month.toString().padLeft(2, '0') + "-" + finalDate.day.toString().padLeft(2, '0') + "T" + finalDate.hour.toString().padLeft(2, '0') + ":" + finalDate.minute.toString().padLeft(2, '0');
              controller.updateStageDataField(key, dateFormatted);
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
          child: Text(value?.toString().isEmpty ?? true ? 'Select Date & Time' : value.toString().replaceAll('T', ' '), style: regularDefault),
        ),
      );
    } else if (['need_description', 'discovery_summary', 'three_year_vision', 'top_3_challenges'].contains(key)) {
      valueWidget = TextFormField(initialValue: value?.toString() ?? '', maxLines: 4, decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), onChanged: (val) => controller.updateStageDataField(key, val));
    } else {
      valueWidget = TextFormField(initialValue: value?.toString() ?? '', decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), onChanged: (val) => controller.updateStageDataField(key, val));
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(flex: 2, child: Text(_formatKey(key), style: semiBoldDefault.copyWith(color: Colors.grey[800]))),
        const SizedBox(width: Dimensions.space10),
        Expanded(flex: 3, child: valueWidget),
      ]),
    );
  }

  String _formatKey(String key) {
    if (key.isEmpty) return key;
    String formatted = key.replaceAll('_', ' ');
    return formatted[0].toUpperCase() + formatted.substring(1);
  }
}
