import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/api/api.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/providers/hazard_provider.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:forest_park_reports/widgets/forest_park_map.dart';
import 'package:latlong2/latlong.dart';
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
    (ref) => CenterOnLocationUpdate.always
);

class _HomeScreenState extends State<HomeScreen> {
  // parameters for the sliding modal/panel on the bottom
  // TODO animate hiding/showing of panel
  final PanelController _panelController = PanelController();
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  final double _panelHeightClosed = 100;

  @override
  void initState() {
    super.initState();
    _fabHeight = _initFabHeight;
  }

  @override
  Widget build(BuildContext context) {
    // make the height of the panel when open 80% of the screen
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Consumer(
            builder: (context, ref, child) {
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
                snapPoint: 0.4,
                body: const ForestParkMap(),
                controller: _panelController,
                panelBuilder: (sc) => Panel(
                  child: ListView(
                    controller: sc,
                    children: [
                      // pill decoration
                      const PlatformPill(),
                      // content should go here
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Text("${parkTrails.selectedTrail?.name}", style: theme.textTheme.titleLarge)
                      ),
                    ],
                  ),
                ),
                // don't render panel sheet so we can add custom blur
                renderPanelSheet: false,
                onPanelSlide: (double pos) => setState(() {
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
                        final parkTrails = ref.read(parkTrailsProvider);
                        // TODO actually handle location errors
                        final location = await getLocation();
                        var res = parkTrails.snapLocation(location.latLng()!);
                        ref.read(apiProvider).postNewHazard(NewHazardRequest(HazardType.other, res.location));
                        ref.refresh(remoteActiveHazardProvider);
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
                      onPressed: () => ref.read(centerOnLocationProvider.notifier)
                          .update((state) => CenterOnLocationUpdate.always),
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
                      )
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
                  color: CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemBackground, context).withAlpha(200),
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
                  color: CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemBackground, context).withAlpha(200),
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

class OutlineBoxShadow extends BoxShadow {
  const OutlineBoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
  }) : super(color: color, offset: offset, blurRadius: blurRadius);

  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, blurSigma);
    assert(() {
      if (debugDisableShadows) {
        result.maskFilter = null;
      }
      return true;
    }());
    return result;
  }
}
