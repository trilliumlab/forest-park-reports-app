import 'package:flutter/material.dart';
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
  bool _stickyLocation = true;

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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0),
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
          // Floating Action Button
          Positioned(
            right: 20.0,
            bottom: _controller.isAttached && _controller.isPanelShown
                ? _fabHeight : _fabHeight-_panelHeightClosed,
            child: FloatingActionButton(
              backgroundColor: theme.colorScheme.background,
              onPressed: () {
                setState(() {
                  _stickyLocation = !_stickyLocation;
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

  Widget _panel(ScrollController sc, Trail trail) {
    var theme = Theme.of(context);
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: [
            const SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: theme.colorScheme.onBackground,
                      borderRadius: const BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            const SizedBox(
              height: 12.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Text(trail.name, style: theme.textTheme.titleLarge)
            ),
          ],
        ),
    );
  }

}
