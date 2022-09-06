import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/pages/home_screen.dart';
import 'package:forest_park_reports/providers/hazard_provider.dart';
import 'package:forest_park_reports/providers/location_provider.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:forest_park_reports/util/permissions_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class AddHazardModal extends ConsumerStatefulWidget {
  const AddHazardModal({super.key});

  @override
  ConsumerState<AddHazardModal> createState() => _AddHazardModalState();
}

class _AddHazardModalState extends ConsumerState<AddHazardModal> {
  final _picker = ImagePicker();
  HazardType? _selectedHazard;
  XFile? _image;
  bool _inProgress = false;
  double _uploadProgress = 0;

  void _close() {
    Navigator.pop(context);
  }

  Future _submit() async {
    print('_submit called');

    setState(() => _inProgress = true);
    final parkTrails = ref.read(parkTrailsProvider);
    // TODO actually handle location errors
    print('requesting location');
    final location = (await ref.read(locationProvider.notifier).getLocation())!;
    print('got location: $location');
    var snappedLoc = parkTrails.snapLocation(location.latLng()!);

    print('got snapped location');

    final continueCompleter = Completer<bool>();
    if (snappedLoc.distance > 10+(location.accuracy)) {
      showPlatformDialog(context: context, builder: (context) => PlatformAlertDialog(
        title: const Text('Too far from trail'),
        content: const Text('Reports must be made on a marked Forest Park trail'),
        actions: [
          PlatformDialogAction(
              onPressed: () {
                Navigator.pop(context);
                continueCompleter.complete(false);
              },
              child: PlatformText('OK')
          ),
          PlatformDialogAction(
              onPressed: () {
                Navigator.pop(context);
                continueCompleter.complete(true);
              },
              child: PlatformText('Override')
          ),
        ],
      ));
    } else {
      continueCompleter.complete(true);
    }

    print('location is good');

    if (!await continueCompleter.future) {
      setState(() => _inProgress = false);
      return;
    }

    final activeHazardNotifier = ref.read(activeHazardProvider.notifier);

    String? imageUuid;
    if (_image != null) {
      imageUuid = await activeHazardNotifier.uploadImage(
        _image!,
        onSendProgress: (sent, total) => setState(() {
          _uploadProgress = sent/total;
        }),
      );
    }

    await activeHazardNotifier.create(NewHazardRequest(
        _selectedHazard!, snappedLoc.location, imageUuid));
    _close();
  }

  Future _onSubmit() async {
    final status = await ref.read(locationPermissionProvider.notifier).checkPermission(requestPrecise: true);
    if (!mounted) return;
    if (status.accuracy == LocationAccuracyStatus.precise) {
      if (_image == null) {
        showPlatformDialog(context: context, builder: (_) => PlatformAlertDialog(
          title: const Text('No photo selected'),
          content: const Text("Are you sure you'd like to submit this hazard without a photo?"),
          actions: [
            PlatformDialogAction(
              child: PlatformText('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            PlatformDialogAction(
              child: PlatformText('Yes'),
              onPressed: () {
                Navigator.pop(context);
                _submit();
              },
            ),
          ],
        ));
      } else {
        _submit();
      }
    } else {
      showMissingPermissionDialog(
          context,
          'Precise Location Required',
          'Precise location permission is required to report trail hazards'
      );
    }
  }

  Future _cameraSelect() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _image = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Panel(
      child: PlatformWidgetBuilder(
        cupertino: (_, child, __) => child,
        material: (_, child, __) => Material(
          color: Colors.transparent,
          child: child,
        ),
        child: SizedBox(
          height: 500,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 10),
                    child: Text(
                      "Report New Hazard",
                      style: isCupertino(context)
                          ? CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontSize: 28)
                          : theme.textTheme.headline6!.copyWith(fontSize: 28),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                    child: PlatformWidget(
                      cupertino: (context, _) => CupertinoSlidingSegmentedControl(
                          groupValue: _selectedHazard,
                          onValueChanged: (HazardType? value) => setState(() {
                            _selectedHazard = value;
                          }),
                          children: {
                            for (final type in HazardType.values)
                              type: Text(
                                type.name,
                                style: isCupertino(context)
                                    ? CupertinoTheme.of(context).textTheme.textStyle
                                    : theme.textTheme.bodyLarge,
                              ),
                          }
                      ),
                      // TODO waiting on m3 support
                      material: (context, _) => DropdownButton(
                        onChanged: (HazardType? value) => setState(() {
                          _selectedHazard = value;
                        }),
                        value: _selectedHazard,
                        hint: const Text('Hazard Type'),
                        items: HazardType.values.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        )).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(isCupertino(context) ? 8 : 18)),
                          child: PlatformWidgetBuilder(
                              cupertino: (context, child, __) => CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: _cameraSelect,
                                color: CupertinoDynamicColor.resolve(CupertinoColors.quaternarySystemFill, context),
                                child: child!,
                              ),
                              material: (context, child, __) => ElevatedButton(
                                onPressed: _cameraSelect,
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(18))
                                      )
                                  ),
                                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                                ),
                                child: child,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints.expand(),
                                child: _image == null ? Icon(
                                  CupertinoIcons.camera,
                                  color: isCupertino(context) ? CupertinoTheme.of(context).primaryColor : theme.colorScheme.primary,
                                ) : Image.file(
                                  File(_image!.path),
                                  fit: BoxFit.cover,
                                ),
                              )
                          )
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 28),
                    child: PlatformWidget(
                      cupertino: (context, _) => CupertinoButton(
                        color: CupertinoTheme.of(context).primaryColor,
                        onPressed: _selectedHazard == null || _inProgress
                            ? null
                            : _onSubmit,
                        child: Text(
                          'Submit',
                          style: CupertinoTheme.of(context).textTheme.textStyle,
                        ),
                      ),
                      material: (context, _) => ElevatedButton(
                        onPressed: _selectedHazard == null ? null : _onSubmit,
                        child: const Text('Submit'),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      borderRadius: const BorderRadius.all(Radius.circular(100)),
                      color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemFill, context),
                      onPressed: _close,
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: CupertinoDynamicColor.resolve(CupertinoColors.systemGrey, context),
                      ),
                    ),
                  ),
                ),
              ),
              if (_inProgress)
                Align(
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(
                    value: _uploadProgress > 0.95 || _uploadProgress < 0.05 ? null : _uploadProgress,
                    backgroundColor: Colors.transparent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


