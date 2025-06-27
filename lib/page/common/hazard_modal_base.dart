import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/page/common/permissions_dialog.dart';
import 'package:forest_park_reports/page/home_page/panel_page.dart';
import 'package:forest_park_reports/provider/location_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class HazardModal<T> extends ConsumerStatefulWidget {
  final String title;
  final Map<T, Widget>? options;
  final T? initialOption;
  final FutureOr<bool>? Function(BuildContext context, WidgetRef ref,
      XFile? image, String uuid, T? option)? onSubmit;

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
  final String _uuid = kUuidGen.v1();
  T? _selectedOption;
  XFile? _image;
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

  void _close() {
    Navigator.pop(context);
  }

  Future _cameraSelect() async {
    // Create an overlay to block touches through camera picker.
    // See https://github.com/flutter/flutter/issues/14720#issuecomment-2012942702
    final entry = OverlayEntry(
      builder: (context) => const AbsorbPointer(
        child: SizedBox.expand(),
      ),
    );

    Overlay.of(context).insert(entry);

    try {
      // check if camera is available
      final image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() => _image = image);
      }
    } finally {
      //always remove the entry
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

    if (_image != null) {
      await _submit();
      return;
    }

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('No photo submitted'),
              content: const Text(
                  'Are you sure you\'d like to submit this hazard without a photo?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    Navigator.pop(context);
                    _submit();
                  },
                ),
              ],
            ));
  }

  Future _submit() async {
    setState(() => _inProgress = true);
    if (widget.onSubmit != null) {
      // A false result indicates a non-confirmation, while null or true represent confirmation
      if (await widget.onSubmit!(
              context, ref, _image, _uuid, _selectedOption) ==
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
      height: 500,
      // height: PanelValues.snapHeight(context),
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
                  child: SizedBox(
                    height: 40,
                    child: SegmentedButton(
                      emptySelectionAllowed: true,
                      showSelectedIcon: false,
                      selected: {if (_selectedOption != null) _selectedOption},
                      onSelectionChanged: (selection) {
                        if (selection.length == 1) {
                          setState(() => _selectedOption = selection.first);
                        }
                      },
                      segments: [
                        for (final option in widget.options!.entries)
                          ButtonSegment(
                            value: option.key,
                            label: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: option.value),
                          ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                  child: FilledButton(
                    style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18))),
                        backgroundColor: WidgetStatePropertyAll(
                            theme.colorScheme.surfaceContainer),
                        padding:
                            const WidgetStatePropertyAll(EdgeInsets.only())),
                    onPressed: null,
                    child: InkWell(
                      onTap: _cameraSelect,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints.expand(),
                        child: _image == null
                            ? Icon(
                                Icons.camera_alt_rounded,
                                color: theme.colorScheme.primary,
                              )
                            : Image.file(
                                File(_image!.path),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
              )),
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
                  // size: 20,
                  // color: CupertinoDynamicColor.resolve(CupertinoColors.systemGrey, context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
