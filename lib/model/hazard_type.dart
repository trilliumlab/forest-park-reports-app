import 'package:flutter/material.dart';

enum HazardType {
  fallenTree("Fallen Tree", Icons.park_rounded, "fallenTree"),
  flood("Drainage Issue", Icons.water_rounded, "drainage"),
  erosion("Erosion Issue", Icons.landslide_rounded, "erosion"),
  structureFailure("Structure Failure", Icons.home_rounded, "structureFailure"),
  damagedSign("Damaged Sign", Icons.signpost_rounded, "damagedSign"),
  seasonal("Seasonal Issue", Icons.calendar_month_rounded, "seasonal"),
  other("Other Hazard", Icons.help_outline_rounded, "other");

  const HazardType(this.displayName, this.icon, this.category);
  final String displayName;
  final IconData icon;

  /// The category string used by the new backend's report API. Differs from
  /// [name] only for `flood`, which the new backend calls "drainage".
  final String category;

  static HazardType fromCategory(String? category) => HazardType.values
      .firstWhere((t) => t.category == category, orElse: () => HazardType.other);
}
