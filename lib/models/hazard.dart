import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

// Tuesday, July 12th, 2022 at 11:53am
// 11:53 AM July 12 2022
DateFormat _formatter = DateFormat('hh:mm a MMMM dd y');
class Hazard extends NewHazardRequest {
  String uuid;
  DateTime time;

  String timeString() => _formatter.format(time.toLocal());

  Hazard(this.uuid, this.time, super.hazard, super.location, [super.image]);

  Hazard.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        time = DateTime.parse(json['time']),
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'time': time.toIso8601String(),
      ...super.toJson()
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class NewHazardRequest {
  HazardType hazard;
  SnappedLatLng location;
  String? image;

  NewHazardRequest(this.hazard, this.location, [this.image]);

  NewHazardRequest.fromJson(Map<String, dynamic> json)
      : hazard = HazardType.values.byName(json['hazard']),
        location = SnappedLatLng.fromJson(json['location']),
        image = json.containsKey('image') ? json['image'] : null;

  Map<String, dynamic> toJson() {
    return {
      'hazard': hazard.name,
      'location': location.toJson(),
      'image': image,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class HazardUpdate extends UpdateHazardRequest {
  String uuid;
  DateTime time;

  String timeString() => _formatter.format(time.toLocal());

  HazardUpdate({
    required this.uuid,
    required this.time,
    required super.hazard,
    required super.active,
    super.image,
  });

  HazardUpdate.fromJson(Map<String, dynamic> json)
      : uuid = json['uuid'],
        time = DateTime.parse(json['time']),
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'time': time.toIso8601String(),
      ...super.toJson(),
    };
  }

}

class UpdateHazardRequest {
  String hazard;
  bool active;
  String? image;

  UpdateHazardRequest({
    required this.hazard,
    required this.active,
    this.image
  });

  UpdateHazardRequest.fromJson(Map<String, dynamic> json)
      : hazard = json['hazard'],
        active = json['active'],
        image = json.containsKey('image') ? json['image'] : null;

  Map<String, dynamic> toJson() {
    return {
      'hazard': hazard,
      'active': active,
      'image': image,
    };
  }
}

// A way of representing a LatLng pair that exists on a path. Stores
// the path uuid, along with the index of the point, and a LatLng pair
class SnappedLatLng extends LatLng {
  String trail;
  int index;

  SnappedLatLng(this.trail, this.index, LatLng loc) : super(loc.latitude, loc.longitude);

  SnappedLatLng.fromJson(Map<String, dynamic> json)
      : trail = json['trail'],
        index = json['index'],
        super(json['lat'], json['long']);

  @override
  Map<String, dynamic> toJson() {
    return {
      'trail': trail,
      'index': index,
      'lat': latitude,
      'long': longitude,
    };
  }
  @override
  String toString() {
    return "${super.toString()} trailUuid:$trail, index:$index";
  }
}

enum HazardType {
  tree,
  flood,
  other;

  String get displayName {
    switch (this) {
      case HazardType.tree:
        return "Fallen Tree";
      case HazardType.flood:
        return "Flooded Trail";
      case HazardType.other:
        return "Other Hazard";
    }
  }
  IconData get icon {
    switch (this) {
      case HazardType.tree:
        return CupertinoIcons.tree;
      case HazardType.flood:
        return Icons.flood_rounded;
      case HazardType.other:
        return CupertinoIcons.question_diamond_fill;
    }
  }
}