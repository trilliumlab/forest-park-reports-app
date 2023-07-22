import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/models/hazard_update.dart';
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
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;

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

  double compassRotation = 0.0;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      double rotation = -event.y;
      magnetometerEvents.listen((MagnetometerEvent magnetometerEvent) {
        double magneticFieldZ = magnetometerEvent.z;
        double azimuth = math.atan2(-magneticFieldZ, event.y);
        double azimuthDegrees = azimuth * (180 / math.pi);
        setState(() {
          compassRotation = rotation - azimuthDegrees;
        });
      });
    });
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
                    case PanelPositionState.open:
                      _panelController.open();
                      break;
                    case PanelPositionState.closed:
                      _panelController.close();
                      break;
                    case PanelPositionState.snapped:
                      _panelController.animatePanelToSnapPoint();
                      break;
                  }
                }
              }); 
              // update panel position
              var position = ref.read(panelPositionProvider).position;
              if (_panelController.isAttached) {
                if (_panelController.isPanelClosed) {
                  position = PanelPositionState.closed;
                } else if (_panelController.isPanelOpen) {
                  position = PanelPositionState.open;
                } else if (_panelController.isPanelSnapped) {
                  position = PanelPositionState.snapped;
                }
              }
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  ref.read(panelPositionProvider.notifier).update(position));
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
          Positioned(
            top: 60.0,
            right: 20.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: compassRotation * (math.pi / 180),
                  child: Icon(
                    Icons.navigation,
                    size: 30.0,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'N',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
                          color: View.of(context).platformDispatcher.platformBrightness == Brightness.light
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
                  final followOnLocation = ref.watch(followOnLocationProvider);
                  return PlatformFAB(
                    onPressed: () async {
                      final status = await ref.read(locationPermissionStatusProvider.notifier).checkPermission();
                      if (!mounted) return;
                      if (status.permission.authorized) {
                        ref.read(followOnLocationProvider.notifier)
                            .update((state) => FollowOnLocationUpdate.always);
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
                        followOnLocation == FollowOnLocationUpdate.always
                            ? CupertinoIcons.location_fill
                            : const IconData(0xf6ee, fontFamily: CupertinoIcons.iconFont, fontPackage: CupertinoIcons.iconFontPackage),
                        color: View.of(context).platformDispatcher.platformBrightness == Brightness.light
                            ? CupertinoColors.systemGrey.highContrastColor
                            : CupertinoColors.systemGrey.darkHighContrastColor
                      ),
                      material: (_, __) => Icon(
                        Icons.my_location_rounded,
                        color: followOnLocation == FollowOnLocationUpdate.always
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onBackground
                      ),
                    ),
                  );
                }
            ),
          ),
          Positioned(
            right: 10.0,
            bottom: (isCupertino(context) ? _panelController.panelHeight - 18 : _panelController.panelHeight) + 140,
            child: Consumer(
              builder: (context, ref, child) {
                return PlatformFAB(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsApp()),
                    );
                  },
                  child: PlatformWidget(
                    cupertino: (_, __) => Icon(
                      // Customize the icon for Cupertino
                      CupertinoIcons.settings,
                      color: WidgetsBinding.instance.window.platformBrightness == Brightness.light
                          ? CupertinoColors.systemGrey.highContrastColor
                          : CupertinoColors.systemGrey.darkHighContrastColor,
                    ),
                    material: (_, __) => Icon(
                      // Customize the icon for Material
                      Icons.settings,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                );
              },
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
    final selectedTrail = ref.watch(selectedTrailProvider);
    final selectedHazard = ref.watch(selectedHazardProvider.select((h) => h.hazard));
    final hazardTrail = selectedHazard == null ? null : ref.read(trailProvider(selectedHazard.location.trail));

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
        title: "${selectedHazard.hazard.displayName} on ${hazardTrail!.value?.name}",
        bottomWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: PlatformTextButton(
                  onPressed: () {
                    ref.read(hazardUpdatesProvider(selectedHazard.uuid).notifier).create(
                      HazardUpdateRequestModel(
                          hazard: selectedHazard.uuid,
                          active: false,
                      ),
                    );
                    ref.read(panelPositionProvider.notifier).move(PanelPositionState.closed);
                    ref.read(selectedHazardProvider.notifier).deselect();
                    ref.read(activeHazardProvider.notifier).refresh();
                  },
                  padding: EdgeInsets.zero,
                  child: Text(
                    "Cleared",
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
                      HazardUpdateRequestModel(
                        hazard: selectedHazard.uuid,
                        active: true,
                      ),
                    );
                    ref.read(panelPositionProvider.notifier).move(PanelPositionState.closed);
                    ref.read(selectedHazardProvider.notifier).deselect();
                    ref.read(activeHazardProvider.notifier).refresh();
                  },
                  padding: EdgeInsets.zero,
                  child: Text(
                    "Present",
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
          // TODO move this out of here
          Card(
            elevation: 1,
            shadowColor: Colors.transparent,
            margin: EdgeInsets.zero,
            child: Column(
              children: hazardUpdates!.map((update) => UpdateInfoWidget(
                update: update,
              )).toList(),
            ),
          ),
          // Container(
          //   decoration: BoxDecoration(
          //       borderRadius: const BorderRadius.all(Radius.circular(8)),
          //       color: isCupertino(context) ? CupertinoDynamicColor.resolve(CupertinoColors.systemFill, context).withAlpha(40) : Theme.of(context).colorScheme.secondaryContainer
          //   ),
          //   child: Column(
          //     children: hazardUpdates!.map((update) => UpdateInfoWidget(
          //       update: update,
          //     )).toList(),
          //   ),
          // ),
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

class SettingsApp extends StatefulWidget {
  @override
  _SettingsAppState createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsApp> {
  bool _isDarkModeEnabled = false;
  bool _isBackgroundGPSEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedMapQuality = 'Medium';
  String _selectedMode = 'Light';
  TargetPlatform _initialPlatform = TargetPlatform.android;

  // Helper function to get the appropriate theme data based on platform and selected mode
  dynamic getThemeData(BuildContext context) {
    if (isMaterial(context)) {
      if (_selectedMode == 'Dark') {
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
        );
      } else if (_selectedMode == 'System') {
        return ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.blue,
        );
      } else {
        return ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
        );
      }
    } else if (isCupertino(context)) {
      return CupertinoThemeData(
        brightness: _selectedMode == 'Dark' ? Brightness.dark : Brightness.light,
      );
    }
    return ThemeData.light();
  }

  // Toggle Dark Mode
  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkModeEnabled = value;
      if (_isDarkModeEnabled) {
        _selectedMode = 'Dark';
      } else {
        _selectedMode = 'Light';
      }
    });
  }

  // Toggle Background GPS
  void _toggleBackgroundGPS(bool value) {
    setState(() {
      _isBackgroundGPSEnabled = value;
    });
  }

  // Update selected language
  void _updateLanguage(String value) {
    setState(() {
      _selectedLanguage = value;
    });
  }

  // Update selected map quality
  void _updateMapQuality(String value) {
    setState(() {
      _selectedMapQuality = value;
    });
  }

  String getAppThemeName() {
    return _initialPlatform == TargetPlatform.iOS
        ? 'iOS Theme'
        : 'Android Theme';
  }

  void _goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformProvider(
      initialPlatform: _initialPlatform,
      builder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: getThemeData(context),
          home: Material(
            child: PlatformScaffold(
              appBar: PlatformAppBar(
                title: Text('Settings'),
                leading: PlatformIconButton(
                  icon: Icon(context.platformIcons.back),
                  onPressed: () => _goBack(context),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.0),
                    // App Theme
                    Text(
                      'App Theme: ${getAppThemeName()}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 16.0),
                    // Platform selection
                    SizedBox(
                      width: double.infinity,
                      child: PlatformSegmentedControl<TargetPlatform>(
                        segments: [
                          PlatformSegment(
                            TargetPlatform.iOS,
                            Text('iOS'),
                          ),
                          PlatformSegment(
                            TargetPlatform.android,
                            Text('Android'),
                          ),
                        ],
                        selected: _initialPlatform,
                        onSelectionChanged: (value) {
                          setState(() {
                            _initialPlatform = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // Dark Mode
                    DarkModeSwitch(
                      isDarkModeEnabled: _isDarkModeEnabled,
                      toggleDarkMode: _toggleDarkMode,
                    ),
                    SizedBox(height: 16.0),
                    // Background GPS
                    BackgroundGPSSwitch(
                      isBackgroundGPSEnabled: _isBackgroundGPSEnabled,
                      toggleBackgroundGPS: _toggleBackgroundGPS,
                    ),
                    SizedBox(height: 16.0),
                    // Language
                    LanguageSelection(
                      selectedLanguage: _selectedLanguage,
                      updateLanguage: _updateLanguage,
                    ),
                    SizedBox(height: 16.0),
                    // Selected Mode
                    SelectedMode(
                      selectedMode: _selectedMode,
                    ),
                    SizedBox(height: 16.0),
                    // Map Quality
                    MapQualitySelection(
                      selectedMapQuality: _selectedMapQuality,
                      updateMapQuality: _updateMapQuality,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PlatformSegmentedControl<T> extends StatelessWidget {
  final List<PlatformSegment<T>> segments;
  final T? selected;
  final void Function(T? selected) onSelectionChanged;

  const PlatformSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) {
        return SizedBox(
          width: double.infinity,
          child: SegmentedButton(
            segments: [
              for (final segment in segments)
                ButtonSegment(
                  value: segment.value,
                  label: segment.child,
                ),
            ],
            emptySelectionAllowed: true,
            onSelectionChanged: (selected) => onSelectionChanged(selected.first as T?),
            selected: {
              if (selected != null)
                selected,
            },
          ),
        );
      },
      cupertino: (context, platform) {
        return CupertinoSlidingSegmentedControl<T>(
          onValueChanged: onSelectionChanged,
          groupValue: selected,
          children: {
            for (final segment in segments)
              segment.value: segment.child,
          },
        );
      },
    );
  }
}

class PlatformSegment<T> {
  final T value;
  final Widget child;
  const PlatformSegment(this.value, this.child);
}

class DarkModeSwitch extends StatelessWidget {
  final bool isDarkModeEnabled;
  final Function(bool) toggleDarkMode;

  const DarkModeSwitch({
    Key? key,
    required this.isDarkModeEnabled,
    required this.toggleDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Dark Mode'),
      trailing: PlatformSwitch(
        value: isDarkModeEnabled,
        onChanged: toggleDarkMode,
      ),
    );
  }
}

class BackgroundGPSSwitch extends StatelessWidget {
  final bool isBackgroundGPSEnabled;
  final Function(bool) toggleBackgroundGPS;

  const BackgroundGPSSwitch({
    Key? key,
    required this.isBackgroundGPSEnabled,
    required this.toggleBackgroundGPS,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Background GPS'),
      trailing: PlatformSwitch(
        value: isBackgroundGPSEnabled,
        onChanged: toggleBackgroundGPS,
      ),
    );
  }
}

class LanguageSelection extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) updateLanguage;

  const LanguageSelection({
    Key? key,
    required this.selectedLanguage,
    required this.updateLanguage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformListTile(
      title: Text('Language'),
      subtitle: Text(selectedLanguage),
      onTap: () {
        showPlatformDialog(
          context: context,
          builder: (_) => PlatformAlertDialog(
            title: Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // English
                PlatformListTile(
                  title: Text('English'),
                  onTap: () {
                    updateLanguage('English');
                    Navigator.pop(context);
                  },
                ),
                // Spanish
                PlatformListTile(
                  title: Text('Spanish'),
                  onTap: () {
                    updateLanguage('Spanish');
                    Navigator.pop(context);
                  },
                ),
                // French
                PlatformListTile(
                  title: Text('French'),
                  onTap: () {
                    updateLanguage('French');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SelectedMode extends StatelessWidget {
  final String selectedMode;

  const SelectedMode({
    Key? key,
    required this.selectedMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Selected Mode: $selectedMode',
      style: TextStyle(fontSize: 18.0),
    );
  }
}

class MapQualitySelection extends StatelessWidget {
  final String selectedMapQuality;
  final Function(String) updateMapQuality;

  const MapQualitySelection({
    Key? key,
    required this.selectedMapQuality,
    required this.updateMapQuality,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Map Quality'),
      subtitle: Text(selectedMapQuality),
      onTap: () {
        showPlatformDialog(
          context: context,
          builder: (_) => PlatformAlertDialog(
            title: Text('Select Map Quality'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Low
                PlatformListTile(
                  title: Text('Low'),
                  onTap: () {
                    updateMapQuality('Low');
                    Navigator.pop(context);
                  },
                ),
                // Medium
                PlatformListTile(
                  title: Text('Medium'),
                  onTap: () {
                    updateMapQuality('Medium');
                    Navigator.pop(context);
                  },
                ),
                // High
                PlatformListTile(
                  title: Text('High'),
                  onTap: () {
                    updateMapQuality('High');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
