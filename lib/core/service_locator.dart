import 'package:get_it/get_it.dart';
import 'package:attendancebyface/core/database/app_database.dart';
import 'package:attendancebyface/core/services/auth_service.dart';
import 'package:attendancebyface/core/services/attendance_service.dart';
import 'package:attendancebyface/core/services/face_service.dart';
import 'package:attendancebyface/core/services/report_service.dart';
import 'package:attendancebyface/core/services/truc_ban_service.dart';
import 'package:attendancebyface/core/services/device_security_service.dart';
import 'package:attendancebyface/core/services/notification_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Đăng ký các Service dưới dạng LazySingleton
  // Có nghĩa là chỉ khi nào được gọi lần đầu tiên thì class mới được tạo
  // Và sẽ được tái sử dụng xuyên suốt vòng đời của app

  locator.registerLazySingleton<AppDatabase>(() => AppDatabase());

  locator.registerLazySingleton<AuthService>(() => AuthService(baseUrl: 'https://auth.samcom.com.vn'));
  locator.registerLazySingleton<AttendanceService>(() => AttendanceService());
  locator.registerLazySingleton<FaceService>(() => FaceService());
  locator.registerLazySingleton<ReportService>(() => ReportService());
  locator.registerLazySingleton<TrucBanService>(() => TrucBanService());
  locator.registerLazySingleton<DeviceSecurityService>(() => DeviceSecurityService());
  
  // NotificationService lấy instance có sẵn
  locator.registerLazySingleton<NotificationService>(() => NotificationService.instance);
}
