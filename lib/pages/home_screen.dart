import 'dart:ui';

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
              // final selectedTrail = parkTrails.trails[parkTrails.selectedTrail];
              final selectedTrail = Trail("Test", "Test");
              // if we have nothing selected, we should hide the modal,
              // otherwise we need to make sure it's open
              if (_panelController.isAttached) {
                if (selectedTrail == null && _panelController.isPanelShown) {
                  _panelController.hide();
                } else if (selectedTrail != null && !_panelController.isPanelShown) {
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
                panelBuilder: (sc) => selectedTrail == null ? Container() : _panel(sc, selectedTrail),
                // don't render panel sheet so we can add custom blur
                renderPanelSheet: false,
                onPanelSlide: (double pos) => setState(() {
                  _fabHeight =
                      pos * (_panelHeightOpen - _panelHeightClosed) +
                          _initFabHeight;
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
                return FloatingActionButton(
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
    var theme = Theme.of(context);
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        // pass the scroll controller to the list view so that scrolling panel
        // content doesn't scroll the panel except when at the very top of list
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
            child: Container(
              color: Colors.red.withAlpha(100),
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
          ),
        ),
    );
  }

}
