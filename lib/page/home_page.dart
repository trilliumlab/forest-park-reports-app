import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:forest_park_reports/page/home_page/map_compass.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/util/panel_values.dart';
import 'package:forest_park_reports/page/home_page/panel_page.dart';
import 'package:forest_park_reports/page/common/platform_fab.dart';
import 'package:forest_park_reports/page/settings_page.dart';
import 'package:forest_park_reports/provider/panel_position_provider.dart';
import 'package:forest_park_reports/page/home_page/map_fabs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forest_park_reports/page/home_page/map_page_libre.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final _panelController = PanelController();

  final _scrollController = ScrollController();

  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // make the height of the panel when open 80% of the screen
    final theme = Theme.of(context);

    final statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      // FIXME: Breaks touch pass through on maplibre_gl
      // body: SoftEdgeBlur(
      //   edges: [
      //     EdgeBlur(
      //       type: EdgeType.topEdge,
      //       size: statusBarHeight,
      //       sigma: 10,
      //       controlPoints: [
      //         ControlPoint(
      //           position: 0.5,
      //           type: ControlPointType.visible,
      //         ),
      //         ControlPoint(
      //           position: 1,
      //           type: ControlPointType.transparent,
      //         )
      //       ],
      //     )
      //   ],
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Consumer(
            builder: (context, ref, child) {
              // listen to panel position state to control panel position
              ref.listen<PanelPositionUpdate>(panelPositionProvider,
                  (prev, next) {
                if (next.move) {
                  _panelController.goToState(next.position);
                }
              });
              // update panel position
              var position = ref.read(panelPositionProvider).position;
              if (_panelController.isAttached) {
                position = _panelController.panelState;
              }
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  ref.read(panelPositionProvider.notifier).update(position));
              //TODO cupertino scrolling physics
              return SlidingUpPanel(
                maxHeight: PanelValues.openHeight(context),
                minHeight: PanelValues.collapsedHeight(context),
                snapHeight: PanelValues.snapHeight(context),
                defaultPanelState: PanelState.HIDDEN,
                body: const MapPage(),
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
          // Location and add hazard buttons
          // When panel is visible, position 20dp above the panel height (_fabHeight)
          Positioned(
            right: kFabPadding,
            bottom: kFabPadding +
                max(
                    _panelController.isAttached
                        ? _panelController.panelHeight
                        : 0,
                    MediaQuery.of(context).viewPadding.bottom),
            child: Visibility(
              visible: !_panelController.isAttached
                  ? true
                  : 1 >
                      (_panelController.panelPosition -
                              PanelValues.snapFraction(context)) /
                          (0.2 * (1 - PanelValues.snapFraction(context))),
              child: MapFabs(
                opacity: !_panelController.isAttached
                    ? 1
                    : Curves.easeInOut.transform(1 -
                        clampDouble(
                            (_panelController.panelPosition -
                                    PanelValues.snapFraction(context)) /
                                (0.2 * (1 - PanelValues.snapFraction(context))),
                            0,
                            1)),
              ),
            ),
          ),

          // Settings FAB and compass
          Positioned(
            right: kFabPadding,
            top: MediaQuery.of(context).viewPadding.top + kFabPadding,
            child: Column(
              children: [
                Consumer(builder: (context, ref, child) {
                  return PlatformFAB(
                    heroTag: "settings_fab",
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.settings,
                      color: theme.colorScheme.onSurface,
                    ),
                  );
                }),
                const SizedBox(
                  height: kFabPadding,
                ),
                Visibility(
                    maintainState: true,
                    visible: !_panelController.isAttached
                        ? true
                        : 1 >
                            (_panelController.panelPosition -
                                    PanelValues.snapFraction(context)) /
                                (0.2 * (1 - PanelValues.snapFraction(context))),
                    child: Opacity(
                        opacity: !_panelController.isAttached
                            ? 1
                            : Curves.easeInOut.transform(1 -
                                clampDouble(
                                    (_panelController.panelPosition -
                                            PanelValues.snapFraction(context)) /
                                        (0.2 *
                                            (1 -
                                                PanelValues.snapFraction(
                                                    context))),
                                    0,
                                    1)),
                        child: MapCompass(
                          mapController: _mapController,
                          hideIfRotatedNorth: true,
                          alignment: Alignment.center,
                        )))
              ],
            ),
          ),
        ],
      ),
      // ),
    );
  }
}
