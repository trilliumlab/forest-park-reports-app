import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forest_park_reports/provider/location_provider.dart';
import 'package:forest_park_reports/util/extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';


Future<bool> testLocationTooFar(
  BuildContext context,
  WidgetRef ref, {
  required LatLng actionLocation,
  required double tolerance,
  String title = "Location is too far",
  String? content,
  String acceptText = "Ok",
  bool overrideEnabled = false,
  String overrideText = "Override",
}) async {
  final location = await _getCurrentLocation(context, ref, acceptText);
  if (location == null) {
    return false;
  }

  if (context.mounted &&
      DistanceVincenty().as(
            LengthUnit.Meter,
            location.latLng()!,
            actionLocation,
          ) <=
          tolerance + location.accuracy) {
    return true;
  }

  return _badLocationAlert(
    context,
    title,
    content,
    acceptText,
    overrideEnabled,
    overrideText,
  );
}

Future<bool> testLocationTooFarDynamic(
  BuildContext context,
  WidgetRef ref, {
  required Future<LatLng> Function(BuildContext, WidgetRef, LatLng)
      actionLocationGetter,
  required double tolerance,
  String title = "Location is too far",
  String? content,
  String acceptText = "Ok",
  bool overrideEnabled = false,
  String overrideText = "Override",
}) async {
  final location = await _getCurrentLocation(context, ref, acceptText);
  if (location == null) {
    return false;
  }

  final actionLocation =
      await actionLocationGetter(context, ref, location.latLng()!);

  if (context.mounted &&
      DistanceVincenty().as(
            LengthUnit.Meter,
            location.latLng()!,
            actionLocation,
          ) <=
          tolerance + location.accuracy) {
    return true;
  }

  return _badLocationAlert(
    context,
    title,
    content,
    acceptText,
    overrideEnabled,
    overrideText,
  );
}

Future<Position?> _getCurrentLocation(
  BuildContext context,
  WidgetRef ref,
  String acceptText,
) async {
  try {
    final location = ref.read(locationProvider);
    if (location.hasValue) {
      return location.requireValue;
    }

    return await Geolocator.getCurrentPosition()
        .timeout(const Duration(seconds: 10));
  } on TimeoutException {
    if (context.mounted) {
      await _badLocationAlert(
        context,
        "Invalid location",
        "No location was found",
        acceptText,
        false,
        "Override",
      );
    }
    return null;
  }
}

Future<bool> _badLocationAlert(
  BuildContext context,
  String title,
  String? content,
  String acceptText,
  bool overrideEnabled,
  String overrideText,
) {
  final continueCompleter = Completer<bool>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: content == null ? null : Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            continueCompleter.complete(false);
          },
          child: Text(acceptText),
        ),
        if (overrideEnabled)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              continueCompleter.complete(true);
            },
            child: Text(overrideText),
          ),
      ],
    ),
  );

  return continueCompleter.future;
}