import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:forest_park_reports/providers/camera_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/providers/hazard_provider.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
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
    (ref) => CenterOnLocationUpdate.always
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

  @override
  Widget build(BuildContext context) {
    // make the height of the panel when open 80% of the screen
    _panelHeightOpen = MediaQuery.of(context).size.height * _openPoint;
    _panelHeightSnap = _panelHeightOpen * _snapPoint;
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
                        // final parkTrails = ref.read(parkTrailsProvider);
                        // // TODO actually handle location errors
                        // final location = await getLocation();
                        // var res = parkTrails.snapLocation(location.latLng()!);
                        // ref.read(activeHazardProvider.notifier).create(
                        //     NewHazardRequest(HazardType.other, res.location));
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

class AddHazardModal extends ConsumerStatefulWidget {
  const AddHazardModal({super.key});

  @override
  ConsumerState<AddHazardModal> createState() => _AddHazardModalState();
}

class _AddHazardModalState extends ConsumerState<AddHazardModal> {
  HazardType? _selectedHazard;
  final HazardCameraController _controller = HazardCameraController();

  @override
  Widget build(BuildContext context) {
    return Panel(
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
                    style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(fontSize: 28),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                  child: CupertinoSlidingSegmentedControl(
                    groupValue: _selectedHazard,
                    onValueChanged: (HazardType? value) => setState(() {
                      _selectedHazard = value;
                    }),
                    children: {
                      for (final type in HazardType.values)
                        type: Text(
                          type.name,
                          style: CupertinoTheme.of(context).textTheme.textStyle
                        )
                    }
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
                    child: HazardCamera(
                      controller: _controller,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 28),
                  child: CupertinoButton(
                    color: CupertinoTheme.of(context).primaryColor,
                    onPressed: _selectedHazard == null ? null : () async {
                      final image = await _controller.takePicture();
                      final activeHazardNotifier = ref.read(activeHazardProvider.notifier);
                      final imageUuid = await activeHazardNotifier.uploadImage(image!);

                      final parkTrails = ref.read(parkTrailsProvider);
                      // TODO actually handle location errors
                      final location = await getLocation();
                      var snappedLoc = parkTrails.snapLocation(location.latLng()!);
                      // TODO check snap distance

                      await activeHazardNotifier.create(NewHazardRequest(
                          _selectedHazard!, snappedLoc.location, imageUuid));
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Submit',
                      style: CupertinoTheme.of(context).textTheme.textStyle
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: CupertinoDynamicColor.resolve(CupertinoColors.systemGrey, context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HazardCameraController {
  Future<XFile?> takePicture() async {
    return callback?.call();
  }
  Future<XFile> Function()? callback;
}

class HazardCamera extends ConsumerStatefulWidget {
  final HazardCameraController? controller;
  const HazardCamera({super.key, this.controller});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HazardCameraState();
}

class _HazardCameraState extends ConsumerState<HazardCamera> {
  final _initializeControllerCompleter = Completer();
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future _initCamera() async {
    final camera = await ref.read(cameraProvider.future);
    _controller = CameraController(
      camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );
    await _controller.initialize();
    widget.controller?.callback = _controller.takePicture;
    _initializeControllerCompleter.complete();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    widget.controller?.callback = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerCompleter.future,
      builder: (context, snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: SizedBox(
                width: 100,
                child: CameraPreview(_controller),
              ),
            ),
          ),
        ) : const Center(child: CupertinoActivityIndicator());
      },
    );
  }
}

class TrailHazardsWidget extends ConsumerWidget {
  final Trail trail;
  const TrailHazardsWidget({super.key, required this.trail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeHazards = ref.watch(activeHazardProvider)
        .where((e) => e.location.trail == trail.uuid);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Hazards",
              style: theme.textTheme.subtitle1
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: CupertinoDynamicColor.resolve(CupertinoColors.systemFill, context).withAlpha(40)
          ),
          child: Column(
            children: activeHazards.map((hazard) => HazardInfoWidget(
              hazard: hazard,
            )).toList(),
          ),
        ),
      ],
    );
  }
}

// Tuesday, July 12th, 2022 at 11:53am
DateFormat _formatter = DateFormat('EEEE, MMMM dd y, hh:mm a');
class HazardInfoWidget extends StatelessWidget {
  final Hazard hazard;
  const HazardInfoWidget({super.key, required this.hazard});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hazard.hazard.displayName,
            style: theme.textTheme.titleLarge,
          ),
          Text(_formatter.format(hazard.time.toLocal()))
        ],
      )
    );
  }

}

class TrailInfoWidget extends StatelessWidget {
  final ScrollController controller;
  final Trail trail;
  final Widget snapWidget;
  final Widget fullWidget;
  const TrailInfoWidget({
    super.key,
    required this.controller,
    required this.trail,
    required this.snapWidget,
    required this.fullWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      controller: controller,
      children: [
        const PlatformPill(),
        // content should go here
        Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, top: 4),
          child: Text(
            trail.name,
            style: theme.textTheme.headline6,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ),
        // Padding(
        //   padding: const EdgeInsets.only(left: 14, right: 14, top: 20),
        //   child: snapWidget,
        // ),
        Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, top: 8),
          child: snapWidget,
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: fullWidget,
        ),
      ],
    );
  }
}

class TrailElevationGraph extends ConsumerWidget {
  final Trail trail;
  final double height;
  const TrailElevationGraph({
    super.key,
    required this.trail,
    required this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeHazards = ref.watch(activeHazardProvider)
        .where((e) => e.location.trail == trail.uuid);
    final Map<double, Hazard?> hazardsMap = {};
    final List<FlSpot> spots = [];
    for (final e in trail.track!.elevation.asMap().entries) {
      final distance = trail.track!.distance[e.key];
      spots.add(FlSpot(distance, e.value));
      hazardsMap[distance] = activeHazards.firstWhereOrNull((h) => h.location.index == e.key);
    }
    final maxInterval = trail.track!.distance.last/5;
    final interval = maxInterval-maxInterval/20;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
                "Elevation",
                style: theme.textTheme.subtitle1
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              color: CupertinoDynamicColor.resolve(CupertinoColors.systemFill, context).withAlpha(40)
          ),
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: LineChart(
              LineChartData(
                  maxY: (trail.track!.maxElevation/50).ceil() * 50.0,
                  minY: (trail.track!.minElevation/50).floor() * 50.0,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      dotData: FlDotData(
                          checkToShowDot: (s, d) => hazardsMap[s.x] != null,
                          getDotPainter: (a, b, c, d) => FlDotCirclePainter(
                            color: CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context),
                            radius: 5,
                          )
                      ),
                    ),
                  ],
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                      topTitles: AxisTitles(),
                      rightTitles: AxisTitles(),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 65,
                              getTitlesWidget: (yVal, meta) {
                                return Text("${yVal.round().toString()} ft");
                              },
                              interval: 50
                          )
                      ),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (xVal, meta) {
                                final offInterval = (xVal % meta.appliedInterval);
                                final isRegInterval = (offInterval < 0.01 || offInterval > meta.appliedInterval - 0.01);
                                return isRegInterval ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text("${xVal.toStringRemoveTrailing(1)} mi"),
                                ) : Container();
                              },
                              interval: interval
                          )
                      )
                  )
              ),
            ),
          ),
        ),
      ],
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
