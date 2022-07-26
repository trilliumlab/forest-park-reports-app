import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/providers/hazard_provider.dart';
import 'package:forest_park_reports/util/outline_box_shadow.dart';
import 'package:forest_park_reports/widgets/hazard_image.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';

class HazardInfoPopup extends StatelessWidget {
  final Hazard hazard;
  const HazardInfoPopup({super.key, required this.hazard});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const radius = BorderRadius.all(Radius.circular(8));
    return Container(
      decoration: const BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          OutlineBoxShadow(
            color: Colors.black26,
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: PlatformWidgetBuilder(
          cupertino: (context, child, _) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context).withAlpha(210),
              child: child,
            ),
          ),
          material: (_, child, __) => Container(
            color: theme.colorScheme.background,
            child: child,
          ),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                  child: Text(
                    hazard.hazard.displayName,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                  child: Text(
                    hazard.timeString(),
                  ),
                ),
                if (hazard.image != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                    child: ClipRRect(
                      borderRadius: radius,
                      child: AspectRatio(
                          aspectRatio: 3/4,
                          child: SizedBox.shrink(
                            child: HazardImage(hazard.image!),
                          )
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HazardMarker extends Marker {
  final Hazard hazard;
  HazardMarker({required this.hazard, super.icon, super.onTap}) : super(markerId: MarkerId(hazard.uuid), position: hazard.location);
}

class MarkerInfo extends ConsumerStatefulWidget {
  final Function getBitmapImage;
  final Hazard? hazard;
  const MarkerInfo({super.key, required this.getBitmapImage, this.hazard});

  @override
  ConsumerState<MarkerInfo> createState() => _MarkerInfoState();
}

class _MarkerInfoState extends ConsumerState<MarkerInfo> {
  final markerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  Future getUint8List(GlobalKey markerKey) async {
    if (widget.hazard?.image != null) {
      print("rendering widget");
      final boundary = markerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      widget.getBitmapImage(byteData!.buffer.asUint8List());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hazard?.image != null) {
      ref.listen(hazardPhotoProgressProvider(widget.hazard!.image!), (prev, next) {
        getUint8List(markerKey);
      });
      ref.listen(hazardPhotoProvider(widget.hazard!.image!), (prev, next) {
        print("image done");
        getUint8List(markerKey);
      });
    }
    return widget.hazard == null ? Container() : RepaintBoundary(
      key: markerKey,
      child: HazardInfoPopup(hazard: widget.hazard!),
    );
  }
}
