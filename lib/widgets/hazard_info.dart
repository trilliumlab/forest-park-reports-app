import 'package:flutter/material.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/widgets/forest_park_map.dart';

class UpdateInfoWidget extends StatelessWidget {
  final HazardUpdate update;
  const UpdateInfoWidget({super.key, required this.update});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                update.active ? "Confirmed" : "Deleted",
                style: theme.textTheme.titleLarge,
              ),
              Text(
                  update.timeString(),
                  style: theme.textTheme.subtitle1
              )
            ],
          ),
          SizedBox(
            height: 80,
            child: AspectRatio(
              aspectRatio: 4/3,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: (update.image != null) ? HazardImage(update.image!) : Container(),
              ),
            )
          )
        ],
      ),
    );
  }
}