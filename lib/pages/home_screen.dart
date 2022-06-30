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

class _HomeScreenState extends State<HomeScreen> {
  // this stores whether camera follows the gps location. This can be disabled
  // by panning the camera, which is updated through the onStickyUpdate callback.
  // when not stickied, pressing the sticky button will animate the camera to
  // the current gps location
  // TODO use a controller
  bool _stickyLocation = true;

  // parameters for the sliding modal/panel on the bottom
  // TODO animate hiding/showing of panel
  final PanelController _controller = PanelController();
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
              final selectedTail = parkTrails.trails[parkTrails.selectedTrail];
              // if we have nothing selected, we should hide the modal,
              // otherwise we need to make sure it's open
              if (_controller.isAttached) {
                if (selectedTail == null && _controller.isPanelShown) {
                  _controller.hide();
                } else if (selectedTail != null && !_controller.isPanelShown) {
                  _controller.show();
                }
              }
              var panelRadius = isMaterial(context) ? 18.0 : 10.0;
              return SlidingUpPanel(
                maxHeight: _panelHeightOpen,
                minHeight: _panelHeightClosed,
                parallaxEnabled: true,
                parallaxOffset: 0.58,
                body: ForestParkMap(
                  followPointer: _stickyLocation,
                  onStickyUpdate: (val) {
                    setState(() {
                      _stickyLocation = val;
                    });
                  },
                ),
                controller: _controller,
                panelBuilder: (sc) => selectedTail == null ? Container() : _panel(sc, selectedTail),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(panelRadius),
                  topRight: Radius.circular(panelRadius),
                ),
                color: theme.colorScheme.background,
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
            bottom: _controller.isAttached && _controller.isPanelShown
                ? _fabHeight : _fabHeight-_panelHeightClosed,
            child: FloatingActionButton(
              backgroundColor: theme.colorScheme.background,
              onPressed: () {
                setState(() {
                  _stickyLocation = true;
                });
              },
              child: Icon(
                  Icons.my_location_rounded,
                  color: _stickyLocation
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onBackground
              ),
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
    );
  }

}
