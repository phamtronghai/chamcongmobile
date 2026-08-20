import 'package:attendancebyface/core/app_config.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Bản đồ MapLibre hiển thị vị trí chấm công hiện tại.
class AttendanceLocationMap extends StatelessWidget {
  final double lat;
  final double lng;

  const AttendanceLocationMap({
    super.key,
    required this.lat,
    required this.lng,
    this.myLocationEnabled = true,
  });

  final bool myLocationEnabled;

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString: AppConfig.mapLibreStyleUrl,
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 15.0,
      ),
      myLocationEnabled: myLocationEnabled,
    );
  }
}
