import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/screens/attendance/widgets/attendance_location_map.dart';
import 'package:flutter/material.dart';

class AttendanceMapScreen extends StatelessWidget {
  final double lat;
  final double lng;
  const AttendanceMapScreen({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Bản đồ'),
      body: AttendanceLocationMap(
        lat: lat,
        lng: lng,
        myLocationEnabled: false,
      ),
    );
  }
}
