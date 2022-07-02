import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:forest_park_reports/widgets/forest_park_map.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// this stores whether camera follows the gps location. This will be set to
// false by panning the camera. when not stickied, pressing the sticky button
// will animate the camera to the current gps location and set sticky to true
final stickyLocationProvider = StateProvider<bool>((ref) => true);

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
    var theme = Theme.of(context);
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
              // if we have nothing selected, we should hide the modal,
              // otherwise we need to make sure it's open
              if (_panelController.isAttached) {
                if (parkTrails.selectedTrail == null && _panelController.isPanelShown) {
                  _panelController.hide();
                } else if (parkTrails.selectedTrail != null && !_panelController.isPanelShown) {
                  _panelController.show();
                }
              }
              var panelRadius = isMaterial(context) ? 18.0 : 10.0;
              return SlidingUpPanel(
                maxHeight: _panelHeightOpen,
                minHeight: _panelHeightClosed,
                parallaxEnabled: isMaterial(context),
                parallaxOffset: 0.58,
                snapPoint: 0.4,
                body: ForestParkMap(),
                controller: _panelController,
                panelBuilder: (sc) => parkTrails.selectedTrail == null
                    ? Container() : _panel(sc, parkTrails.selectedTrail!),
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
            right: 20.0,
            bottom: _panelController.isAttached && _panelController.isPanelShown
                ? _fabHeight : _fabHeight-_panelHeightClosed,
            child: Consumer(
              builder: (context, ref, child) {
                final stickyLocation = ref.watch(stickyLocationProvider);
                return PlatformWidgetBuilder(
                    cupertino: (context, child, __) {
                      var iosTheme = CupertinoTheme.of(context);
                      return ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                          child: FloatingActionButton(
                            backgroundColor: iosTheme.scaffoldBackgroundColor.withAlpha(200),
                            splashColor: Colors.transparent,
                            elevation: 0,
                            hoverElevation: 0,
                            onPressed: () {
                              ref.read(stickyLocationProvider.notifier).update((state) => true);
                            },
                            shape: const RoundedRectangleBorder(),
                            child: Icon(
                                Icons.my_location_rounded,
                                color: stickyLocation
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onBackground
                            ),
                          ),
                        ),
                      );
                    },
                  material: (_, __, ___) => FloatingActionButton(
                    backgroundColor: theme.colorScheme.background,
                    onPressed: () {
                      ref.read(stickyLocationProvider.notifier).update((state) => true);
                    },
                    child: Icon(
                        Icons.my_location_rounded,
                        color: stickyLocation
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onBackground
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  // builds the panel content
  Widget _panel(ScrollController sc, Trail trail) {
    final theme = Theme.of(context);
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        // pass the scroll controller to the list view so that scrolling panel
        // content doesn't scroll the panel except when at the very top of list
        child: PlatformWidgetBuilder(
          cupertino: (context, child, __) {
            var iosTheme = CupertinoTheme.of(context);
            var panelRadius = const BorderRadius.vertical(top: Radius.circular(10));
            //TODO widgetize
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: panelRadius,
                  boxShadow: const [
                    OutlineBoxShadow(
                      color: Colors.black45,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: panelRadius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(
                      color: iosTheme.scaffoldBackgroundColor.withAlpha(200),
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
          material: (_, child, __) => ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Container(
              color: theme.colorScheme.background,
              child: child,
            ),
          ),
          child: ListView(
            controller: sc,
            children: [
              // pill decoration
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  width: 26,
                  height: 4,
                  decoration: BoxDecoration(
                      color: theme.colorScheme.onBackground,
                      borderRadius: const BorderRadius.all(Radius.circular(12.0))),
                ),
              ),
              // content should go here
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Text(trail.name, style: theme.textTheme.titleLarge)
              ),
            ],
          ),
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
