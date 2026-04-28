import 'package:attendancebyface/core/app_config.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Bản đồ MapLibre hình tròn hiển thị vị trí chấm công hiện tại + label vị trí
class AttendanceLocationMap extends StatelessWidget {
  final double? lat;
  final double? lng;
  final String? locationLabel;

  const AttendanceLocationMap({
    super.key,
    required this.lat,
    required this.lng,
    required this.locationLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (lat == null || lng == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final shortestSide = constraints.biggest.shortestSide;
        // Giảm chiều cao bản đồ để chừa không gian cho text bên dưới, tránh overflow
        final height = shortestSide * 0.8;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: height,
                    child: MapLibreMap(
                      styleString: AppConfig.mapLibreStyleUrl,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(lat!, lng!),
                        zoom: 15.0,
                      ),
                      myLocationEnabled: true,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (locationLabel != null)
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: 'Overpass',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  children: [
                    const TextSpan(text: 'Bạn đang ở '),
                    TextSpan(
                      text: locationLabel!,
                      style: TextStyle(
                        fontFamily: 'Overpass',
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
          ],
        );
      },
    );
  }
}
