import 'package:fl_chart/fl_chart.dart';
import 'package:latlong2/latlong.dart';

import '../models/hazard.dart';

class FlCoordinateSpot extends FlSpot {
  final LatLng position;
  final HazardModel? hazard;
  FlCoordinateSpot(super.x, super.y, this.position, [this.hazard]);
}
