import 'package:flutter/material.dart';
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/model/hazard.dart';
import 'package:forest_park_reports/page/common/confirmation.dart';
import 'package:forest_park_reports/page/common/hazard_modal_base.dart';
import 'package:forest_park_reports/page/common/test_location_too_far.dart';
import 'package:forest_park_reports/provider/hazard_provider.dart';
import 'package:latlong2/latlong.dart';

/// The additional modal with the ui for reporting a trail hazard

createHazardUpdateModal(
    BuildContext context, HazardModel selectedHazard, bool isPresent) async {
  await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: HazardModal(
            title: "Update Hazard",
            options: const {
              false: Text("Cleared", style: TextStyle(color: Colors.green)),
              true: Text("Present", style: TextStyle(color: Colors.red)),
            },
            initialOption: isPresent,
            onSubmit:
                (context, ref, image, updateUuid, hazardType, comments) async {
              if (!await showConfirmationDialog(
                  context,
                  ConfirmationInfo(
                      title:
                          "Report hazard ${isPresent ? "present" : "cleared"}?",
                      content:
                          "Please make sure the hazard is ${isPresent ? "still present" : "gone"}.",
                      affirmative: "Yes"))) {
                return false;
              }

              if (context.mounted &&
                  !await testLocationTooFar(context, ref,
                      tolerance: kUpdateLocationTolerance,
                      actionLocation: LatLng(selectedHazard.location.latitude,
                          selectedHazard.location.longitude),
                      title: "Too far from hazard",
                      content:
                          "Hazard updates must be made in proximity to the hazard",
                      overrideEnabled: kLocationOverrideEnabled)) {
                return false;
              }

              ref.read(activeHazardProvider.notifier).updateHazard(
                    uuid: updateUuid,
                    hazard: selectedHazard.uuid,
                    active: isPresent,
                    imageFile: image,
                  );
              return true;
            },
          ),
        );
      });
}
