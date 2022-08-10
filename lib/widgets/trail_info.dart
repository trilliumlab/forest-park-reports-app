import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/pages/home_screen.dart';
import 'package:forest_park_reports/providers/hazard_provider.dart';
import 'package:forest_park_reports/providers/panel_position_provider.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:forest_park_reports/widgets/forest_park_map.dart';

class TrailHazardsWidget extends ConsumerWidget {
  final Trail trail;
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

class HazardInfoWidget extends ConsumerWidget {
  final Hazard hazard;
  const HazardInfoWidget({super.key, required this.hazard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return PlatformTextButton(
      padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
      onPressed: () {
        ref.read(selectedHazardProvider.notifier).selectAndMove(hazard);
        ref.read(panelPositionProvider.notifier).move(PanelPosition.closed);
      },
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
                  style: theme.textTheme.subtitle1
              )
            ],
          ),
          if (hazard.image != null)
            SizedBox(
                height: 80,
                child: AspectRatio(
                  aspectRatio: 4/3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: HazardImage(hazard.image!),
                  ),
                )
            )
        ],
      ),
    );
  }
}

class TrailInfoWidget extends StatelessWidget {
  final ScrollController controller;
  final String title;
  final Widget snapWidget;
  final Widget fullWidget;
  const TrailInfoWidget({
    super.key,
    required this.controller,
    required this.title,
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
              title,
              style: theme.textTheme.headline6,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
        ),
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
    final filterInterval = (trail.track!.elevation.length/100).round();
    for (final e in trail.track!.elevation.asMap().entries) {
      if (e.key % filterInterval == 0) {
        final distance = trail.track!.distance[e.key];
        spots.add(FlSpot(distance, e.value));
        hazardsMap[distance] =
            activeHazards.firstWhereOrNull((h) => h.location.index == e.key);
      }
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