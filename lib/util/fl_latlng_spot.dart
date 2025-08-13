import 'package:fl_chart/fl_chart.dart';
import 'package:turf/turf.dart';

import '../model/hazard.dart';

class FlCoordinateSpot extends FlSpot {
  final Position position;
  final HazardModel? hazard;
  const FlCoordinateSpot(super.x, super.y, this.position, [this.hazard]);
}
