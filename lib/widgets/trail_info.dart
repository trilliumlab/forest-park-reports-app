import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/models/trail_metadata.dart';
import 'package:forest_park_reports/pages/home_screen/panel_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/pages/home_screen.dart';
import 'package:forest_park_reports/providers/hazard_provider.dart';
import 'package:forest_park_reports/providers/panel_position_provider.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:forest_park_reports/widgets/forest_park_map.dart';

class TrailHazardsWidget extends ConsumerWidget {
  final TrailMetadataModel trail;
  const TrailHazardsWidget({super.key, required this.trail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeHazards = ref.watch(activeHazardProvider.select((hazards) =>
        hazards.where((e) => e.location.trail == trail.uuid)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Hazards",
              style: theme.textTheme.titleMedium
            ),
          ),
        ),
        Card(
          elevation: 1,
          shadowColor: Colors.transparent,
          margin: EdgeInsets.zero,
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

class HazardInfoWidget extends ConsumerWidget {
  final HazardModel hazard;
  const HazardInfoWidget({super.key, required this.hazard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hazardUpdates = ref.watch(hazardUpdatesProvider(hazard.uuid));
    final lastImage = hazardUpdates.lastImage;
    return PlatformTextButton(
      padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
      onPressed: () {
        ref.read(selectedTrailProvider.notifier).deselect();
        ref.read(selectedHazardProvider.notifier).selectAndMove(hazard);
        ref.read(panelPositionProvider.notifier).move(PanelPositionState.snapped);
      },
      material: (_, __) => MaterialTextButtonData(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hazard.hazard.displayName,
                style: theme.textTheme.titleLarge,
              ),
              Text(
                  hazard.timeString(),
                  style: theme.textTheme.titleMedium
              )
            ],
          ),
          if (lastImage != null)
            SizedBox(
                height: 80,
                child: AspectRatio(
                  aspectRatio: 4/3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: HazardImage(lastImage),
                  ),
                )
            )
        ],
      ),
    );
  }
}

class TrailInfoWidget extends StatefulWidget {
  final ScrollController scrollController;
  final ScreenPanelController panelController;
  final List<Widget> children;
  final String? title;
  final Widget? bottomWidget;
  const TrailInfoWidget({
    super.key,
    required this.scrollController,
    required this.panelController,
    required this.children,
    this.bottomWidget,
    this.title,
  });

  @override
  State<TrailInfoWidget> createState() => _TrailInfoWidgetState();
}

