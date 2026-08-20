import 'package:attendancebyface/core/cubits/attendance_cubit.dart';
import 'package:attendancebyface/core/cubits/attendance_state.dart';
import 'package:attendancebyface/core/repositories/attendance_repository.dart';
import 'package:attendancebyface/core/repositories/date_time_repository.dart';
import 'package:attendancebyface/core/repositories/location_repository.dart';
import 'package:attendancebyface/core/repositories/worklog_repository.dart';
import 'package:attendancebyface/core/services/attendance_service.dart';
import 'package:attendancebyface/core/services/face_service.dart';
import 'package:attendancebyface/core/services/report_service.dart';
import 'package:attendancebyface/models/attendance_model.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/models/worklog_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAttendanceRepository extends AttendanceRepository {
  _FakeAttendanceRepository({this.records = const [], this.throwOnLoad = false});

  final List<AttendanceModel> records;
  final bool throwOnLoad;

  @override
  Future<void> init() async {}

  @override
  Future<List<AttendanceModel>> getAttendancesByDate(String date) async {
    if (throwOnLoad) throw Exception('network');
    return List<AttendanceModel>.from(records);
  }
}

class _FakeWorklogRepository extends WorklogRepository {
  @override
  Future<void> init() async {}

  @override
  Future<List<WorklogModel>> getWorklogsByDate({
    required String userId,
    required String dateStr,
  }) async {
    return const [];
  }
}

UserModel _user() => UserModel(
  id: 'u1',
  name: 'Test',
  email: 't@example.com',
  image: '',
  role: 'user',
  username: 'test',
  position: 'nv',
  department: 'IT',
  departmentSlug: 'it',
  canApprove: 'nv',
);

AttendanceCubit _cubit({
  AttendanceRepository? attendanceRepository,
}) {
  return AttendanceCubit(
    attendanceService: AttendanceService(
      faceService: FaceService(),
      locationRepository: LocationRepository(),
    ),
    dateTimeRepository: DateTimeRepository(),
    reportService: ReportService(),
    locationRepository: LocationRepository(),
    attendanceRepository: attendanceRepository ?? _FakeAttendanceRepository(),
    worklogRepository: _FakeWorklogRepository(),
  );
}

void main() {
  final now = DateTime(2026, 8, 19, 8, 0);

  test('clearResultStatus đưa status về initial', () {
    final cubit = _cubit();
    cubit.emit(
      cubit.state.copyWith(
        status: AttendanceStatus.success,
        errorMessage: 'x',
        successMessage: 'ok',
      ),
    );

    cubit.clearResultStatus();

    expect(cubit.state.status, AttendanceStatus.initial);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.successMessage, isNull);
    cubit.close();
  });

  test('loadAttendanceRecords sắp xếp bản ghi mới nhất trước', () async {
    final older = AttendanceModel(
      id: '1',
      userId: 'u1',
      checkInTime: now.subtract(const Duration(hours: 1)),
      location: 'A',
    );
    final newer = AttendanceModel(
      id: '2',
      userId: 'u1',
      checkInTime: now,
      location: 'B',
    );
    final cubit = _cubit(
      attendanceRepository: _FakeAttendanceRepository(records: [older, newer]),
    );

    await cubit.loadAttendanceRecords(_user());

    expect(cubit.state.isLoadingRecords, isFalse);
    expect(cubit.state.attendanceRecords.map((e) => e.id), ['2', '1']);
    cubit.close();
  });

  test('loadAttendanceRecords khi lỗi để list rỗng', () async {
    final cubit = _cubit(
      attendanceRepository: _FakeAttendanceRepository(throwOnLoad: true),
    );

    await cubit.loadAttendanceRecords(_user());

    expect(cubit.state.attendanceRecords, isEmpty);
    expect(cubit.state.isLoadingRecords, isFalse);
    cubit.close();
  });
}
