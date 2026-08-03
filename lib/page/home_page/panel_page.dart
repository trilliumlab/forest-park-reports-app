import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forest_park_reports/provider/geojson_provider.dart';
import 'package:forest_park_reports/provider/panel_position_provider.dart';
import 'package:forest_park_reports/provider/selected_trail_provider.dart';
import 'package:forest_park_reports/util/panel_values.dart';
import 'package:forest_park_reports/model/hazard_update.dart';
import 'package:forest_park_reports/provider/hazard_provider.dart';
import 'package:forest_park_reports/util/outline_box_shadow.dart';
import 'package:forest_park_reports/page/home_page/panel_page/hazard_image.dart';
import 'package:forest_park_reports/page/home_page/panel_page/hazard_info.dart';
import 'package:forest_park_reports/page/home_page/panel_page/trail_info.dart';
import 'package:forest_park_reports/page/home_page/panel_page/trail_elevation_graph.dart';
import 'package:forest_park_reports/page/home_page/panel_page/trail_hazards_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

/// The sliding-up modal with info on the current selected trail or hazard on the map
class PanelPage extends ConsumerWidget {
  final ScrollController scrollController;
  final PanelController panelController;
  const PanelPage({
    super.key,
    required this.scrollController,
    required this.panelController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTrail = ref.watch(selectedTrailProvider);
    final selectedReport = ref.watch(selectedReportProvider);
    final reportRoute = ref
        .read(routeProvider)
        .valueOrNull
        ?.features
        .firstWhereOrNull((route) =>
            route.id.toString() ==
            selectedReport?.properties?["route"].toString());
    final selectedHazard =
        ref.watch(selectedHazardProvider.select((h) => h.hazard));

    HazardUpdateList? hazardUpdates;
    //lastImage can be removed if it is not needed
    String? lastImage;
    final reportImage = selectedReport?.properties?["image"]?.toString();
    final reportBlurHash = selectedReport?.properties?["blurHash"]?.toString();
    if (selectedHazard != null) {
      hazardUpdates =
          ref.watch(hazardUpdatesProvider(selectedHazard.uuid)).valueOrNull;
      lastImage = hazardUpdates?.lastImage;
    }

    return Panel(
      // panel for when a hazard is selected
      child: selectedReport != null
          ? TrailInfoWidget(
              scrollController: scrollController,
              panelController: panelController,
              // TODO fetch trail name
              title:
                  "${selectedReport.properties?["category"]} on ${reportRoute?.properties?["title"] ?? "Unnamed Trail"}",
              bottomWidget: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 10),
                      child: TextButton(
                        onPressed: () async {
                          ref
                              .read(panelPositionProvider.notifier)
                              .move(PanelState.COLLAPSED);
                          // await createHazardUpdateModal(
                          //     context, selectedHazard, false);
                          ref
                              .read(panelPositionProvider.notifier)
                              .move(PanelState.SNAPPED);
                        },
                        child: Text(
                          "Report Cleared",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 20),
                      child: TextButton(
                        onPressed: () async {
                          ref
                              .read(panelPositionProvider.notifier)
                              .move(PanelState.COLLAPSED);
                          // await createHazardUpdateModal(
                          //     context, selectedHazard, true);
                          ref
                              .read(panelPositionProvider.notifier)
                              .move(PanelState.SNAPPED);
                        },
                        child: Text(
                          "Report Present",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              children: [
                if (reportImage != null && reportImage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Opacity(
                      opacity: ((panelController.panelPosition -
                                  PanelValues.collapsedFraction(context)) /
                              (PanelValues.snapFraction(context) -
                                  PanelValues.collapsedFraction(context)))
                          .clamp(0, 1),
                      child: SizedBox(
                        height: PanelValues.snapHeight(context) * 0.6 +
                            max(
                                    panelController.panelPosition -
                                        PanelValues.snapFraction(context),
                                    0) *
                                1.2 *
                                PanelValues.snapHeight(context),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          child: HazardImage(
                            reportImage,
                            blurHash: reportBlurHash,
                          ),
                        ),
                      ),
                    ),
                  ),
                // TODO move this out of here
                Opacity(
                  opacity: ((panelController.panelPosition -
                              PanelValues.collapsedFraction(context)) /
                          (PanelValues.snapFraction(context) -
                              PanelValues.collapsedFraction(context)))
                      .clamp(0, 1),
                  child: Card(
                    elevation: 1,
                    shadowColor: Colors.transparent,
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: hazardUpdates
                              ?.map((update) => UpdateInfoWidget(
                                    update: update,
                                  ))
                              .toList() ??
                          [],
                    ),
                  ),
                ),
                // Container(
                //   decoration: BoxDecoration(
                //       borderRadius: const BorderRadius.all(Radius.circular(8)),
                //       color: isCupertino(context) ? CupertinoDynamicColor.resolve(CupertinoColors.systemFill, context).withAlpha(40) : Theme.of(context).colorScheme.secondaryContainer
                //   ),
                //   child: Column(
                //     children: hazardUpdates!.map((update) => UpdateInfoWidget(
                //       update: update,
                //     )).toList(),
                //   ),
                // ),
              ],
            )
          :

          // panel for when a trail is selected
          selectedTrail != null
              ? TrailInfoWidget(
                  scrollController: scrollController,
                  panelController: panelController,
                  // TODO show real name
                  title: selectedTrail.properties?['title'],
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Opacity(
                        opacity: ((panelController.panelPosition -
                                    PanelValues.collapsedFraction(context)) /
                                (PanelValues.snapFraction(context) -
                                    PanelValues.collapsedFraction(context)))
                            .clamp(0, 1),
                        child: TrailElevationGraph(
                          trail: selectedTrail,
                          height: PanelValues.snapHeight(context) * 0.6,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Opacity(
                        opacity: ((panelController.panelPosition -
                                    PanelValues.snapFraction(context)) /
                                (1 - PanelValues.snapFraction(context)))
                            .clamp(0, 1),
                        child: TrailHazardsWidget(routeId: selectedTrail.id),
                      ),
                    ),
                  ],
                )
              :

              // panel for when nothing is selected
              TrailInfoWidget(
                  scrollController: scrollController,
                  panelController: panelController,
                  children: const []),
    );
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  const Panel({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const panelRadius = BorderRadius.vertical(top: Radius.circular(18));
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      // pass the scroll controller to the list view so that scrolling panel
      // content doesn't scroll the panel except when at the very top of list
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: panelRadius,
            boxShadow: [
              OutlineBoxShadow(
                color: Colors.black26,
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: panelRadius,
            child: Container(
              color: theme.colorScheme.surface,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
