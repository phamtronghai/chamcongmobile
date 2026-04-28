import 'package:attendancebyface/models/attendance_model.dart';
import 'package:attendancebyface/models/worklog_model.dart';

enum AttendanceStatus { initial, loading, success, failure }

class AttendanceState {
  final AttendanceStatus status;
  final String? errorMessage;
  final String? successMessage; // For manual attendance specific message if needed
  
  final bool isProcessing;
  final bool isCheckingFace;
  final bool hasRegisteredFace;

  final String? currentLocation;
  final double? currentLat;
  final double? currentLng;

  final DateTime? serverTime;
  final DateTime selectedDate;

  final List<AttendanceModel> attendanceRecords;
  final bool isLoadingRecords;

  final List<WorklogModel> dailyWorklogs;
  final bool isLoadingWorklogs;

  final bool isLoadingReport;

  AttendanceState({
    this.status = AttendanceStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.isProcessing = false,
    this.isCheckingFace = true,
    this.hasRegisteredFace = false,
    this.currentLocation,
    this.currentLat,
    this.currentLng,
    this.serverTime,
    DateTime? selectedDate,
    this.attendanceRecords = const [],
    this.isLoadingRecords = true,
    this.dailyWorklogs = const [],
    this.isLoadingWorklogs = false,
    this.isLoadingReport = false,
  }) : selectedDate = selectedDate ?? DateTime.now();

  AttendanceState copyWith({
    AttendanceStatus? status,
    String? errorMessage,
    String? successMessage,
    bool? isProcessing,
    bool? isCheckingFace,
    bool? hasRegisteredFace,
    String? currentLocation,
    double? currentLat,
    double? currentLng,
    DateTime? serverTime,
    DateTime? selectedDate,
    List<AttendanceModel>? attendanceRecords,
    bool? isLoadingRecords,
    List<WorklogModel>? dailyWorklogs,
    bool? isLoadingWorklogs,
    bool? isLoadingReport,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isProcessing: isProcessing ?? this.isProcessing,
      isCheckingFace: isCheckingFace ?? this.isCheckingFace,
      hasRegisteredFace: hasRegisteredFace ?? this.hasRegisteredFace,
      currentLocation: currentLocation ?? this.currentLocation,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      serverTime: serverTime ?? this.serverTime,
      selectedDate: selectedDate ?? this.selectedDate,
      attendanceRecords: attendanceRecords ?? this.attendanceRecords,
      isLoadingRecords: isLoadingRecords ?? this.isLoadingRecords,
      dailyWorklogs: dailyWorklogs ?? this.dailyWorklogs,
      isLoadingWorklogs: isLoadingWorklogs ?? this.isLoadingWorklogs,
      isLoadingReport: isLoadingReport ?? this.isLoadingReport,
    );
  }
}
