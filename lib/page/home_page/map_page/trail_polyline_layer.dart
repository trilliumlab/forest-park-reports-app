import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:forest_park_reports/model/relation.dart';
import 'package:forest_park_reports/provider/hazard_provider.dart';
import 'package:forest_park_reports/provider/panel_position_provider.dart';
import 'package:forest_park_reports/provider/relation_provider.dart';
import 'package:forest_park_reports/provider/trail_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

class TrailPolylineLayer extends ConsumerWidget {
  const TrailPolylineLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRelationID = ref.watch(selectedRelationProvider);
    final relations =
        ref.watch(relationsProvider.select((value) => value.value));
    final trails = ref.watch(trailsProvider).value;
    if (relations == null || trails == null) {
      return Container();
    }
    final selectedRelation =
        selectedRelationID == null ? null : relations.get(selectedRelationID);

    final LayerHitNotifier hitNotifier = ValueNotifier(null);

    return MouseRegion(
      hitTestBehavior: HitTestBehavior.deferToChild,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final LayerHitResult? hitResult = hitNotifier.value;
          if (hitResult != null && hitResult.hitValues.isNotEmpty) {
            // We clicked a polyline

            // deselect hazards
            ref.read(selectedHazardProvider.notifier).deselect();

            // select polyline
            final tag = hitResult.hitValues.first;
            if (selectedRelation?.members.contains(tag) ?? false) {
              if (ref.read(panelPositionProvider).position == PanelState.OPEN) {
                ref
                    .read(panelPositionProvider.notifier)
                    .move(PanelState.SNAPPED);
              } else {
                ref.read(selectedHazardProvider.notifier).deselect();
                ref.read(selectedRelationProvider.notifier).deselect();
                ref
                    .read(panelPositionProvider.notifier)
                    .move(PanelState.HIDDEN);
              }
            } else {
              ref.read(selectedRelationProvider.notifier).select(
                  relations.firstWhere((r) => r.members.contains(tag)).id);
              if (ref.read(panelPositionProvider).position.index <=
                  PanelState.COLLAPSED.index) {
                ref
                    .read(panelPositionProvider.notifier)
                    .move(PanelState.SNAPPED);
              }
            }
          }
        },
        child: PolylineLayer(
          hitNotifier: hitNotifier,
          polylines: trails
              .map((trail) {
                return selectedRelation?.members.contains(trail.id) ?? false
                    ? Polyline(
                        hitValue: trail.id,
                        points: trail.geometry,
                        strokeWidth: 1.0,
                        borderColor: Colors.green.withAlpha(80),
                        borderStrokeWidth: 8.0,
                        color: Colors.green,
                      )
                    : Polyline(
                        hitValue: trail.id,
                        points: trail.geometry,
                        strokeWidth: 1.0,
                        color: Colors.orange,
                      );
              })
              .whereNotNull()
              .toList()
            ..sort((a, b) {
              // sorts the list to have selected polylines at the top
              return (selectedRelation?.members.contains(a.hitValue) ?? false
                      ? 1
                      : 0) -
                  (selectedRelation?.members.contains(b.hitValue) ?? false
                      ? 1
                      : 0);
            }),
        ),
      ),
    );
  }
}
