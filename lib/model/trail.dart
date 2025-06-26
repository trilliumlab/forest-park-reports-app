import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' as drift;
import 'package:forest_park_reports/consts.dart';
import 'package:forest_park_reports/database/database.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'trail.freezed.dart';

class TrailList extends DelegatingList<TrailModel> {
  TrailList(super.trails);

  // Constructs a list of trails from a buffer
  factory TrailList.decode(Uint8List buffer) {
    final copy = Uint8List.fromList(buffer);
    final data = ByteData.sublistView(copy);

    // keep track of read position
    var cursor = 0;

    final List<TrailModel> trails = [];

    while (cursor < buffer.length) {
      final trailLength = data.getUint32(cursor, kNetworkEndian);
      cursor += 4;
      final trailData = copy.sublist(cursor, cursor + trailLength);
      cursor += trailLength;

      trails.add(TrailModel.decode(trailData));
    }

    return TrailList(trails);
  }

  TrailModel? get(int id) {
    return firstWhereOrNull((trail) => trail.id == id);
  }
}

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

/// Represents an OSM way in an easy to use way.
class TrailModel implements drift.Insertable<TrailModel> {
  String system = "";
  int id = -1;
  Map<String, String> tags = {};
  late BoundsModel bounds;
  List<int> nodes = [];
  List<Coordinate> geometry = [];
  List<double> distances = [0];
  double maxElevation = 0;
  double minElevation = double.infinity;
  // tracks the elevation positive delta
  double totalIncline = 0;
  // tracks the elevation negative delta
  double totalDecline = 0;

  /// Maps a database [TrailsTable] row to a [TrailModel].
  TrailModel.fromDb({required int id, required Uint8List data})
      : this.decode(data);

  /// Maps a [TrailModel] to a database [TrailsTable] row.
  @override
  Map<String, drift.Expression<Object>> toColumns(bool nullToAbsent) =>
      TrailsTableCompanion(id: drift.Value(id), data: drift.Value(encode()))
          .toColumns(nullToAbsent);

  /// Decodes a [TrailModel] from the binary encoding used to send over network.
  ///
  /// For more information on this encoding, see
  /// [trails-service.ts](https://github.com/trilliumlab/forest-park-reports-server/blob/main/src/services/trails-service.ts)
  /// in the server repository.
  TrailModel.decode(Uint8List buffer) {
    final data =
        buffer.buffer.asByteData(buffer.offsetInBytes, buffer.lengthInBytes);
    // keep track of read position
    var cursor = 0;

    // decode system name
    final systemLength = data.getUint16(cursor, kNetworkEndian);
    cursor += 2;
    system =
        ascii.decode(buffer.getRange(cursor, cursor += systemLength).toList());

    // decode id
    id = data.getUint64(cursor, kNetworkEndian);
    cursor += 8;

    // decode tags
    final tagSize = data.getUint16(cursor, kNetworkEndian);
    cursor += 2;
    for (int i = 0; i < tagSize; i++) {
      final keyLength = data.getUint16(cursor, kNetworkEndian);
      cursor += 2;
      final key =
          ascii.decode(buffer.getRange(cursor, cursor += keyLength).toList());
      final valueLength = data.getUint16(cursor, kNetworkEndian);
      cursor += 2;
      final value =
          ascii.decode(buffer.getRange(cursor, cursor += valueLength).toList());
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
        minlat: minlat, minlon: minlon, maxlat: maxlat, maxlon: maxlon);

    // decode nodes
    final nodeSize = data.getUint16(cursor, kNetworkEndian);
    cursor += 2;
    for (int i = 0; i < nodeSize; i++) {
      nodes.add(data.getUint64(cursor, kNetworkEndian));
      cursor += 8;
    }

    // decode geometry
    final geometrySize = data.getUint16(cursor, kNetworkEndian);
    cursor += 2;
    for (int i = 0; i < geometrySize; i++) {
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
        elevation = geometry.last.elevation +
            (data.getInt8(cursor++).toDouble() / kElevationDeltaMultiplier);
      }
      // calculate max and min elevation + delta
      final delta = elevation - (geometry.lastOrNull?.elevation ?? elevation);
      if (delta >= 0) {
        totalIncline += delta;
        if (elevation > maxElevation) {
          maxElevation = elevation;
        }
      }
      if (delta <= 0) {
        totalDecline -= delta;
        if (elevation < minElevation) {
          minElevation = elevation;
        }
      }

      final coord = Coordinate(latitude, longitude, elevation);
      // calculate distance and add to array
      if (geometry.isNotEmpty) {
        distances.add(distances.last +
            haversine.as(LengthUnit.Meter, geometry.last, coord));
      }
      // add latlong to path
      geometry.add(coord);
    }
  }

  /// Encodes the [TrailModel] to the binary encoding used to send over network.
  ///
  /// For more information on this encoding, see
  /// [trails-service.ts](https://github.com/trilliumlab/forest-park-reports-server/blob/main/src/services/trails-service.ts)
  /// in the server repository.
  Uint8List encode() {
    final builder = BytesBuilder();

    // encode system name
    builder.addUint16(system.length);
    builder.add(ascii.encode(system));

    // encode ID
    builder.addUint64(id);

    // encode tags
    builder.addUint16(tags.length);
    for (final tag in tags.entries) {
      // encode key
      builder.addUint16(tag.key.length);
      builder.add(ascii.encode(tag.key));
      // encode value
      builder.addUint16(tag.value.length);
      builder.add(ascii.encode(tag.value));
    }

    // encode bounds
    builder.addFloat32(bounds.minlat);
    builder.addFloat32(bounds.minlon);
    builder.addFloat32(bounds.maxlat);
    builder.addFloat32(bounds.maxlon);

    // encode nodes
    builder.addUint16(nodes.length);
    for (final node in nodes) {
      builder.addUint64(node);
    }

    // encode geometry data
    builder.addUint16(geometry.length);

    for (int i = 0; i < geometry.length; i++) {
      builder.addFloat32(geometry[i].latitude);
      builder.addFloat32(geometry[i].longitude);
      if (i == 0) {
        builder.addFloat32(geometry[i].elevation);
      } else {
        builder.addByte((((geometry[i].elevation - geometry[0].elevation) -
                    (geometry[i - 1].elevation - geometry[0].elevation)) *
                kElevationDeltaMultiplier)
            .round());
      }
    }

    return builder.takeBytes();
  }
}

@freezed
class ColorStop with _$ColorStop {
  const ColorStop._();
  const factory ColorStop(int index, Color color) = _ColorStop;
}
