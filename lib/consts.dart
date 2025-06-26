import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:forest_park_reports/model/camera_position.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

// const kApiUrl = "https://forestpark.cecs.pdx.edu/prod/v1";
// const kApiUrl = "https://forestpark.cecs.pdx.edu/staging/v1";
// const kApiUrl = "http://192.168.0.247:8000";
const kApiUrl = "http://localhost:8000/";

final kMaterialAppPrimaryColor = Colors.green.shade700;

// Allows a user to submit hazards and updates without appropriate proximity.
const bool kLocationOverrideEnabled = true;

// Tolerance in meters used when creating/updating a hazard
const double kAddLocationTolerance = 25;
const double kUpdateLocationTolerance = 50;

// Example: 11:53 AM July 12 2022
final DateFormat kDisplayDateFormat = DateFormat('hh:mm a MMMM dd y');

// Provider consts
const kHazardRefreshPeriod = Duration(seconds: 10);

// Filesystem consts
const kDbName = "forest_park_reports";
const kImageDirectory = "images";
const kQueueDirectory = "queue";

const double kFabPadding = 10;

// Map constants
const kHomeCameraPosition = CameraPosition(
  center: LatLng(45.57416784067063, -122.76892379502566),
  zoom: 11.5,
);
const kMarkerTopAlignment = Alignment(0, -0.65);

const kElevationMaxEntries = 200;

// Encoding consts
const kNetworkEndian = Endian.little;
const kElevationDeltaMultiplier = 8;

// Isolate consts
const kBackgroundRequestPortName = "backgroundRequestPort";

// Uuid generator
const kUuidGen = Uuid();
