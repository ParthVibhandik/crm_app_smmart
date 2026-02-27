import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/features/spanco/approaching/controller/approaching_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class RmiPlanScreen extends StatefulWidget {
  const RmiPlanScreen({super.key});

  @override
  State<RmiPlanScreen> createState() => _RmiPlanScreenState();
}

class _RmiPlanScreenState extends State<RmiPlanScreen> {
  String _mode = 'manual';

  // Each section holds a list of TextEditingControllers (one per point)
  List<TextEditingController> _roadblocksCtrl = [];
  List<TextEditingController> _opportunitiesCtrl = [];
  List<TextEditingController> _capabilitiesCtrl = [];

  File? _selectedFile;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<ApproachingController>();
    final sd = controller.editableDetails?['stage_data'];

    if (sd is Map) {
      _mode =
          sd['rmi_mode']?.toString() == 'attachment' ? 'attachment' : 'manual';

      _roadblocksCtrl = _initControllers(sd['roadblocks']);
      _opportunitiesCtrl = _initControllers(sd['opportunities']);
      _capabilitiesCtrl = _initControllers(sd['capabilities']);

      if (sd['rmi_attachment'] != null) {
        _selectedFileName = sd['rmi_attachment']?.toString();
      }
    }

    // Ensure at least one empty field per section
    if (_roadblocksCtrl.isEmpty) _roadblocksCtrl = [TextEditingController()];
    if (_opportunitiesCtrl.isEmpty)
      _opportunitiesCtrl = [TextEditingController()];
    if (_capabilitiesCtrl.isEmpty)
      _capabilitiesCtrl = [TextEditingController()];

