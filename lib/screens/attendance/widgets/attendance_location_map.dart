import 'package:attendancebyface/core/app_config.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Gọi khi map sẵn sàng; trả về hàm đưa camera về vị trí hiện tại.
typedef AttendanceMapReadyCallback = void Function(VoidCallback flyToLocation);

/// Bản đồ MapLibre hiển thị vị trí hiện tại (GPS + compass).
class AttendanceLocationMap extends StatefulWidget {
  final double lat;
  final double lng;
  final AttendanceMapReadyCallback? onMapReady;

  const AttendanceLocationMap({
    super.key,
    required this.lat,
    required this.lng,
    this.onMapReady,
  });

  @override
  State<AttendanceLocationMap> createState() => _AttendanceLocationMapState();
}

class _AttendanceLocationMapState extends State<AttendanceLocationMap> {
  static const double _defaultZoom = 15;

  MapLibreMapController? _controller;

  LatLng get _target => LatLng(widget.lat, widget.lng);

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString: AppConfig.mapLibreStyleUrl,
      initialCameraPosition: CameraPosition(
        target: _target,
        zoom: _defaultZoom,
      ),
      trackCameraPosition: true,
      myLocationEnabled: true,
      myLocationTrackingMode: MyLocationTrackingMode.trackingCompass,
      myLocationRenderMode: MyLocationRenderMode.compass,
      onMapCreated: (controller) => _controller = controller,
      onStyleLoadedCallback: () {
        widget.onMapReady?.call(_flyToLocation);
      },
    );
  }

  Future<void> _flyToLocation() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.updateMyLocationTrackingMode(
      MyLocationTrackingMode.trackingCompass,
    );
  }
}
