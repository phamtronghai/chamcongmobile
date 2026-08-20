import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:attendancebyface/models/attendance_model.dart';
import 'package:attendancebyface/models/worklog_model.dart';

part 'attendance_state.freezed.dart';

enum AttendanceStatus { initial, loading, success, failure }

@freezed
abstract class AttendanceState with _$AttendanceState {
  const factory AttendanceState({
    @Default(AttendanceStatus.initial) AttendanceStatus status,
    String? errorMessage,
    String? successMessage,
    @Default(false) bool isProcessing,
    @Default(true) bool isCheckingFace,
    @Default(false) bool hasRegisteredFace,
    String? currentLocation,
    double? currentLat,
    double? currentLng,
    DateTime? serverTime,
    required DateTime selectedDate,
    @Default(<AttendanceModel>[]) List<AttendanceModel> attendanceRecords,
    @Default(true) bool isLoadingRecords,
    @Default(<WorklogModel>[]) List<WorklogModel> dailyWorklogs,
    @Default(false) bool isLoadingWorklogs,
    @Default(false) bool isLoadingReport,
  }) = _AttendanceState;
}
