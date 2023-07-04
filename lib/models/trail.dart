import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:simplify/simplify.dart';

part 'trail.freezed.dart';

const haversine = DistanceHaversine(roundResult: false);
/// Represents a GPX file (list of coordinates) in an easy to use way
class TrailModel {
  String name = "";
  List<LatLng> path = [];
  List<double> elevation = [];
  List<ColorStop> colors = [];
  List<double> distance = [0];
  double maxElevation = 0;
  double minElevation = double.infinity;
  // tracks the elevation positive delta
  double totalIncline = 0;
  // tracks the elevation negative delta
  double totalDecline = 0;

  final Map<PolylineResolutionModel, List<LatLng>> _pathCache = {};
  List<LatLng> getPath(PolylineResolutionModel resolution) {
    if (!_pathCache.containsKey(resolution)) {
      _pathCache[resolution] = simplify(path, tolerance: resolution.tolerance);
    }
    return _pathCache[resolution]!;
  }

  // constructs a track from binary encoded track
  TrailModel.decode(Uint8List buffer) {
    final data = buffer.buffer.asByteData();
    // keep track of read position
    var cursor = 0;

    // decode trail name
    final nameLength = data.getUint16(cursor, kNetworkEndian);
    cursor += 2;
    name = ascii.decode(buffer.getRange(cursor, cursor+=nameLength).toList());

    // decode colors
    final colorLength = data.getUint16(cursor, kNetworkEndian);
    cursor += 2;
    final colorEnd = cursor + colorLength;
    while (cursor < colorEnd) {
      final index = data.getUint16(cursor, kNetworkEndian);
      cursor += 2;
      final r = data.getUint8(cursor++);
      final g = data.getUint8(cursor++);
      final b = data.getUint8(cursor++);
      colors.add(ColorStop(index, Color.fromARGB(255, r, g, b)));
    }

    // decode path data
    final pathLength = data.getUint16(cursor, kNetworkEndian);
    cursor += 2;
    final pathEnd = cursor + pathLength;
    while (cursor < pathEnd) {
      // read latlong
      final latitude = data.getFloat32(cursor, kNetworkEndian);
      cursor += 4;
      final longitude = data.getFloat32(cursor, kNetworkEndian);
      cursor += 4;
      final point = LatLng(latitude, longitude);
      // calculate distance and add to array
      if (path.isNotEmpty) {
        distance.add(
            distance.last + haversine
                .as(LengthUnit.Mile, path.last, point)
        );
      }
      // add latlong to path
      path.add(point);

      // read elevation
      final double elevation;
      if (this.elevation.isEmpty) {
        elevation = data.getFloat32(cursor, kNetworkEndian);
        cursor += 4;
      } else {
        elevation = this.elevation.last + data.getInt8(cursor++);
      }
      // calculate max and min elevation + delta
      final delta = elevation - (this.elevation.lastOrNull ?? elevation);
      if (delta >= 0) {
        totalIncline += delta;
        if (elevation > maxElevation) {maxElevation = elevation;}
      }
      if (delta <= 0) {
        totalDecline -= delta;
        if (elevation < minElevation) {minElevation = elevation;}
      }
      // add elevation
      this.elevation.add(elevation);
    }
  }

  Uint8List encode() {
    final builder = BytesBuilder();

    // encode trail name
    builder.addUint16(name.length);
    builder.add(ascii.encode(name));

    // encode colors
    builder.addUint16(colors.length * (2+1+1+1));
    for (final color in colors) {
      builder.addUint16(color.index);
      builder.addByte(color.color.red);
      builder.addByte(color.color.green);
      builder.addByte(color.color.blue);
    }

    // encode path data
    builder.addUint16(path.length * (4+4+1));
    for (int i=0; i<path.length; i++) {
      builder.addFloat32(path[i].latitude);
      builder.addFloat32(path[i].longitude);
      if (i==0) {
        builder.addFloat32(elevation[i]);
      } else {
        builder.addByte((
            (elevation[i] - elevation[0])
                - (elevation[i-1] - elevation[0])
        ).round());
      }
    }

    return builder.takeBytes();
  }
}

enum PolylineResolutionModel {
  full(0),
  ultra(0.00004),
  high(0.0002),
  medium(0.0004),
  low(0.0007);

  final double tolerance;
  const PolylineResolutionModel(this.tolerance);

  factory PolylineResolutionModel.resolutionFromZoom(double zoom) {
    if (zoom < 12) {
      return PolylineResolutionModel.low;
    } else if (zoom < 13) {
      return PolylineResolutionModel.medium;
    } else if (zoom < 14.5) {
      return PolylineResolutionModel.high;
    } else if (zoom < 16) {
      return PolylineResolutionModel.ultra;
    } else {
      return PolylineResolutionModel.full;
    }
  }
}

@freezed
class ColorStop with _$ColorStop {
  const ColorStop._();
  const factory ColorStop(int index, Color color) = _ColorStop;
}
