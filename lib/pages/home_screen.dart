import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/providers/location_provider.dart';
import 'package:forest_park_reports/providers/panel_position_provider.dart';
import 'package:forest_park_reports/util/outline_box_shadow.dart';
import 'package:forest_park_reports/widgets/add_hazard_modal.dart';
import 'package:forest_park_reports/widgets/trail_info.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:forest_park_reports/widgets/forest_park_map.dart';
import 'package:location/location.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// this stores whether camera follows the gps location. This will be set to
// false by panning the camera. when not stickied, pressing the sticky button
// will animate the camera to the current gps location and set sticky to true
final centerOnLocationProvider = StateProvider<CenterOnLocationUpdate>(
    (ref) => CenterOnLocationUpdate.never
);

class _HomeScreenState extends State<HomeScreen> {
  // parameters for the sliding modal/panel on the bottom
  // TODO animate hiding/showing of panel
  final PanelController _panelController = PanelController();
  final double _initFabHeight = 120.0;
  final double _openPoint = 0.80;
  final double _snapPoint = 0.40;
  double _fabHeight = 0;
  double _snapWidgetOpacity = 0;
  double _fullWidgetOpacity = 0;
  double _panelHeightOpen = 0;
  double _panelHeightSnap = 0;
  final double _panelHeightClosed = 100;

  @override
  void initState() {
    super.initState();
    _fabHeight = _initFabHeight;
  }

