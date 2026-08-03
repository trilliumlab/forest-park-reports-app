import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:forest_park_reports/util/fl_latlng_spot.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:turf/turf.dart';

/// Graph displayed in the panel modal when a trail is clicked on
class TrailElevationGraph extends ConsumerWidget {
  final Feature trail;
  final double height;
  const TrailElevationGraph({
    super.key,
    required this.trail,
    required this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final distances = [0.0];
    var cumulativeDistance = 0.0;
    trail.segmentEach(
        (seg, featureIndex, multiFeatureIndex, geometryIndex, segmentIndex) {
      final distance = length(seg, Unit.meters);
      distances.add(distance + cumulativeDistance);
      cumulativeDistance += distance;
    });

    final maxElevation =
        trail.coordAll().map((pos) => pos?.elementAt(2) ?? 0).reduce(max);
    final minElevation = trail
        .coordAll()
        .map((pos) => pos?.elementAt(2) ?? double.infinity)
        .reduce(min);

    final List<FlCoordinateSpot> spots = [];
    final filterInterval =
        max((trail.coordAll().length / kElevationMaxEntries).round(), 1);

    for (final (i, coord) in trail.coordAll().indexed) {
      if (i % filterInterval == 0) {
        final distance = distances[i];
        // TODO: pass the hazard at this point once hazards are plotted on the graph again.
        spots.add(FlCoordinateSpot(
            distance, coord?.elementAt(2).toDouble() ?? 0.0, coord!, null));
      }
    }

    final maxInterval = distances.last / 5;
    final interval = maxInterval - maxInterval / 20;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Elevation", style: theme.textTheme.titleMedium),
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
              child: Builder(builder: (context) {
                return LineChart(
                  LineChartData(
                      maxY: (maxElevation / 50).ceil() * 50.0,
                      minY: (minElevation / 50).floor() * 50.0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          dotData: FlDotData(
                              checkToShowDot: (s, d) {
                                final coordSpot = s is FlCoordinateSpot
                                    ? s
                                    : spots[d.spots.indexOf(s)];
                                return coordSpot.hazard != null;
                              },
                              getDotPainter: (a, b, c, d) => FlDotCirclePainter(
                                    color: Colors.red,
                                    radius: 5,
                                  )),
                        ),
                      ],
                      // TODO: re-add cursor-follows-graph-drag behavior (previously drove mapCursorProvider).
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 65,
                                // TODO add units to settings
                                getTitlesWidget: (yVal, meta) {
                                  return Text("${yVal.round().toString()} m");
                                },
                                interval: 50)),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (xVal, meta) {
                                  final offInterval =
                                      (xVal % meta.appliedInterval);
                                  final isRegInterval = (offInterval < 0.01 ||
                                      offInterval >
                                          meta.appliedInterval - 0.01);
                                  return isRegInterval
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                              "${(xVal / 1000).toStringRemoveTrailing(1)} km"),
                                        )
                                      : Container();
                                },
                                interval: interval)),
                      )),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
