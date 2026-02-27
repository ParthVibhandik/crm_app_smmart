import 'package:flutex_admin/common/components/custom_loader/custom_loader.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/spanco/approaching/controller/approaching_controller.dart';
import 'package:flutex_admin/features/spanco/approaching/view/rmi_plan_screen.dart';
import 'package:flutex_admin/common/components/text-form-field/custom_drop_down_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApproachingDetailsScreen extends StatelessWidget {
  const ApproachingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ApproachingController>(
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
                      child: Text('Details not available',
                          style: regularDefault.copyWith(color: Colors.grey)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(Dimensions.space15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Regular top-level fields ─────────────────────
                          ...controller.editableDetails!.entries
                              .where((e) =>
                                  e.key != 'opportunity_id' &&
                                  e.key != 'id' &&
                                  e.key != 'stage_data' &&
                                  e.key != 'recommended_programs')
                              .map((entry) {
                            return _buildDetailRow(context, controller,
                                entry.key, entry.value?.toString() ?? '');
                          }),

                          // ── Recommended Programs ─────────────────────────
                          _buildProgramsRow(context, controller),

                          // ── Stage data fields ────────────────────────────
                          if (controller.editableDetails!['stage_data']
                              is Map) ...[
                            const SizedBox(height: Dimensions.space10),
                            ...(controller.editableDetails!['stage_data']
                                    as Map)
                                .entries
                                .where((e) => ![
                                      'roadblocks',
                                      'opportunities',
                                      'capabilities',
                                      'rmi_mode',
                                      'rmi_attachment',
                                      'follow_up_date',
                                    ].contains(e.key))
                                .map((e) {
                              return _buildStageDataRow(
                                  context, controller, e.key, e.value);
                            }),
                          ],

                          // ── RMI Details (view mode) ──────────────────────
                          if (!controller.isEditing)
                            _buildRmiViewSection(context, controller),

                          const SizedBox(height: Dimensions.space20),

                          // ── Edit mode buttons ────────────────────────────
                          if (controller.isEditing) ...[
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade700,
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.space15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.space10)),
                              ),
                              icon: const Icon(Icons.assignment,
                                  color: Colors.white),
                              label: Text('RMI Plan',
                                  style: regularLarge.copyWith(
                                      color: Colors.white)),
                              onPressed: () =>
                                  Get.to(() => const RmiPlanScreen()),
                            ),
                            const SizedBox(height: Dimensions.space10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.space15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.space10)),
                              ),
                              onPressed: () => controller.updateData(),
                              child: controller.isUpdateLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : Text('Update',
                                      style: regularLarge.copyWith(
                                          color: Colors.white)),
                            ),
                          ],

                          // ── View mode: Move to Negotiation ───────────────
                          if (!controller.isEditing) ...[
                            const SizedBox(height: Dimensions.space10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade600,
                                padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.space15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.space10)),
                              ),
                              onPressed: () => controller.moveToNegotiation(),
                              child: controller.isMoveLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : Text('Move to Negotiation',
                                      style: regularLarge.copyWith(
                                          color: Colors.white)),
                            ),
                          ],
                        ],
                      ),
                    ),
        );
      },
    );
  }

  // ─── RMI view section ────────────────────────────────────────────────────
  Widget _buildRmiViewSection(
      BuildContext context, ApproachingController controller) {
    final sd = controller.editableDetails?['stage_data'];
    if (sd == null || sd is! Map) return const SizedBox();

    final mode = sd['rmi_mode']?.toString() ?? 'manual';
    final roadblocks = _parseList(sd['roadblocks']);
    final opportunities = _parseList(sd['opportunities']);
    final capabilities = _parseList(sd['capabilities']);
    final attachment = sd['rmi_attachment']?.toString() ?? '';

    // Nothing entered yet — show nothing extra
    if (mode == 'manual' &&
        roadblocks.isEmpty &&
        opportunities.isEmpty &&
        capabilities.isEmpty) {
      return const SizedBox();
    }
    if (mode == 'attachment' && attachment.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: Dimensions.space10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space15, vertical: Dimensions.space12),
            decoration: BoxDecoration(
              color: Colors.orange.shade700,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(children: [
              const Icon(Icons.assignment, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                  'RMI Plan — ${mode == 'attachment' ? 'Attachment' : 'Manual'}',
                  style: semiBoldDefault.copyWith(color: Colors.white)),
            ]),
          ),

          if (mode == 'attachment') ...[
            Padding(
              padding: const EdgeInsets.all(Dimensions.space15),
              child: Row(children: [
                Icon(Icons.insert_drive_file, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(attachment,
                        style:
                            regularDefault.copyWith(color: Colors.grey[800]))),
              ]),
            ),
          ] else ...[
            if (roadblocks.isNotEmpty)
              _rmiPointsBlock(context,
                  icon: Icons.block,
                  iconColor: Colors.red.shade400,
                  bgColor: Colors.red.shade50,
                  title: 'Roadblocks / Challenges',
                  points: roadblocks),
            if (opportunities.isNotEmpty)
              _rmiPointsBlock(context,
                  icon: Icons.lightbulb_outline,
                  iconColor: Colors.orange.shade500,
                  bgColor: Colors.orange.shade50,
                  title: 'Opportunities / Potentials',
                  points: opportunities),
            if (capabilities.isNotEmpty)
              _rmiPointsBlock(context,
                  icon: Icons.star_outline,
                  iconColor: Colors.green.shade500,
                  bgColor: Colors.green.shade50,
                  title: 'Key Capabilities',
                  points: capabilities),
          ],
        ],
      ),
    );
  }

  Widget _rmiPointsBlock(BuildContext context,
      {required IconData icon,
      required Color iconColor,
      required Color bgColor,
      required String title,
      required List<String> points}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimensions.space15, Dimensions.space12, Dimensions.space15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(6)),
              child: Icon(icon, color: iconColor, size: 15),
            ),
            const SizedBox(width: 8),
            Text(title, style: semiBoldDefault.copyWith(fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          ...points.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(
                          child: Text('${entry.key + 1}',
                              style: regularSmall.copyWith(
                                  color: iconColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(entry.value,
                            style: regularDefault.copyWith(
                                color: Colors.grey[800]))),
                  ],
                ),
              )),
          const SizedBox(height: Dimensions.space10),
          Divider(color: Colors.grey.shade100, height: 1),
        ],
      ),
    );
  }

  List<String> _parseList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    final str = raw.toString().trim();
    if (str.isEmpty || str == '[]') return [];
    // JSON array string: ["a","b"]
    if (str.startsWith('[')) {
      try {
        final cleaned = str
            .substring(1, str.length - 1)
            .split(',')
            .map((e) => e.trim().replaceAll('"', ''))
            .where((e) => e.isNotEmpty)
            .toList();
        return cleaned;
      } catch (_) {}
    }
    return str
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // ─── Recommended Programs multi-select ───────────────────────────────────
  Widget _buildProgramsRow(
      BuildContext context, ApproachingController controller) {
    final List rawSelected =
        controller.editableDetails!['recommended_programs'] is List
            ? controller.editableDetails!['recommended_programs'] as List
            : [];

    if (!controller.isEditing) {
      String names = rawSelected
          .map((e) => e is Map ? e['name']?.toString() ?? '' : '')
          .where((e) => e.isNotEmpty)
          .join(', ');
      return _rowContainer(context,
          label: 'Recommended Programs',
          child: Text(names.isEmpty ? '-' : names,
              style: regularDefault.copyWith(color: Colors.black87)));
    }

    return _rowContainerWide(
      context,
      label: 'Recommended Programs',
      child: controller.programList.isEmpty
          ? Text('Loading programs...',
              style: regularSmall.copyWith(color: Colors.grey))
          : Wrap(
              spacing: 8,
              runSpacing: 4,
              children: controller.programList.map((prog) {
                bool isSelected = rawSelected.any((p) =>
                    p is Map &&
                    (p['program_id']?.toString() == prog.id?.toString() ||
                        p['id']?.toString() == prog.id?.toString()));
                return FilterChip(
                  label: Text(prog.name ?? '',
                      style: regularSmall.copyWith(fontSize: 12)),
                  selected: isSelected,
                  selectedColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                  onSelected: (val) => controller.toggleProgram(prog, val),
                );
              }).toList(),
            ),
    );
  }

  // ─── Regular detail row ───────────────────────────────────────────────────
  Widget _buildDetailRow(BuildContext context, ApproachingController controller,
      String key, String value) {
    bool isReadOnly = !controller.isEditing ||
        key == 'assigned' ||
        key == 'dateadded' ||
        key == 'id' ||
        key == 'status';

    Widget valueWidget;

    if (isReadOnly) {
      String displayValue = value.isEmpty ? '-' : value;
      if (key == 'source') {
        try {
          var matched = controller.sourceList
              .firstWhere((s) => s.id?.toString() == value || s.name == value);
          displayValue = matched.name ?? displayValue;
        } catch (_) {}
      } else if (key == 'company_industry') {
        try {
          var matched = controller.industryList
              .firstWhere((i) => i.id?.toString() == value || i.name == value);
          displayValue = matched.name ?? displayValue;
        } catch (_) {}
      }
      valueWidget = Text(displayValue,
          style: regularDefault.copyWith(color: Colors.black87));
    } else if (key == 'company_industry' &&
        controller.industryList.isNotEmpty) {
      String resolvedName = value;
      try {
        var matched = controller.industryList
            .firstWhere((i) => i.id?.toString() == value || i.name == value);
        resolvedName = matched.name ?? value;
      } catch (_) {}
      valueWidget = CustomDropDownTextField(
        hintText: 'Select Industry',
        needLabel: false,
        onChanged: (v) {
          if (v != null) controller.updateEditableField(key, v.toString());
        },
        selectedValue:
            controller.industryList.any((i) => i.name == resolvedName)
                ? resolvedName
                : null,
        items: controller.industryList.map((ind) {
          return DropdownMenuItem<String>(
            value: ind.name,
            child: Text(ind.name ?? '',
                overflow: TextOverflow.ellipsis,
                style: regularDefault.copyWith(color: Colors.black)),
          );
        }).toList(),
      );
    } else if (key == 'source' && controller.sourceList.isNotEmpty) {
      String resolvedName = value;
      try {
        var matched = controller.sourceList
            .firstWhere((s) => s.id?.toString() == value || s.name == value);
        resolvedName = matched.name ?? value;
      } catch (_) {}
      valueWidget = CustomDropDownTextField(
        hintText: 'Select Source',
        needLabel: false,
        onChanged: (v) {
          if (v != null) controller.updateEditableField(key, v.toString());
        },
        selectedValue: controller.sourceList.any((s) => s.name == resolvedName)
            ? resolvedName
            : null,
        items: controller.sourceList.map((src) {
          return DropdownMenuItem<String>(
            value: src.name,
            child: Text(src.name ?? '',
                overflow: TextOverflow.ellipsis,
                style: regularDefault.copyWith(color: Colors.black)),
          );
        }).toList(),
      );
    } else {
      valueWidget = TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (v) => controller.updateEditableField(key, v),
      );
    }

    return _rowContainer(context, label: _formatKey(key), child: valueWidget);
  }

  // ─── Stage data row ───────────────────────────────────────────────────────
  Widget _buildStageDataRow(BuildContext context,
      ApproachingController controller, String key, dynamic value) {
    if (!controller.isEditing) {
      String d = value?.toString() ?? '-';
      if (d.toLowerCase() == 'true') d = 'Yes';
      if (d.toLowerCase() == 'false') d = 'No';
      if (d.isEmpty) d = '-';
      if (d.contains('T') && d.length >= 15) d = d.replaceAll('T', ' ');
      return _rowContainer(context,
          label: _formatKey(key),
          child:
              Text(d, style: regularDefault.copyWith(color: Colors.black87)));
    }

    Widget valueWidget = const SizedBox();

    if ([
      'man_identified',
      'money_identified',
      'authority_identified',
      'need_identified',
      'proposal_sent',
    ].contains(key)) {
      bool isChecked =
          value?.toString().toLowerCase() == 'true' || value?.toString() == '1';
      valueWidget = Align(
        alignment: Alignment.centerLeft,
        child: Checkbox(
          value: isChecked,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (val) => controller.updateStageDataField(key, val),
        ),
      );
    } else if (key == 'appointment') {
      String displayDate = value?.toString().isEmpty ?? true
          ? 'Select Date & Time'
          : value.toString().replaceAll('T', ' ');
      valueWidget = InkWell(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime(2100),
          );
          if (picked != null && context.mounted) {
            TimeOfDay? tp = await showTimePicker(
                context: context, initialTime: TimeOfDay.now());
            if (tp != null) {
              DateTime fd = DateTime(
                  picked.year, picked.month, picked.day, tp.hour, tp.minute);
              String formatted =
                  '${fd.year.toString().padLeft(4, '0')}-${fd.month.toString().padLeft(2, '0')}-${fd.day.toString().padLeft(2, '0')}T${fd.hour.toString().padLeft(2, '0')}:${fd.minute.toString().padLeft(2, '0')}';
              controller.updateStageDataField(key, formatted);
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8)),
          child: Text(displayDate, style: regularDefault),
        ),
      );
    } else if ([
      'need_description',
      'discovery_summary',
      'three_year_vision',
      'top_3_challenges',
    ].contains(key)) {
      valueWidget = TextFormField(
        initialValue: value?.toString() ?? '',
        maxLines: 4,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (v) => controller.updateStageDataField(key, v),
      );
    } else {
      valueWidget = TextFormField(
        initialValue: value?.toString() ?? '',
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (v) => controller.updateStageDataField(key, v),
      );
    }

    return _rowContainer(context, label: _formatKey(key), child: valueWidget);
  }

  // ─── Layout helpers ───────────────────────────────────────────────────────
  Widget _rowContainer(BuildContext context,
      {required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: semiBoldDefault.copyWith(color: Colors.grey[800]))),
          const SizedBox(width: Dimensions.space10),
          Expanded(flex: 3, child: child),
        ],
      ),
    );
  }

  Widget _rowContainerWide(BuildContext context,
      {required String label, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: semiBoldDefault.copyWith(color: Colors.grey[800])),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  String _formatKey(String key) {
    if (key.isEmpty) return key;
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
