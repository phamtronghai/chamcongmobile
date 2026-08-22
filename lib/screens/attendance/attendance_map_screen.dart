import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/screens/attendance/widgets/attendance_location_map.dart';
import 'package:flutter/material.dart';

class AttendanceMapScreen extends StatefulWidget {
  final double lat;
  final double lng;

  const AttendanceMapScreen({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  State<AttendanceMapScreen> createState() => _AttendanceMapScreenState();
}

class _AttendanceMapScreenState extends State<AttendanceMapScreen> {
  VoidCallback? _flyToLocation;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Bản đồ'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AttendanceLocationMap(
            lat: widget.lat,
            lng: widget.lng,
            onMapReady: (flyToLocation) {
              setState(() => _flyToLocation = flyToLocation);
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + bottomInset,
            child: Center(
              child: CustomButton(
                text: 'Vị trí hiện tại',
                icon: Icons.my_location,
                variant: CustomButtonVariant.normalButton,
                onPressed: _flyToLocation,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
