import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/core/cubits/attendance_state.dart';
import 'package:attendancebyface/core/services/attendance_service.dart';
import 'package:attendancebyface/core/services/device_security_service.dart';
import 'package:attendancebyface/core/repositories/date_time_repository.dart';
import 'package:attendancebyface/core/services/report_service.dart';
import 'package:attendancebyface/core/repositories/location_repository.dart';
import 'package:attendancebyface/core/repositories/attendance_repository.dart';
import 'package:attendancebyface/core/repositories/worklog_repository.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/models/worklog_model.dart';
import 'package:attendancebyface/core/service_locator.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceService _attendanceService = locator<AttendanceService>();
  final DeviceSecurityService _deviceSecurityService = locator<DeviceSecurityService>();
  final DateTimeRepository _dateTimeRepository = DateTimeRepository();
  final ReportService _reportService = locator<ReportService>();
  final LocationRepository _locationRepository = LocationRepository();
  final AttendanceRepository _attendanceRepository = AttendanceRepository();
  final WorklogRepository _worklogRepository = WorklogRepository();

  AttendanceCubit() : super(AttendanceState());

  Future<void> init(BuildContext context, UserModel user, bool isFaceRegistered) async {
    emit(state.copyWith(
      hasRegisteredFace: isFaceRegistered,
      isCheckingFace: false,
    ));

    await _initServerTime();
    if (!context.mounted) return;
    await getCurrentLocation(context);
    await loadAttendanceRecords(user);
  }

  Future<void> _initServerTime() async {
    try {
      await _dateTimeRepository.init();
      final server = await _dateTimeRepository.getServerTime();
      if (server != null) {
        emit(state.copyWith(serverTime: server));
      }
    } catch (_) {}
  }

  Future<void> refreshServerTime() async {
    final server = await _dateTimeRepository.getServerTime();
    emit(state.copyWith(serverTime: server ?? DateTime.now()));
  }

  Future<void> getCurrentLocation(BuildContext context) async {
    try {
      final position = await _attendanceService.getCurrentLocation(context);
      if (position != null) {
        final address = await _locationRepository.getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );
        emit(state.copyWith(
          currentLocation: address,
          currentLat: position.latitude,
          currentLng: position.longitude,
        ));
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy vị trí ban đầu: $e');
    }
  }

  Future<void> loadAttendanceRecords(UserModel user) async {
    emit(state.copyWith(isLoadingRecords: true));
    try {
      final dateFormatted = DateFormat('yyyy-MM-dd').format(state.selectedDate);
      await _attendanceRepository.init();
      final records = await _attendanceRepository.getAttendancesByDate(dateFormatted);

      records.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

      emit(state.copyWith(
        attendanceRecords: records,
        isLoadingRecords: false,
      ));
      
      await loadDailyWorklogs(user);
    } catch (e) {
      emit(state.copyWith(
        attendanceRecords: [],
        isLoadingRecords: false,
      ));
    }
  }

  Future<void> loadDailyWorklogs(UserModel user) async {
    emit(state.copyWith(isLoadingWorklogs: true));
    try {
      await _worklogRepository.init();
      final dateStr = DateFormat('yyyy-MM-dd').format(state.selectedDate);
      final worklogs = await _worklogRepository.getWorklogsByDate(
        userId: user.id,
        dateStr: dateStr,
      );

      emit(state.copyWith(
        dailyWorklogs: worklogs,
        isLoadingWorklogs: false,
      ));
    } catch (_) {
      emit(state.copyWith(
        dailyWorklogs: <WorklogModel>[],
        isLoadingWorklogs: false,
      ));
    }
  }

  void changeSelectedDate(DateTime date, UserModel user) {
    emit(state.copyWith(selectedDate: date));
    loadAttendanceRecords(user);
  }

  Future<void> takePicture(BuildContext context, UserModel user) async {
    if (state.isProcessing) return;

    final isDeviceSafe = await _deviceSecurityService.validateDeviceSecurity(context);
    if (!isDeviceSafe) return;

    emit(state.copyWith(
      isProcessing: true,
      status: AttendanceStatus.initial,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      if (!context.mounted) return;
      final result = await _attendanceService.checkFaceLiveness(context, user.id);

      final isSuccess = result['isSuccess'] ?? false;
      final errorMessage = result['message'] as String?;

      emit(state.copyWith(
        isProcessing: false,
        status: isSuccess ? AttendanceStatus.success : AttendanceStatus.failure,
        errorMessage: errorMessage,
      ));

      if (isSuccess) {
        await loadAttendanceRecords(user);
      }
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        status: AttendanceStatus.failure,
        errorMessage: null, // ErrorInterceptor sẽ lo hiển thị Snackbar từ Dio
      ));
    }
  }

  Future<void> submitManualAttendance(List<String> times, UserModel user) async {
    if (state.isProcessing || times.isEmpty) return;

    emit(state.copyWith(
      isProcessing: true,
      status: AttendanceStatus.initial,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      final List<Future<Map<String, dynamic>>> futures = times.map((time) {
        return _attendanceRepository.addAttendanceManual(
          recordTime: time,
          userId: user.id,
        );
      }).toList();

      final results = await Future.wait(futures);
      final successCount = results.where((r) => r['success'] == true).length;
      final failCount = results.length - successCount;

      final isSuccess = failCount == 0;
      final errorMessage = failCount > 0
          ? 'Chấm công thành công $successCount/${results.length} lần. Có $failCount lần thất bại.'
          : null;

      emit(state.copyWith(
        isProcessing: false,
        status: isSuccess ? AttendanceStatus.success : AttendanceStatus.failure,
        errorMessage: errorMessage,
      ));

      if (successCount > 0) {
        await loadAttendanceRecords(user);
      }
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        status: AttendanceStatus.failure,
        errorMessage: 'Lỗi khi chấm công: ${e.toString()}',
      ));
    }
  }

  Future<String?> downloadQuanSoReport() async {
    if (state.isLoadingReport) return null;

    emit(state.copyWith(isLoadingReport: true));

    try {
      final dateStr = (state.serverTime ?? DateTime.now()).toIso8601String().split('T')[0];
      final filePath = await _reportService.getQuanSoReport(dateStr);
      
      emit(state.copyWith(isLoadingReport: false));
      return filePath;
    } catch (e) {
      emit(state.copyWith(isLoadingReport: false));
      return null;
    }
  }

  void clearResultStatus() {
    emit(state.copyWith(
      status: AttendanceStatus.initial,
      errorMessage: null,
      successMessage: null,
    ));
  }
}
