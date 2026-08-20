import 'package:get_it/get_it.dart';
import 'package:attendancebyface/core/database/app_database.dart';
import 'package:attendancebyface/core/services/auth_service.dart';
import 'package:attendancebyface/core/services/attendance_service.dart';
import 'package:attendancebyface/core/services/face_service.dart';
import 'package:attendancebyface/core/services/citizen_service.dart';
import 'package:attendancebyface/core/services/report_service.dart';
import 'package:attendancebyface/core/services/truc_ban_service.dart';
import 'package:attendancebyface/core/services/notification_service.dart';
import 'package:attendancebyface/core/repositories/date_time_repository.dart';
import 'package:attendancebyface/core/repositories/location_repository.dart';
import 'package:attendancebyface/core/repositories/attendance_repository.dart';
import 'package:attendancebyface/core/repositories/worklog_repository.dart';
import 'package:attendancebyface/core/repositories/leave_repository.dart';
import 'package:attendancebyface/core/repositories/device_repository.dart';
import 'package:attendancebyface/core/services/approver_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<AppDatabase>(() => AppDatabase());

  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<AttendanceService>(() => AttendanceService());
  locator.registerLazySingleton<FaceService>(() => FaceService());
  locator.registerLazySingleton<CitizenService>(() => CitizenService());
  locator.registerLazySingleton<ApproverService>(() => ApproverService());
  locator.registerLazySingleton<ReportService>(() => ReportService());
  locator.registerLazySingleton<TrucBanService>(() => TrucBanService());
  locator.registerLazySingleton<NotificationService>(
    () => NotificationService.instance,
  );

  locator.registerLazySingleton<DateTimeRepository>(() => DateTimeRepository());
  locator.registerLazySingleton<LocationRepository>(() => LocationRepository());
  locator.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepository(),
  );
  locator.registerLazySingleton<WorklogRepository>(() => WorklogRepository());
  locator.registerLazySingleton<LeaveRepository>(() => LeaveRepository());
  locator.registerLazySingleton<DeviceRepository>(() => DeviceRepository());
}
