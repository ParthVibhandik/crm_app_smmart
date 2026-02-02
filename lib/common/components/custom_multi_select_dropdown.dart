import 'package:flutter/material.dart';
import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutex_admin/core/utils/dimensions.dart';
import 'package:flutex_admin/core/utils/style.dart';
import 'package:flutex_admin/core/utils/local_strings.dart';
import 'package:get/get.dart';

class CustomMultiSelectDropDown extends StatefulWidget {
  final String? hintText;
  final List<dynamic> items; // Expecting objects with 'id' and 'name' properties or similar
  final List<String> initialSelectedIds;
  final Function(List<String> selectedIds) onChanged;
  final bool isSearchable;

  const CustomMultiSelectDropDown({
    Key? key,
    this.hintText,
    required this.items,
    this.initialSelectedIds = const [],
    required this.onChanged,
    this.isSearchable = false,
  }) : super(key: key);

  @override
  State<CustomMultiSelectDropDown> createState() => _CustomMultiSelectDropDownState();
}

class _CustomMultiSelectDropDownState extends State<CustomMultiSelectDropDown> {
  late List<String> _selectedIds;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.initialSelectedIds);
    _updateDisplayText();
  }

  @override
  void didUpdateWidget(covariant CustomMultiSelectDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedIds != oldWidget.initialSelectedIds) {
      _selectedIds = List.from(widget.initialSelectedIds);
      _updateDisplayText();
    }
  }

  void _updateDisplayText() {
    if (_selectedIds.isEmpty) {
      _displayText = '';
      return;
    }

    List<String> selectedNames = [];
    for (var id in _selectedIds) {
      dynamic item;
      try {
        item = widget.items.firstWhere(
          (element) => element.id.toString() == id,
        );
      } catch (e) {
        item = null;
      }
      
      if (item != null) {
        selectedNames.add(item.name?.toString() ?? '');
      }
    }
    setState(() {
      _displayText = selectedNames.join(', ');
    });
  }

  void _showSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _MultiSelectDialog(
          items: widget.items,
          initialSelectedIds: _selectedIds,
          onConfirm: (List<String> newSelectedIds) {
            setState(() {
              _selectedIds = newSelectedIds;
              _updateDisplayText();
            });
            widget.onChanged(newSelectedIds);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showSelectionDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space15,
          vertical: Dimensions.space15,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.cardRadius),
          border: Border.all(
            color: ColorResources.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _displayText.isEmpty
                    ? (widget.hintText ?? 'Select')
                    : _displayText,
                style: regularDefault.copyWith(
                  color: _displayText.isEmpty
                      ? ColorResources.getTextColor().withOpacity(0.6)
                      : ColorResources.getTextColor(),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: ColorResources.getTextColor(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MultiSelectDialog extends StatefulWidget {
  final List<dynamic> items;
  final List<String> initialSelectedIds;
  final Function(List<String>) onConfirm;

  const _MultiSelectDialog({
    Key? key,
    required this.items,
    required this.initialSelectedIds,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late List<String> _tempSelectedIds;

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = List.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocalStrings.select.tr), // Make sure LocalStrings is imported or handle generic
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.items.map((item) {
            final String id = item.id.toString();
            final String name = item.name?.toString() ?? '';
            final bool isSelected = _tempSelectedIds.contains(id);

            return CheckboxListTile(
              title: Text(name),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    if (!_tempSelectedIds.contains(id)) {
                      _tempSelectedIds.add(id);
                    }
                  } else {
                    _tempSelectedIds.remove(id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'.tr),
        ),
        TextButton(
          onPressed: () {
            widget.onConfirm(_tempSelectedIds);
            Navigator.pop(context);
          },
          child: Text('OK'.tr),
        ),
      ],
    );
  }
}
