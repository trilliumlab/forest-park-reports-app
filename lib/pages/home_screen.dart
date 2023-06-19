import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/providers/hazard_provider.dart';
import 'package:forest_park_reports/providers/location_provider.dart';
import 'package:forest_park_reports/providers/panel_position_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:forest_park_reports/util/outline_box_shadow.dart';
import 'package:forest_park_reports/util/permissions_dialog.dart';
import 'package:forest_park_reports/util/statusbar_blur.dart';
import 'package:forest_park_reports/widgets/add_hazard_modal.dart';
import 'package:forest_park_reports/widgets/hazard_info.dart';
import 'package:forest_park_reports/widgets/trail_info.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:forest_park_reports/widgets/forest_park_map.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// this stores whether camera follows the gps location. This will be set to
// false by panning the camera. when not stickied, pressing the sticky button
// will animate the camera to the current gps location and set sticky to true
final followOnLocationProvider = StateProvider<FollowOnLocationUpdate>(
    (ref) => FollowOnLocationUpdate.never
);

class ScreenPanelController extends PanelController {
  // utility functions
  bool get isPanelSnapped => (panelPosition-snapPoint).abs()<0.0001 && !isPanelAnimating;
  double get safePanelPosition => isAttached ? panelPosition : 0;

  double get snapWidgetOpacity => (panelPosition/snapPoint).clamp(0, 1);
  double get fullWidgetOpacity => ((panelPosition-snapPoint)/(1-snapPoint)).clamp(0, 1);

  // bounding stuff
  double snapPoint;
  double panelClosedHeight;
  ScreenPanelController({
    required this.snapPoint,
    required this.panelClosedHeight,
  });

  double panelOpenHeight = 0;

  double get pastSnapPosition => ((panelPosition-snapPoint)/(1-snapPoint)).clamp(0, 1);
  double get panelSnapHeight => ((panelOpenHeight-panelClosedHeight) * snapPoint) + panelClosedHeight;
  double get panelHeight => safePanelPosition * (panelOpenHeight - panelClosedHeight) + panelClosedHeight;

}