  _showMissingPermissionDialog(BuildContext context, String message) {
    showPlatformDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: const Text('Location Permission Required'),
        content: Text(message),
        actions: [
          PlatformDialogAction(
            child: PlatformText("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          PlatformDialogAction(
            child: PlatformText("Go To Settings"),
            onPressed: () {
              AppSettings.openAppSettings();
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // make the height of the panel when open 80% of the screen
    _panelHeightOpen = MediaQuery.of(context).size.height * _openPoint;
    _panelHeightSnap = _panelHeightOpen * _snapPoint;
    final theme = Theme.of(context);

    return PlatformScaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Consumer(
            builder: (context, ref, child) {
              // listen to panel position state to control panel position
              ref.listen<PanelPositionUpdate>(panelPositionProvider, (prev, next) {
                if (next.move) {
                  switch (next.position) {
                    case PanelPosition.open:
                      _panelController.open();
                      break;
                    case PanelPosition.closed:
                      _panelController.close();
                      break;
                    case PanelPosition.snapped:
                      _panelController.animatePanelToSnapPoint();
                      break;
                  }
                }
              });
              // update panel position
              var position = ref.read(panelPositionProvider).position;
              if (_panelController.isAttached) {
                if (_panelController.isPanelClosed) {
                  position = PanelPosition.closed;
                } else if (_panelController.isPanelOpen) {
                  position = PanelPosition.open;
                } else if ((_panelController.panelPosition-_snapPoint).abs()<0.0001 && !_panelController.isPanelAnimating) {
                  position = PanelPosition.snapped;
                }
              }
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  ref.read(panelPositionProvider.notifier).update(position));
              // listen to updates from parkTrailsProvider. This builder
              // will rebuild whenever a value changes (initial load, trail selected)
              // we want to know when a trail has been selected so we can show the modal.
              final parkTrails = ref.watch(parkTrailsProvider);
              //TODO cupertino scrolling physics
              return SlidingUpPanel(
                maxHeight: _panelHeightOpen,
                minHeight: _panelHeightClosed,
                parallaxEnabled: isMaterial(context),
                parallaxOffset: 0.58,
                snapPoint: _snapPoint,
                body: const ForestParkMap(),
                controller: _panelController,
                panelBuilder: (sc) => Panel(
                  child: parkTrails.selectedTrail == null ? ListView(
                    controller: sc,
                    children: const [
                      // pill decoration
                      PlatformPill()
                    ],
                  ) : TrailInfoWidget(
                    controller: sc,
                    trail: parkTrails.selectedTrail!,
                    snapWidget: Opacity(
                      opacity: _snapWidgetOpacity,
                      child: TrailElevationGraph(
                        trail: parkTrails.selectedTrail!,
                        height: _panelHeightSnap*0.7,
                      ),
                    ),
                    fullWidget: Opacity(
                      opacity: _fullWidgetOpacity,
                      child: TrailHazardsWidget(
                        trail: parkTrails.selectedTrail!
                      ),
                    ),
                  ),
                ),
                // don't render panel sheet so we can add custom blur
                renderPanelSheet: false,
                onPanelSlide: (double pos) => setState(() {
                  _snapWidgetOpacity = (pos/_snapPoint).clamp(0, 1);
                  _fullWidgetOpacity = ((pos-_snapPoint)/(1-_snapPoint)).clamp(0, 1);
                  _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) + _initFabHeight;
                }),
              );
            },
          ),
          // When panel is visible, position 20dp above the panel height (_fabHeight)
          // when panel is hidden, set it to 20db from bottom
          Positioned(
            right: 10.0,
            bottom: isCupertino(context) ? _fabHeight - 18 : _fabHeight - 8,
            child: Consumer(
                builder: (context, ref, child) {
                  return PlatformFAB(
                      onPressed: () async {
                        final status = await ref.read(locationPermissionProvider.notifier).checkPermission();
                        if (!mounted) return;
                        switch(status) {
                          case PermissionStatus.authorizedAlways:
                          case PermissionStatus.authorizedWhenInUse:
                            showCupertinoModalPopup(
                              context: context,
                              builder: (context) {
                                return Dismissible(
                                    direction: DismissDirection.down,
                                    key: const Key('key'),
                                    onDismissed: (_) => Navigator.of(context).pop(),
                                    child: const AddHazardModal()
                                );
                              },
                            );
                            break;
                          case PermissionStatus.restricted:
                            _showMissingPermissionDialog(context, 'Precise location permission is required to jump to current location');
                            break;
                          case PermissionStatus.denied:
                            _showMissingPermissionDialog(context, 'Location permission is required to jump to current location');
                            break;
                          default:
                        }
                      },
                      child: PlatformWidget(
                        cupertino: (_, __) => Icon(
                          // Fix for bug in cupertino_icons package, should be CupertinoIcons.location
                          CupertinoIcons.add,
                          color: WidgetsBinding.instance.window.platformBrightness == Brightness.light
                              ? CupertinoColors.systemGrey.highContrastColor
                              : CupertinoColors.systemGrey.darkHighContrastColor
                        ),
                        material: (_, __) => Icon(
                          Icons.add,
                          color: theme.colorScheme.onBackground,
                        ),
                      )
                  );
                }
            ),
          ),
          Positioned(
            right: 10.0,
            bottom: (isCupertino(context) ? _fabHeight - 18 : _fabHeight) + 60,
            child: Consumer(
                builder: (context, ref, child) {
                  final centerOnLocation = ref.watch(centerOnLocationProvider);
                  return PlatformFAB(
                    onPressed: () async {
                      final status = await ref.read(locationPermissionProvider.notifier).checkPermission();
                      if (!mounted) return;
                      switch(status) {
                        case PermissionStatus.authorizedAlways:
                        case PermissionStatus.authorizedWhenInUse:
                          ref.read(centerOnLocationProvider.notifier)
                              .update((state) => CenterOnLocationUpdate.always);
                          break;
                        case PermissionStatus.restricted:
                          _showMissingPermissionDialog(context, 'Precise location permission is required to jump to current location');
                          break;
                        case PermissionStatus.denied:
                          _showMissingPermissionDialog(context, 'Location permission is required to jump to current location');
                          break;
                        default:
                      }
                    },
                    child: PlatformWidget(
                      cupertino: (_, __) => Icon(
                        // Fix for bug in cupertino_icons package, should be CupertinoIcons.location
                        centerOnLocation == CenterOnLocationUpdate.always
                            ? CupertinoIcons.location_fill
                            : const IconData(0xf6ee, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage),
                        color: WidgetsBinding.instance.window.platformBrightness == Brightness.light
                            ? CupertinoColors.systemGrey.highContrastColor
                            : CupertinoColors.systemGrey.darkHighContrastColor
                      ),
                      material: (_, __) => Icon(
                        Icons.my_location_rounded,
                        color: centerOnLocation == CenterOnLocationUpdate.always
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onBackground
                      ),
                    ),
                  );
                }
            ),
          ),
          // status bar blur
          if (isCupertino(context))
            const StatusBarBlur(),
        ],
      ),
    );
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  const Panel({
    Key? key,
    required this.child
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panelRadius = BorderRadius.vertical(top: Radius.circular(isCupertino(context) ? 8 : 18));
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      // pass the scroll controller to the list view so that scrolling panel
      // content doesn't scroll the panel except when at the very top of list
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: panelRadius,
            boxShadow: const [
              OutlineBoxShadow(
                color: Colors.black26,
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: panelRadius,
            child: PlatformWidget(
              cupertino: (context, _) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context).withAlpha(210),
                  child: child,
                ),
              ),
              material: (_, __) => Container(
                color: theme.colorScheme.background,
                child: child,
              )
            ),
          ),
        ),
      ),
    );
  }
}

class StatusBarBlur extends StatelessWidget {
  const StatusBarBlur({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 50,
          ),
        ),
      ),
    );
  }
}

class PlatformFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  const PlatformFAB({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PlatformWidget(
      cupertino: (context, _) {
        const fabRadius = BorderRadius.all(Radius.circular(8));
        return Container(
          decoration: const BoxDecoration(
            borderRadius: fabRadius,
            boxShadow: [
              OutlineBoxShadow(
                color: Colors.black26,
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: fabRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: SizedBox(
                width: 50,
                height: 50,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context).withAlpha(210),
                  pressedOpacity: 0.9,
                  onPressed: onPressed,
                  child: child
                ),
              ),
            ),
          ),
        );
      },
      material: (_, __) => FloatingActionButton(
        backgroundColor: theme.colorScheme.background,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class PlatformPill extends StatelessWidget {
  const PlatformPill({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final isIos = isCupertino(context);
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: isIos ? 5 : 10
        ),
        width: isIos ? 35 : 26,
        height: 5,
        decoration: BoxDecoration(
            color: isIos
                ? CupertinoDynamicColor.resolve(CupertinoColors.systemGrey2, context)
                : theme.colorScheme.onBackground,
            borderRadius: const BorderRadius.all(Radius.circular(12.0))),
      ),
    );
  }

}