class _TrailInfoWidgetState extends State<TrailInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: max(widget.panelController.panelSnapHeight, widget.panelController.panelHeight)-MediaQueryData.fromView(View.of(context)).padding.bottom,
        child: Column(
          children: [
            Stack(
              children: [
                if (widget.title != null)
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 14, top: 16, bottom: 10),
                      child: Text(
                        widget.title!,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                const Align(
                  alignment: Alignment.topCenter,
                  child: PlatformPill(),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: CustomScrollView(
                    controller: widget.scrollController,
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate([
                          ...widget.children,
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.bottomWidget != null)
              ClipRect(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: widget.bottomWidget!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    //TODO check this out
        // if (widget.title != null)
        //   Align(
        //     alignment: Alignment.topLeft,
        //     child: ClipRect(
        //       child: BackdropFilter(
        //         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        //         child: Container(
        //           color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context).withAlpha(210),
        //           width: MediaQuery.of(context).size.width,
        //           child: Padding(
        //             key: _textKey,
        //             padding: const EdgeInsets.only(left: 14, right: 14, top: 16, bottom: 6),
        //             child: Text(
        //               widget.title!,
        //               style: theme.textTheme.headline6,
        //               maxLines: 2,
        //               overflow: TextOverflow.ellipsis,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // if (widget.bottomWidget != null)
        //   Positioned(
        //     bottom: (
        //         widget.panelController.panelOpenHeight-
        //             max(
        //                 widget.panelController.panelHeight,
        //                 widget.panelController.panelSnapHeight
        //             )
        //     ),
        //     child: ClipRect(
        //       child: BackdropFilter(
        //         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        //         child: Container(
        //           color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context).withAlpha(210),
        //           child: Padding(
        //             padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, top: 4),
        //             child: SizedBox(
        //               width: width,
        //               child: widget.bottomWidget!,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
  }
}

class TrailElevationGraph extends ConsumerWidget {
  final TrailMetadataModel trail;
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
    final trailData = ref.watch(trailProvider(trail.uuid)).value;
    if (trailData == null) {
      return Center(
        child: PlatformCircularProgressIndicator()
      );
    }
    final Map<double, HazardModel?> hazardsMap = {};
    final List<FlSpot> spots = [];
    final filterInterval = (trailData.elevation.length/100).round();
    for (final e in trailData.elevation.asMap().entries) {
      if (e.key % filterInterval == 0) {
        final distance = trailData.distance[e.key];
        spots.add(FlSpot(distance, e.value));
        hazardsMap[distance] =
            activeHazards.firstWhereOrNull((h) => h.location.index == e.key);
      }
    }
    final maxInterval = trailData.distance.last/5;
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
                style: theme.textTheme.titleMedium
            ),
          ),
        ),
        Card(
          elevation: 1,
          shadowColor: Colors.transparent,
          margin: EdgeInsets.zero,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: LineChart(
                LineChartData(
                    maxY: (trailData.maxElevation/50).ceil() * 50.0,
                    minY: (trailData.minElevation/50).floor() * 50.0,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false,
                        dotData: FlDotData(
                            checkToShowDot: (s, d) => hazardsMap[s.x] != null,
                            getDotPainter: (a, b, c, d) => FlDotCirclePainter(
                              color: CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context),
                              radius: 5,
                            )
                        ),
                      ),
                    ],
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
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
        ),
        // Container(
        //   decoration: BoxDecoration(
        //       borderRadius: const BorderRadius.all(Radius.circular(8)),
        //       color: CupertinoDynamicColor.resolve(CupertinoColors.systemFill, context).withAlpha(40)
        //   ),
        //   height: height,
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        //     child: LineChart(
        //       LineChartData(
        //           maxY: (trailData.maxElevation/50).ceil() * 50.0,
        //           minY: (trailData.minElevation/50).floor() * 50.0,
        //           lineBarsData: [
        //             LineChartBarData(
        //               spots: spots,
        //               isCurved: false,
        //               dotData: FlDotData(
        //                   checkToShowDot: (s, d) => hazardsMap[s.x] != null,
        //                   getDotPainter: (a, b, c, d) => FlDotCirclePainter(
        //                     color: CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context),
        //                     radius: 5,
        //                   )
        //               ),
        //             ),
        //           ],
        //           gridData: const FlGridData(show: false),
        //           borderData: FlBorderData(show: false),
        //           titlesData: FlTitlesData(
        //               topTitles: const AxisTitles(),
        //               rightTitles: const AxisTitles(),
        //               leftTitles: AxisTitles(
        //                   sideTitles: SideTitles(
        //                       showTitles: true,
        //                       reservedSize: 65,
        //                       getTitlesWidget: (yVal, meta) {
        //                         return Text("${yVal.round().toString()} ft");
        //                       },
        //                       interval: 50
        //                   )
        //               ),
        //               bottomTitles: AxisTitles(
        //                   sideTitles: SideTitles(
        //                       showTitles: true,
        //                       getTitlesWidget: (xVal, meta) {
        //                         final offInterval = (xVal % meta.appliedInterval);
        //                         final isRegInterval = (offInterval < 0.01 || offInterval > meta.appliedInterval - 0.01);
        //                         return isRegInterval ? Padding(
        //                           padding: const EdgeInsets.only(top: 4),
        //                           child: Text("${xVal.toStringRemoveTrailing(1)} mi"),
        //                         ) : Container();
        //                       },
        //                       interval: interval
        //                   )
        //               )
        //           )
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}