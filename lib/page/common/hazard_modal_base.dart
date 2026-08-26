import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/page/common/permissions_dialog.dart';

import 'package:forest_park_reports/provider/location_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class HazardModal<T> extends ConsumerStatefulWidget {
  final String title;
  final Map<T, Widget>? options;
  final T? initialOption;
  final FutureOr<bool>? Function(BuildContext context, WidgetRef ref,
      XFile? image, String uuid, T? option, String? comments)? onSubmit;

  HazardModal(
      {super.key,
      this.title = "Report Hazard",
      required this.onSubmit,
      this.options,
      this.initialOption})
      : assert(
            initialOption == null ||
                (options != null && options[initialOption] != null),
            "Initial option must correspond with a provided list of options");

  @override
  ConsumerState<HazardModal> createState() => _HazardModalState<T>();
}

class _HazardModalState<T> extends ConsumerState<HazardModal<T>> {
  final _picker = ImagePicker();
  final _commentsController = TextEditingController();
  final String _uuid = kUuidGen.v1();
  T? _selectedOption;
  XFile? _image;
  bool _showPhotoRequiredError = false;
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    if (widget.options != null && widget.initialOption != null) {
      _selectedOption = widget.initialOption;
    } else {
      _selectedOption = null;
    }
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.pop(context);
  }

  Future _cameraSelect() async {

    final entry = OverlayEntry(
      builder: (context) => const AbsorbPointer(
        child: SizedBox.expand(),
      ),
    );

    Overlay.of(context).insert(entry);

    try {
      final image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _image = image;
          _showPhotoRequiredError = false;
        });
      }
    } finally {
      entry.remove();
    }
  }

  Future _onSubmit() async {
    final status = await ref
        .read(locationPermissionStatusProvider.notifier)
        .checkPermission(requestPrecise: true);
    if (!mounted) return;
    if (status.accuracy != LocationAccuracyStatus.precise) {
      showMissingPermissionDialog(context, 'Precise Location Required',
          "Please provided your precise location to submit trail hazard reports");
      return;
    }

    if (_image == null) {
      setState(() => _showPhotoRequiredError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take a photo before submitting this report.'),
        ),
      );
      return;
    }

    await _submit();
  }

  Future _submit() async {
    setState(() => _inProgress = true);
    if (widget.onSubmit != null) {
      if (await widget.onSubmit!(
              context,
              ref,
              _image,
              _uuid,
              _selectedOption,
              _commentsController.text.trim().isEmpty
                  ? null
                  : _commentsController.text.trim()) ==
          false) {
        setState(() => _inProgress = false);
        return;
      }
    }
    _close();
    setState(() => _inProgress = false);
    return;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 650,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 10),
                child: Text(
                  widget.title,
                  style: theme.textTheme.titleLarge!.copyWith(fontSize: 28),
                ),
              ),
              if (widget.options != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hazard Type:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<T>(
                            value: _selectedOption,
                            hint: const Text('Select hazard type'),
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            borderRadius: BorderRadius.circular(12),
                            dropdownColor: theme.colorScheme.surface,
                            style: theme.textTheme.bodyMedium,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: theme.colorScheme.onSurface,
                            ),
                            onChanged: (T? newValue) {
                              setState(() {
                                _selectedOption = newValue;
                              });
                            },
                            items: widget.options!.entries.map((entry) {
                              return DropdownMenuItem<T>(
                                value: entry.key,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: entry.value,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Description of the hazard...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photo required:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _showPhotoRequiredError
                              ? theme.colorScheme.error
                              : theme.colorScheme.outline,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: _cameraSelect,
                          child: _image == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to take required photo',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                )
                              : Image.file(
                                  File(_image!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                        ),
                      ),
                    ),
                    if (_showPhotoRequiredError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'A photo is required before this report can be submitted.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 12, right: 12, top: 8, bottom: 28),
                child: FilledButton(
                  onPressed:
                      (widget.options != null && _selectedOption == null) ||
                              _inProgress
                          ? null
                          : _onSubmit,
                  child: const Text('Submit'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: IconButton(
                onPressed: _close,
                icon: const Icon(
                  Icons.close_rounded,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
