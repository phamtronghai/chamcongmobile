import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/screens/attendance/widgets/attendance_result_dialog.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/core/services/report_service.dart';
import 'package:attendancebyface/screens/attendance/pdf_viewer_screen.dart';
import 'package:attendancebyface/core/widgets/base_screen.dart';
import 'package:attendancebyface/screens/attendance/widgets/daily_info_section.dart';
import 'package:attendancebyface/screens/attendance/widgets/worklog_bottom_sheet.dart';
import 'package:attendancebyface/screens/attendance/widgets/attendance_location_map.dart';
import 'package:attendancebyface/screens/attendance/widgets/manual_attendance_dialog.dart';
import 'package:attendancebyface/screens/attendance/widgets/attendance_action_buttons.dart';
import 'package:attendancebyface/widgets/nav_bar_layout.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:attendancebyface/core/cubits/attendance_cubit.dart';
import 'package:attendancebyface/core/cubits/attendance_state.dart';
import 'package:attendancebyface/core/repositories/worklog_repository.dart';
import 'package:attendancebyface/core/repositories/location_repository.dart';

class AttendanceScreen extends BaseScreen {
  const AttendanceScreen({super.key});

  @override
  Widget buildContent(UserModel user) {
    return BlocProvider(
      create: (context) {
        final isFaceRegistered = context.read<UserCubit>().isFaceRegistered;
        return AttendanceCubit()..init(context, user, isFaceRegistered);
      },
      child: _AttendanceScreenContent(user: user),
    );
  }

  @override
  Widget buildLoading() {
    return const LoadingOverlay(
      isLoading: true,
      child: Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

class _AttendanceScreenContent extends StatefulWidget {
  final UserModel user;

  const _AttendanceScreenContent({required this.user});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<_AttendanceScreenContent> {
  final ReportService _reportService = ReportService();
  bool _canViewQuanSoReport = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);
    _loadQuanSoPermission();
  }

  Future<void> _loadQuanSoPermission() async {
    final canView = await _reportService.hasPermissionViewAttendanceReport(
      widget.user.id,
    );
    if (!mounted) return;
    setState(() => _canViewQuanSoReport = canView);
  }

  Future<void> _showAttendanceLocation(BuildContext context, dynamic attendance) async {
    String message;
    try {
      if (attendance.lat != null && attendance.long != null) {
        final locationRepository = LocationRepository();
        await locationRepository.init();
        final address = await locationRepository.getAddressFromLatLng(
          attendance.lat!,
          attendance.long!,
        );
        message = address ?? 'Không lấy được địa chỉ chấm công';
      } else {
        message = attendance.location.isNotEmpty
            ? attendance.location
            : 'Không có thông tin vị trí chấm công';
      }
    } catch (_) {
      message = 'Lỗi khi lấy thông tin vị trí chấm công';
    }

    if (context.mounted) {
      CustomSnackbar.show(
        context: context,
        message: message,
        type: CustomSnackbarType.info,
      );
    }
  }

  void _openWorklogBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) {
        return WorklogBottomSheet(
          user: widget.user,
          worklogRepository: WorklogRepository(),
          onSuccess: () async {
            await context.read<AttendanceCubit>().loadDailyWorklogs(widget.user);
          },
        );
      },
    );
  }

  void _showAttendanceResultDialog(BuildContext context, AttendanceState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AttendanceResultDialog(
          isSuccess: state.status == AttendanceStatus.success,
          errorMessage: state.errorMessage,
          onClose: () {
            context.read<AttendanceCubit>().clearResultStatus();
          },
          onSecondaryAction: () {
            if (state.status != AttendanceStatus.success) {
              context.read<AttendanceCubit>().clearResultStatus();
              context.read<AttendanceCubit>().takePicture(context, widget.user);
            }
          },
        );
      },
    );
  }

  Future<void> _showManualAttendanceDialog(BuildContext context) async {
    final cubit = context.read<AttendanceCubit>();
    if (cubit.state.isProcessing) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ManualAttendanceDialog(userId: widget.user.id),
    );

    if (result == null || result['times'] == null) return;

    final List<String> times = result['times'] as List<String>;
    if (times.isNotEmpty && context.mounted) {
      await cubit.submitManualAttendance(times, widget.user);
    }
  }

  Future<void> _viewQuanSoReport(BuildContext context) async {
    final cubit = context.read<AttendanceCubit>();
    final serverTime = cubit.state.serverTime ?? DateTime.now();
    final dateStr = serverTime.toIso8601String().split('T')[0];

    final filePath = await cubit.downloadQuanSoReport();
    if (filePath != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            filePath: filePath,
            title: 'Báo cáo quân số - $dateStr',
          ),
        ),
      );
    } else if (context.mounted) {
      CustomSnackbar.show(
        context: context,
        message: 'Không lấy được báo cáo',
        type: CustomSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceCubit, AttendanceState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          (current.status == AttendanceStatus.success || current.status == AttendanceStatus.failure),
      listener: (context, state) {
        _showAttendanceResultDialog(context, state);
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Chấm công',
            automaticallyImplyLeading: false,
            onNotificationTap: () {
              AppRouter.goToNotification(context, widget.user);
            },
          ),
          body: LoadingOverlay(
            isLoading: state.isProcessing || state.isLoadingReport,
            child: SafeArea(
              bottom: false,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: attendanceFabBottomFromScreenBottom(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DailyInfoSection(
                          user: widget.user,
                          isLoadingRecords: state.isLoadingRecords,
                          attendanceRecords: state.attendanceRecords,
                          selectedDate: state.selectedDate,
                          onRefresh: () async => context.read<AttendanceCubit>().loadAttendanceRecords(widget.user),
                          onDateSelected: (date) => context.read<AttendanceCubit>().changeSelectedDate(date, widget.user),
                          onShowLocation: (att) => _showAttendanceLocation(context, att),
                          isLoadingWorklogs: state.isLoadingWorklogs,
                          worklogs: state.dailyWorklogs,
                          onAddWorklog: () => _openWorklogBottomSheet(context),
                          showQuanSoReportChip: _canViewQuanSoReport,
                          isLoadingQuanSoReport: state.isLoadingReport,
                          onQuanSoReport: () => _viewQuanSoReport(context),
                        ),
                        Expanded(
                          child: AttendanceLocationMap(
                            lat: state.currentLat,
                            lng: state.currentLng,
                            locationLabel: state.currentLocation,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!state.isCheckingFace)
                    Positioned(
                      right: kNavBarHorizontalPadding,
                      bottom: attendanceFabBottomFromScreenBottom(context),
                      child: AttendanceActionButtons(
                        hasRegisteredFace: state.hasRegisteredFace,
                        isProcessing: state.isProcessing,
                        onTakeAttendance: () => context.read<AttendanceCubit>().takePicture(context, widget.user),
                        onNavigateToRegisterFace: () => AppRouter.goToRegisterFace(context, widget.user),
                        onManualAttendance: (state.hasRegisteredFace &&
                                widget.user.departmentSlug == 'to-ncpt-khoa-hoc-cong-nghe')
                            ? () => _showManualAttendanceDialog(context)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
