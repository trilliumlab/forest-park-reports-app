import 'package:flutter/material.dart';

enum HazardType {
  fallenTree("Fallen Tree", Icons.park_rounded),
  flood("Drainage Issue", Icons.water_rounded),
  erosion("Erosion Issue", Icons.landslide_rounded),
  structureFailure("Structure Failure", Icons.home_rounded),
  damagedSign("Damaged Sign", Icons.signpost_rounded),
  seasonal("Seasonal Issue", Icons.calendar_month_rounded),
  other("Other Hazard", Icons.help_outline_rounded);

  const HazardType(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}
