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
  bool stickyLocation = true;
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 100;

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
          SlidingUpPanel(
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: 0.55,
            body: ForestParkMap(
              followPointer: stickyLocation,
              onStickyUpdate: (val) {
                setState(() {
                  stickyLocation = val;
                });
              },
            ),
            panelBuilder: (sc) => _panel(sc),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0),
              topRight: Radius.circular(18.0),
            ),
            color: theme.colorScheme.background,
            onPanelSlide: (double pos) => setState(() {
              _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                  _initFabHeight;
            }),
          ),
          // Floating Action Button
          Positioned(
            right: 20.0,
            bottom: _fabHeight,
            child: FloatingActionButton(
              backgroundColor: theme.colorScheme.background,
              onPressed: () {
                setState(() {
                  stickyLocation = !stickyLocation;
                });
              },
              child: Icon(
                  Icons.my_location_rounded,
                  color: stickyLocation
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onBackground
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel(ScrollController sc) {
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
            Consumer(
              builder: (context, ref, child) {
                final parkTrails = ref.watch(parkTrailsProvider);
                final selectedTail = parkTrails.trails[parkTrails.selectedTrail];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Text(selectedTail?.name ?? "NOTHING SELECTED", style: theme.textTheme.titleLarge)
                );
              },
            ),
          ],
        ),
    );
  }

}