class _HomeScreenState extends State<HomeScreen> {
  // parameters for the sliding modal/panel on the bottom
  // TODO animate hiding/showing of panel
  late final _panelController = ScreenPanelController(
    snapPoint: 0.40,
    panelClosedHeight: 100,
  );

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // _panelHeight = _initFabHeight;
  }

  @override
  Widget build(BuildContext context) {
    // make the height of the panel when open 80% of the screen
    _panelController.panelOpenHeight = MediaQuery.of(context).size.height * 0.80;
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
                } else if (_panelController.isPanelSnapped) {
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
                maxHeight: _panelController.panelOpenHeight,
                minHeight: _panelController.panelClosedHeight,
                parallaxEnabled: isMaterial(context),
                parallaxOffset: 0.58,
                snapPoint: _panelController.snapPoint,
                body: const ForestParkMap(),
                controller: _panelController,
                scrollController: _scrollController,
                panelBuilder: () => PanelPage(
                  scrollController: _scrollController,
                  panelController: _panelController,
                ),
                // don't render panel sheet so we can add custom blur
                renderPanelSheet: false,
                onPanelSlide: (double pos) => setState(() {
                  // _snapWidgetOpacity = (pos/_snapPoint).clamp(0, 1);
                  // _fullWidgetOpacity = ((pos-_snapPoint)/(1-_snapPoint)).clamp(0, 1);
                  // _panelHeight = pos * (_panelHeightOpen - _panelHeightClosed) + _panelHeightClosed;
                }),
              );
            },
          ),
          // When panel is visible, position 20dp above the panel height (_fabHeight)
          // when panel is hidden, set it to 20db from bottom
          Positioned(
            right: 10.0,
            bottom: (isCupertino(context) ? _panelController.panelHeight - 18 : _panelController.panelHeight - 8) + 20,
            child: Consumer(
                builder: (context, ref, child) {
                  return PlatformFAB(
                      onPressed: () async {
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
            bottom: (isCupertino(context) ? _panelController.panelHeight - 18 : _panelController.panelHeight) + 80,
            child: Consumer(
                builder: (context, ref, child) {
                  final centerOnLocation = ref.watch(followOnLocationProvider);
                  return PlatformFAB(
                    onPressed: () async {
                      final status = await ref.read(locationPermissionProvider.notifier).checkPermission();
                      if (!mounted) return;
                      if (status.permission.authorized) {
                        ref.read(followOnLocationProvider.notifier)
                            .update((state) => CenterOnLocationUpdate.always);
                      } else {
                        showMissingPermissionDialog(
                            context,
                            'Location Required',
                            'Location permission is required to jump to current location'
                        );
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

class PanelPage extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final ScreenPanelController panelController;
  const PanelPage({
    super.key,
    required this.scrollController,
    required this.panelController,
  });
  @override
  ConsumerState<PanelPage> createState() => _PanelPageState();
}

//TODO stateless?
class _PanelPageState extends ConsumerState<PanelPage> {
  @override
  Widget build(BuildContext context) {
    final selectedTrail = ref.watch(parkTrailsProvider.select((p) => p.selectedTrail));
    final selectedHazard = ref.watch(selectedHazardProvider.select((h) => h.hazard));
    final hazardTrail = ref.read(parkTrailsProvider).trails[selectedHazard?.location.trail];

    HazardUpdateList? hazardUpdates;
    String? lastImage;
    if (selectedHazard != null) {
      hazardUpdates = ref.watch(hazardUpdatesProvider(selectedHazard.uuid));
      lastImage = hazardUpdates!.lastImage;
    }

    return Panel(
      // panel for when a hazard is selected
      child: selectedHazard != null ? TrailInfoWidget(
        scrollController: widget.scrollController,
        panelController: widget.panelController,
        title: "${selectedHazard.hazard.displayName} on ${hazardTrail!.name}",
        bottomWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: PlatformTextButton(
                  onPressed: () {
                    ref.read(hazardUpdatesProvider(selectedHazard.uuid).notifier).create(
                      UpdateHazardRequest(
                          hazard: selectedHazard.uuid,
                          active: false,
                      ),
                    );
                    ref.read(panelPositionProvider.notifier).move(PanelPosition.closed);
                    ref.read(selectedHazardProvider.notifier).deselect();
                    ref.read(activeHazardProvider.notifier).refresh();
                  },
                  padding: EdgeInsets.zero,
                  child: Text(
                    "Delete",
                    style: TextStyle(color: CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 20),
                child: PlatformTextButton(
                  onPressed: () {
                    ref.read(hazardUpdatesProvider(selectedHazard.uuid).notifier).create(
                      UpdateHazardRequest(
                        hazard: selectedHazard.uuid,
                        active: true,
                      ),
                    );
                    ref.read(panelPositionProvider.notifier).move(PanelPosition.closed);
                    ref.read(selectedHazardProvider.notifier).deselect();
                    ref.read(activeHazardProvider.notifier).refresh();
                  },
                  padding: EdgeInsets.zero,
                  child: Text(
                    "Confirm",
                    style: TextStyle(color: CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context)),
                  ),
                ),
              ),
            ),
          ],
        ),
        children: [
          if (lastImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Opacity(
                opacity: widget.panelController.snapWidgetOpacity,
                child: SizedBox(
                  height: widget.panelController.panelSnapHeight * 0.7
                      + (widget.panelController.panelOpenHeight-widget.panelController.panelSnapHeight)*widget.panelController.pastSnapPosition * 0.6,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: HazardImage(lastImage),
                  ),
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              color: CupertinoDynamicColor.resolve(CupertinoColors.systemFill, context).withAlpha(40)
            ),
            child: Column(
              children: hazardUpdates!.map((update) => UpdateInfoWidget(
                update: update,
              )).toList(),
            ),
          )
        ],
      ):

      // panel for when a trail is selected
      selectedTrail != null ? TrailInfoWidget(
        scrollController: widget.scrollController,
        panelController: widget.panelController,
        title: selectedTrail.name,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Opacity(
              opacity: widget.panelController.snapWidgetOpacity,
              child: TrailElevationGraph(
                trail: selectedTrail,
                height: widget.panelController.panelSnapHeight*0.6,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Opacity(
              opacity: widget.panelController.fullWidgetOpacity,
              child: TrailHazardsWidget(
                trail: selectedTrail
              ),
            ),
          ),
        ],
      ):

      // panel for when nothing is selected
      TrailInfoWidget(
        scrollController: widget.scrollController,
        panelController: widget.panelController,
        children: const []
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
