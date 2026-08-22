import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:attendancebyface/core/app_config.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Gọi khi map sẵn sàng; trả về hàm zoom về [lat]/[lng].
typedef AttendanceMapReadyCallback = void Function(VoidCallback flyToLocation);

/// Bản đồ MapLibre hiển thị vị trí chấm công hiện tại.
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
  static const String _markerImageId = 'attendance-current-location';
  static const double _defaultZoom = 15;

  MapLibreMapController? _controller;
  bool _markerAdded = false;

  LatLng get _target => LatLng(widget.lat, widget.lng);

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString: AppConfig.mapLibreStyleUrl,
      initialCameraPosition: CameraPosition(
        target: _target,
        zoom: _defaultZoom,
      ),
      onMapCreated: (controller) => _controller = controller,
      onStyleLoadedCallback: _onStyleLoaded,
    );
  }

  Future<void> _onStyleLoaded() async {
    final controller = _controller;
    if (controller == null || _markerAdded || !mounted) return;

    try {
      final primary = Theme.of(context).colorScheme.primary;
      final markerBytes = await _buildLocationMarkerImage(primary);
      await controller.addImage(_markerImageId, markerBytes);
      await controller.addSymbol(
        SymbolOptions(
          geometry: _target,
          iconImage: _markerImageId,
          iconSize: 1.2,
          iconAnchor: 'bottom',
        ),
      );
      _markerAdded = true;
      widget.onMapReady?.call(_flyToLocation);
    } catch (_) {
      // Marker lỗi không chặn map; nút vẫn zoom được.
      widget.onMapReady?.call(_flyToLocation);
    }
  }

  Future<void> _flyToLocation() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(_target, _defaultZoom),
    );
  }

  Future<Uint8List> _buildLocationMarkerImage(Color color) async {
    const size = 64.0;
    const icon = Icons.my_location;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      )
      ..layout();
    textPainter.paint(canvas, Offset.zero);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.ceil(), size.ceil());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
