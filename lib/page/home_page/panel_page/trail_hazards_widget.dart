import 'package:flutter/material.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/model/hazard_type.dart';
import 'package:forest_park_reports/page/home_page/panel_page/hazard_image.dart';
import 'package:forest_park_reports/provider/geojson_provider.dart';
import 'package:forest_park_reports/provider/selected_trail_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:turf/turf.dart' show Feature;

/// A list of hazards on a given trail when that trail is clicked on
class TrailHazardsWidget extends ConsumerWidget {
  final Object? routeId;
  const TrailHazardsWidget({super.key, required this.routeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reports = ref.watch(reportProvider);
    final trailHazards = reports.valueOrNull?.features
        .where((report) =>
            report.properties?['route'].toString() == routeId.toString())
        .toList();

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
          child: trailHazards != null ? Column(
              children: trailHazards.map((report) =>
                  HazardInfoWidget(
                    report: report,
                  )).toList(),
              ) : const Center(
                child: CircularProgressIndicator(),
              ),
        ),
      ],
    );
  }
}

class HazardInfoWidget extends ConsumerWidget {
  final Feature report;
  const HazardInfoWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hazardType =
        HazardType.fromCategory(report.properties?['category'] as String?);
    final image = report.properties?['image'] as String?;
    final blurHash = report.properties?['blurHash'] as String?;
    final reportedAt = report.properties?['reportedAt'] as String?;
    final reportedTime =
        reportedAt != null ? DateTime.tryParse(reportedAt) : null;

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
      child: TextButton(
        onPressed: () {
          ref.read(selectedTrailProvider.notifier).clear();
          ref.read(selectedReportProvider.notifier).select(report);
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
                  hazardType.displayName,
                  style: theme.textTheme.titleLarge,
                ),
                if (reportedTime != null)
                  Text(
                      kDisplayDateFormat.format(reportedTime.toLocal()),
                      style: theme.textTheme.titleMedium
                  )
              ],
            ),
            if (image != null)
              SizedBox(
                  height: 80,
                  child: AspectRatio(
                    aspectRatio: 4/3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: HazardImage(image, blurHash: blurHash),
                    ),
                  )
              )
          ],
        ),
      ),
    );
  }
}
