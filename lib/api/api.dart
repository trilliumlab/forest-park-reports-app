import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forest_park_reports/models/hazard.dart';
import 'package:forest_park_reports/providers/trail_provider.dart';
import 'package:gpx/gpx.dart';

class Api {
  static String baseUrl = "http://192.168.1.169:3000/api/v1/";
  static BaseOptions options = BaseOptions(
      baseUrl: baseUrl
  );
  static GpxReader gpxReader = GpxReader();
  Dio dio = Dio(options);
  Future<Map<String, Trail>> getTrails() async {
    final res = await dio.get("/trail/list");
    return {
      for (final val in res.data.values)
        val["uuid"]: Trail(val["name"], val["uuid"])
    };
  }
  Future<Track> getTrack(String uuid) async {
    final res = await dio.get("/trail/$uuid");
    return Track(gpxReader.fromString(res.data));
  }
  Future postNewHazard(NewHazardRequest request) async {
    final res = await dio.post("/hazard/new", data: request.toJson());
  }
}

final apiProvider = Provider<Api>((ref) => Api());
