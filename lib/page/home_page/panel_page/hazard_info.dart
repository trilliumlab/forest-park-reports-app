import 'package:flutter/material.dart';
import 'package:forest_park_reports/model/hazard_update.dart';

import 'package:forest_park_reports/page/home_page/panel_page/hazard_image.dart';

const double kImageHeight = 80;

/// A widget for the main panel modal with info on a singular hazard
class UpdateInfoWidget extends StatelessWidget {
  final HazardUpdateModel update;
  const UpdateInfoWidget({super.key, required this.update});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(2.5)),
                  color: update.offline
                      ? Colors.grey
                      : update.active
                          ? Colors.red
                          : Colors.green,
                ),
                height: kImageHeight,
                width: 5,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    update.active ? "Reported Present" : "Reported Cleared",
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(update.timeString(), style: theme.textTheme.titleMedium)
                ],
              ),
            ],
          ),
          SizedBox(
              height: kImageHeight,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: (update.image != null)
                      ? HazardImage(update.image!, blurHash: update.blurHash)
                      : Container(),
                ),
              )),
        ],
      ),
    );
  }
}
