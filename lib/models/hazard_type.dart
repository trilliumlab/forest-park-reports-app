import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum HazardType {
  tree("Fallen Tree", CupertinoIcons.tree),
  flood("Flooded Trail", Icons.flood_rounded),
  other("Other Hazard", CupertinoIcons.question_diamond_fill);

  const HazardType(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}
