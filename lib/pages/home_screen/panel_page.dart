import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:forest_park_reports/models/hazard_update.dart';
import 'package:forest_park_reports/pages/home_screen.dart';
import 'package:forest_park_reports/providers/hazard_provider.dart';
import 'package:forest_park_reports/providers/panel_position_provider.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:forest_park_reports/util/outline_box_shadow.dart';
import 'package:forest_park_reports/widgets/forest_park_map.dart';
import 'package:forest_park_reports/widgets/hazard_info.dart';
import 'package:forest_park_reports/widgets/trail_info.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PanelPage extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final ScreenPanelController panelController;
  const PanelPage({
    super.key,
    required this.scrollController,
    required this.panelController,
  });
  @override
  ConsumerState<PanelPage> createState() => _PanelPageState();
}

//TODO stateless?
class _PanelPageState extends ConsumerState<PanelPage> {
  @override
  Widget build(BuildContext context) {
    final selectedTrail = ref.watch(selectedTrailProvider);
    final selectedHazard = ref.watch(selectedHazardProvider.select((h) => h.hazard));
    final hazardTrail = selectedHazard == null ? null : ref.read(trailProvider(selectedHazard.location.trail));

    HazardUpdateList? hazardUpdates;
    String? lastImage;
    if (selectedHazard != null) {
      hazardUpdates = ref.watch(hazardUpdatesProvider(selectedHazard.uuid));
      lastImage = hazardUpdates!.lastImage;
    }

    return Panel(
      // panel for when a hazard is selected
      child: selectedHazard != null ? TrailInfoWidget(
        scrollController: widget.scrollController,
        panelController: widget.panelController,
        // TODO fetch trail name
        title: "${selectedHazard.hazard.displayName} on ${hazardTrail!.value}",
        bottomWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: PlatformTextButton(
                  onPressed: () {
                    ref.read(hazardUpdatesProvider(selectedHazard.uuid).notifier).create(
                      HazardUpdateRequestModel(
                        hazard: selectedHazard.uuid,
                        active: false,
                      ),
                    );
                    ref.read(panelPositionProvider.notifier).move(PanelPositionState.closed);
                    ref.read(selectedHazardProvider.notifier).deselect();
                    ref.read(activeHazardProvider.notifier).refresh();
                  },
                  padding: EdgeInsets.zero,
                  child: Text(
                    "Cleared",
                    style: TextStyle(color: CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 20),
                child: PlatformTextButton(
                  onPressed: () {
                    ref.read(hazardUpdatesProvider(selectedHazard.uuid).notifier).create(
                      HazardUpdateRequestModel(
                        hazard: selectedHazard.uuid,
                        active: true,
                      ),
                    );
                    ref.read(panelPositionProvider.notifier).move(PanelPositionState.closed);
                    ref.read(selectedHazardProvider.notifier).deselect();
                    ref.read(activeHazardProvider.notifier).refresh();
                  },
                  padding: EdgeInsets.zero,
                  child: Text(
                    "Present",
                    style: TextStyle(color: CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context)),
                  ),
                ),
              ),
            ),
          ],
        ),
        children: [
          if (lastImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Opacity(
                opacity: widget.panelController.snapWidgetOpacity,
                child: SizedBox(
                  height: widget.panelController.panelSnapHeight * 0.7
                      + (widget.panelController.panelOpenHeight-widget.panelController.panelSnapHeight)*widget.panelController.pastSnapPosition * 0.6,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: HazardImage(lastImage),
                  ),
                ),
              ),
            ),
          // TODO move this out of here
          Card(
            elevation: 1,
            shadowColor: Colors.transparent,
            margin: EdgeInsets.zero,
            child: Column(
              children: hazardUpdates!.map((update) => UpdateInfoWidget(
                update: update,
              )).toList(),
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
      ):

      // panel for when a trail is selected
      selectedTrail != null ? TrailInfoWidget(
        scrollController: widget.scrollController,
        panelController: widget.panelController,
        // TODO show real name
        title: selectedTrail.toString(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Opacity(
              opacity: widget.panelController.snapWidgetOpacity,
              child: TrailElevationGraph(
                trailID: selectedTrail,
                height: widget.panelController.panelSnapHeight*0.6,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Opacity(
              opacity: widget.panelController.fullWidgetOpacity,
              child: TrailHazardsWidget(
                  trail: selectedTrail
              ),
            ),
          ),
        ],
      ):

      // panel for when nothing is selected
      TrailInfoWidget(
          scrollController: widget.scrollController,
          panelController: widget.panelController,
          children: const []
      ),
    );
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  const Panel({
    Key? key,
    required this.child
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panelRadius = BorderRadius.vertical(top: Radius.circular(isCupertino(context) ? 8 : 18));
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      // pass the scroll controller to the list view so that scrolling panel
      // content doesn't scroll the panel except when at the very top of list
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: panelRadius,
            boxShadow: const [
              OutlineBoxShadow(
                color: Colors.black26,
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: panelRadius,
            child: PlatformWidget(
                cupertino: (context, _) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                  child: Container(
                    color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context).withAlpha(210),
                    child: child,
                  ),
                ),
                material: (_, __) => Container(
                  color: theme.colorScheme.background,
                  child: child,
                )
            ),
          ),
        ),
      ),
    );
  }
}

//TODO move to widgets
class PlatformFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  const PlatformFAB({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PlatformWidget(
      cupertino: (context, _) {
        const fabRadius = BorderRadius.all(Radius.circular(8));
        return Container(
          decoration: const BoxDecoration(
            borderRadius: fabRadius,
            boxShadow: [
              OutlineBoxShadow(
                color: Colors.black26,
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: fabRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: SizedBox(
                width: 50,
                height: 50,
                child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context).withAlpha(210),
                    pressedOpacity: 0.9,
                    onPressed: onPressed,
                    child: child
                ),
              ),
            ),
          ),
        );
      },
      material: (_, __) => FloatingActionButton(
        backgroundColor: theme.colorScheme.background,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class PlatformPill extends StatelessWidget {
  const PlatformPill({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final isIos = isCupertino(context);
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: isIos ? 5 : 10
        ),
        width: isIos ? 35 : 26,
        height: 5,
        decoration: BoxDecoration(
            color: isIos
                ? CupertinoDynamicColor.resolve(CupertinoColors.systemGrey2, context)
                : theme.colorScheme.onBackground,
            borderRadius: const BorderRadius.all(Radius.circular(12.0))),
      ),
    );
  }

}
