import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/model/hazard_type.dart';
import 'package:forest_park_reports/page/common/hazard_modal_base.dart';
import 'package:forest_park_reports/page/common/test_location_too_far.dart';
import 'package:forest_park_reports/provider/hazard_provider.dart';
import 'package:forest_park_reports/provider/location_provider.dart';
import 'package:forest_park_reports/provider/trail_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/// The additional modal with the ui for reporting a trail hazard
createHazardAddModal(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: HazardModal(
          title: "Report New Hazard",
          options: {
            for (final type in HazardType.values)
              type: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type.icon,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(type.displayName),
                ],
              )
          },
          onSubmit: (context, ref, image, uuid, hazardType, comments) async {
            if (!await testLocationTooFarDynamic(context, ref,
                tolerance: kAddLocationTolerance,
                actionLocationGetter: (context, ref, loc) {
              var completer = Completer<LatLng>();
              ref
                  .read(trailsProvider.notifier)
                  .snapLocation(loc)
                  .then((result) => completer.complete(result.location));
              return completer.future;
            },
                title: "Too far from trail",
                content: "Reports must be made on a marked Forest Park trail",
                overrideEnabled: kLocationOverrideEnabled)) {
              return false;
            }

            final location = await Geolocator.getCurrentPosition();
            final snappedLoc = await ref
                .read(trailsProvider.notifier)
                .snapLocation(location.latLng()!);

            final activeHazardNotifier =
                ref.read(activeHazardProvider.notifier);

            await activeHazardNotifier.createHazard(
              uuid: uuid,
              hazard: hazardType!,
              location: snappedLoc.location,
              imageFile: image,
            );

            return true;
          },
        ),
      );
    },
  );
}