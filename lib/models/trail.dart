import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:forest_park_reports/consts.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:simplify/simplify.dart';

part 'trail.freezed.dart';

// TODO move
class Coordinate extends LatLng {
  final double elevation;
  const Coordinate(super.latitude, super.longitude, this.elevation);
}

@freezed
class BoundsModel with _$BoundsModel {
  const BoundsModel._();

  const factory BoundsModel({
    required double minlat,
    required double minlon,
    required double maxlat,
    required double maxlon,
  }) = _BoundsModel;
}

const haversine = DistanceHaversine(roundResult: false);
/// Represents a OSM way in an easy to use way
class TrailModel {
  String system = "";
  int id = -1;
  Map<String, String> tags = {};
  late BoundsModel bounds;
  List<int> nodes = [];
  List<Coordinate> geometry = [];
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
      _pathCache[resolution] = simplify(geometry, tolerance: resolution.tolerance);
    }
    return _pathCache[resolution]!;
  }

  // constructs a track from binary encoded track
  TrailModel.decode(Uint8List buffer) {
    final data = buffer.buffer.asByteData();
    // keep track of read position
    var cursor = 0;

    // decode trail name
    final systemLength = data.getUint16(cursor, kNetworkEndian);
    cursor += 2;
    system = ascii.decode(buffer.getRange(cursor, cursor+=systemLength).toList());

    // decode id
    id = data.getUint64(cursor, kNetworkEndian);
    cursor += 8;

    print("DECODING ID $id");

    // decode tags
    final tagSize = data.getUint16(cursor, kNetworkEndian);
    cursor += 2;
    for (int i=0; i<tagSize; i++) {
      final keyLength = data.getUint16(cursor, kNetworkEndian);
      cursor += 2;
      final key = ascii.decode(buffer.getRange(cursor, cursor+=keyLength).toList());
      final valueLength = data.getUint16(cursor, kNetworkEndian);
      cursor += 2;
      final value = ascii.decode(buffer.getRange(cursor, cursor+=valueLength).toList());
      tags[key] = value;
    }

    // decode bounds
    final minlat = data.getFloat32(cursor, kNetworkEndian);
    cursor += 4;
    final minlon = data.getFloat32(cursor, kNetworkEndian);
    cursor += 4;
    final maxlat = data.getFloat32(cursor, kNetworkEndian);
    cursor += 4;
    final maxlon = data.getFloat32(cursor, kNetworkEndian);
    cursor += 4;
    bounds = BoundsModel(
      minlat: minlat,
      minlon: minlon,
      maxlat: maxlat,
      maxlon: maxlon
    );

    // decode nodes
    final nodeSize = data.getUint16(cursor, kNetworkEndian);
    cursor += 2;
    print("NODE SIZE $nodeSize");
    for (int i=0; i<nodeSize; i++) {
      nodes.add(data.getUint64(cursor, kNetworkEndian));
      cursor += 8;
    }

    print("NODES DECODED ${nodes.length}");

    // decode geometry
    final geometrySize = data.getUint16(cursor, kNetworkEndian);
    print("GEOMETRY SIZE $geometrySize");
    cursor += 2;
    for (int i=0; i<geometrySize; i++) {
      // read latlong
      final latitude = data.getFloat32(cursor, kNetworkEndian);
      cursor += 4;
      final longitude = data.getFloat32(cursor, kNetworkEndian);
      cursor += 4;

      // read elevation
      final double elevation;
      if (geometry.isEmpty) {
        elevation = data.getFloat32(cursor, kNetworkEndian);
        cursor += 4;
      } else {
        elevation = geometry.last.elevation + (data.getInt8(cursor++).toDouble()/4);
      }
      // calculate max and min elevation + delta
      final delta = elevation - (geometry.lastOrNull?.elevation ?? elevation);
      if (delta >= 0) {
        totalIncline += delta;
        if (elevation > maxElevation) {maxElevation = elevation;}
      }
      if (delta <= 0) {
        totalDecline -= delta;
        if (elevation < minElevation) {minElevation = elevation;}
      }

      final coord = Coordinate(latitude, longitude, elevation);
      // calculate distance and add to array
      if (geometry.isNotEmpty) {
        distance.add(
            distance.last + haversine
                .as(LengthUnit.Mile, geometry.last, coord)
        );
      }
      // add latlong to path
      geometry.add(coord);
    }

    print("DECODED TRAIL ${system}");
  }

  Uint8List encode() {
    final builder = BytesBuilder();

    // TODO update encoding
    // // encode trail name
    // builder.addUint16(name.length);
    // builder.add(ascii.encode(name));
    //
    // // encode colors
    // builder.addUint16(colors.length * (2+1+1+1));
    // for (final color in colors) {
    //   builder.addUint16(color.index);
    //   builder.addByte(color.color.red);
    //   builder.addByte(color.color.green);
    //   builder.addByte(color.color.blue);
    // }
    //
    // // encode path data
    // builder.addUint16(path.length * (4+4+1));
    // for (int i=0; i<path.length; i++) {
    //   builder.addFloat32(path[i].latitude);
    //   builder.addFloat32(path[i].longitude);
    //   if (i==0) {
    //     builder.addFloat32(elevation[i]);
    //   } else {
    //     builder.addByte((
    //         (elevation[i] - elevation[0])
    //             - (elevation[i-1] - elevation[0])
    //     ).round());
    //   }
    // }

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