    // Attach listeners to auto-add fields
    _attachListeners(_roadblocksCtrl, () => setState(() {}));
    _attachListeners(_opportunitiesCtrl, () => setState(() {}));
    _attachListeners(_capabilitiesCtrl, () => setState(() {}));
  }

  List<TextEditingController> _initControllers(dynamic raw) {
    if (raw == null) return [];
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => TextEditingController(text: e.toString())).toList();
    }
    final str = raw.toString().trim();
    if (str.isEmpty) return [];
    // Support newline-separated or comma-separated legacy data
    final parts = str.contains('\n')
        ? str.split('\n')
        : str.split(',').map((e) => e.trim()).toList();
    return parts
        .where((e) => e.isNotEmpty)
        .map((e) => TextEditingController(text: e))
        .toList();
  }

  void _attachListeners(
      List<TextEditingController> ctrls, VoidCallback rebuild) {
    for (var ctrl in ctrls) {
      ctrl.addListener(() => rebuild());
    }
  }

  /// When the last field has text, append a new empty field
  void _ensureTrailingEmpty(
      List<TextEditingController> ctrls, VoidCallback rebuild) {
    if (ctrls.last.text.trim().isNotEmpty) {
      final newCtrl = TextEditingController();
      newCtrl.addListener(() => rebuild());
      ctrls.add(newCtrl);
      // Rebuild happens via listener on next frame
    }
  }

  void _removePoint(List<TextEditingController> ctrls, int index) {
    if (ctrls.length <= 1) {
      ctrls[0].clear();
    } else {
      ctrls[index].dispose();
      ctrls.removeAt(index);
    }
    setState(() {});
  }

  List<String> _getValues(List<TextEditingController> ctrls) {
    return ctrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not pick file: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _save() {
    final controller = Get.find<ApproachingController>();
    controller.updateStageDataField('rmi_mode', _mode);

    if (_mode == 'manual') {
      controller.updateStageDataField(
          'roadblocks', _getValues(_roadblocksCtrl));
      controller.updateStageDataField(
          'opportunities', _getValues(_opportunitiesCtrl));
      controller.updateStageDataField(
          'capabilities', _getValues(_capabilitiesCtrl));
      controller.updateStageDataField('rmi_attachment', null);
    } else {
      if (_selectedFileName != null) {
        controller.updateStageDataField('rmi_attachment', _selectedFileName);
      }
      controller.updateStageDataField('roadblocks', []);
      controller.updateStageDataField('opportunities', []);
      controller.updateStageDataField('capabilities', []);
    }

    Get.back();
    Get.snackbar('Saved', 'RMI Plan saved. Press Update to submit.',
        snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void dispose() {
    for (var c in [
      ..._roadblocksCtrl,
      ..._opportunitiesCtrl,
      ..._capabilitiesCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Auto-grow last field on each build
    _ensureTrailingEmpty(_roadblocksCtrl, () => setState(() {}));
    _ensureTrailingEmpty(_opportunitiesCtrl, () => setState(() {}));
    _ensureTrailingEmpty(_capabilitiesCtrl, () => setState(() {}));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('RMI Input Method',
            style: regularLarge.copyWith(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Save',
                style: regularDefault.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Mode selector ───────────────────────────────────────────
            _modeCard(context),
            const SizedBox(height: Dimensions.space20),

            if (_mode == 'manual') ...[
              _buildSection(
                context,
                icon: Icons.block,
                iconColor: Colors.red.shade400,
                title: 'Roadblocks / Challenges',
                hint: 'Enter a roadblock or challenge...',
                controllers: _roadblocksCtrl,
                accentColor: Colors.red.shade50,
                borderColor: Colors.red.shade100,
              ),
              const SizedBox(height: Dimensions.space15),
              _buildSection(
                context,
                icon: Icons.lightbulb_outline,
                iconColor: Colors.orange.shade500,
                title: 'Opportunities / Potentials',
                hint: 'Enter an opportunity or potential...',
                controllers: _opportunitiesCtrl,
                accentColor: Colors.orange.shade50,
                borderColor: Colors.orange.shade100,
              ),
              const SizedBox(height: Dimensions.space15),
              _buildSection(
                context,
                icon: Icons.star_outline,
                iconColor: Colors.green.shade500,
                title: 'Key Capabilities',
                hint: 'Enter a key capability...',
                controllers: _capabilitiesCtrl,
                accentColor: Colors.green.shade50,
                borderColor: Colors.green.shade100,
              ),
            ] else ...[
              _attachmentCard(context),
            ],

            const SizedBox(height: Dimensions.space30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: Dimensions.space15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.space10)),
                ),
                onPressed: _save,
                child: Text('Save RMI Plan',
                    style: regularLarge.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mode selector card ──────────────────────────────────────────────────
  Widget _modeCard(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space20, vertical: Dimensions.space10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Input Method',
              style: semiBoldDefault.copyWith(color: Colors.grey[800])),
          RadioListTile<String>(
            value: 'manual',
            groupValue: _mode,
            activeColor: Theme.of(context).primaryColor,
            title: Text('Manual Entry', style: regularDefault),
            subtitle: Text('Enter data point by point',
                style: regularSmall.copyWith(color: Colors.grey)),
            onChanged: (v) => setState(() => _mode = v!),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            value: 'attachment',
            groupValue: _mode,
            activeColor: Theme.of(context).primaryColor,
            title: Text('Attachment', style: regularDefault),
            subtitle: Text('Upload a file (PDF, DOC, Image)',
                style: regularSmall.copyWith(color: Colors.grey)),
            onChanged: (v) => setState(() => _mode = v!),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // ── Dynamic points section ──────────────────────────────────────────────
  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String hint,
    required List<TextEditingController> controllers,
    required Color accentColor,
    required Color borderColor,
  }) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(Dimensions.space15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: accentColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title,
                    style: semiBoldDefault.copyWith(color: Colors.grey[800]))),
          ]),
          const SizedBox(height: Dimensions.space12),

          // Dynamic point list
          ...List.generate(controllers.length, (index) {
            final isLast = index == controllers.length - 1;
            final isEmpty = controllers[index].text.trim().isEmpty;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Point number badge
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isEmpty
                          ? Colors.grey.shade200
                          : Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text('${index + 1}',
                          style: regularSmall.copyWith(
                              color: isEmpty
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Text field
                  Expanded(
                    child: TextField(
                      controller: controllers[index],
                      style: regularDefault,
                      decoration: InputDecoration(
                        hintText: isLast && isEmpty
                            ? (index == 0 ? hint : 'Add point ${index + 1}...')
                            : 'Point ${index + 1}',
                        hintStyle: regularDefault.copyWith(
                            color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color:
                                  isEmpty ? Colors.grey.shade300 : borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: iconColor, width: 1.5),
                        ),
                        filled: !isEmpty,
                        fillColor: isEmpty ? Colors.transparent : accentColor,
                      ),
                    ),
                  ),

                  // Remove button (only on non-empty or non-last fields)
                  if (!isEmpty || controllers.length > 1) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _removePoint(controllers, index),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.remove_circle_outline,
                            color: Colors.red.shade300, size: 22),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Attachment card ─────────────────────────────────────────────────────
  Widget _attachmentCard(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(Dimensions.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upload Attachment',
              style: semiBoldDefault.copyWith(color: Colors.grey[800])),
          const SizedBox(height: Dimensions.space15),
          if (_selectedFileName != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200)),
              child: Row(children: [
                Icon(Icons.insert_drive_file, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(_selectedFileName!,
                        style: regularDefault.copyWith(
                            color: Colors.green.shade800),
                        overflow: TextOverflow.ellipsis)),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red.shade400, size: 20),
                  onPressed: () => setState(() {
                    _selectedFile = null;
                    _selectedFileName = null;
                  }),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.space15),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: Dimensions.space15),
                side: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: Icon(Icons.upload_file,
                  color: Theme.of(context).primaryColor),
              label: Text(
                _selectedFileName != null ? 'Change File' : 'Choose File',
                style: regularDefault.copyWith(
                    color: Theme.of(context).primaryColor),
              ),
              onPressed: _pickFile,
            ),
          ),
          const SizedBox(height: Dimensions.space10),
          Text('Supported formats: PDF, DOC, DOCX, JPG, PNG',
              style: regularSmall.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2))
      ],
    );
  }
}
