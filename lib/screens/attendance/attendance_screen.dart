import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/screens/attendance/widgets/attendance_result_dialog.dart';
import 'package:attendancebyface/core/widgets/custom_snackbar.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/widgets/samcom_tab_bar.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/core/service_locator.dart';
import 'package:attendancebyface/core/services/report_service.dart';
import 'package:attendancebyface/core/widgets/base_screen.dart';
import 'package:attendancebyface/screens/attendance/widgets/daily_info_section.dart';
import 'package:attendancebyface/screens/attendance/widgets/attendance_action_buttons.dart';
import 'package:attendancebyface/screens/home/custom_navbar.dart';
import 'package:attendancebyface/core/cubits/attendance_cubit.dart';
import 'package:attendancebyface/core/cubits/attendance_state.dart';

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

class _AttendanceScreenState extends State<_AttendanceScreenContent>
    with SingleTickerProviderStateMixin {
  final ReportService _reportService = locator<ReportService>();
  bool _canViewQuanSoReport = false;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuanSoPermission();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuanSoPermission() async {
    final canView = await _reportService.hasPermissionViewAttendanceReport(
      widget.user.id,
    );
    if (!mounted) return;
    setState(() => _canViewQuanSoReport = canView);
  }

  void _openWorklogForm(BuildContext context) {
    AppRouter.goToWorklogCreate(
      context,
      userId: widget.user.id,
      selectedDate: context.read<AttendanceCubit>().state.selectedDate,
      onSuccess: () =>
          context.read<AttendanceCubit>().loadDailyWorklogs(widget.user),
    );
  }

  void _showAttendanceResultDialog(
    BuildContext context,
    AttendanceState state,
  ) {
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

  void _openAttendanceMap(BuildContext context, AttendanceState state) {
    final lat = state.currentLat;
    final lng = state.currentLng;
    if (lat == null || lng == null) return;
    AppRouter.goToAttendanceMap(context, lat: lat, lng: lng);
  }

  void _openManualAttendance(BuildContext context) {
    final cubit = context.read<AttendanceCubit>();
    if (cubit.state.isProcessing) return;
    AppRouter.goToManualAttendance(context, user: widget.user, cubit: cubit);
  }

  Future<void> _viewQuanSoReport(BuildContext context) async {
    final cubit = context.read<AttendanceCubit>();
    final serverTime = cubit.state.serverTime ?? DateTime.now();
    final dateStr = serverTime.toIso8601String().split('T')[0];

    final filePath = await cubit.downloadQuanSoReport();
    if (filePath != null && context.mounted) {
      AppRouter.goToPdfViewer(
        context,
        filePath: filePath,
        title: 'Báo cáo quân số - $dateStr',
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
          (current.status == AttendanceStatus.success ||
              current.status == AttendanceStatus.failure),
      listener: (context, state) {
        _showAttendanceResultDialog(context, state);
      },
      buildWhen: (previous, current) =>
          previous.isProcessing != current.isProcessing ||
          previous.isLoadingReport != current.isLoadingReport ||
          previous.isCheckingFace != current.isCheckingFace ||
          previous.hasRegisteredFace != current.hasRegisteredFace ||
          previous.selectedDate != current.selectedDate ||
          previous.attendanceRecords != current.attendanceRecords ||
          previous.isLoadingRecords != current.isLoadingRecords ||
          previous.dailyWorklogs != current.dailyWorklogs ||
          previous.isLoadingWorklogs != current.isLoadingWorklogs,
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            title: 'Chấm công',
            showAvatar: true,
            onNotificationTap: () {
              AppRouter.goToNotification(context, widget.user);
            },
          ),
          body: LoadingOverlay(
            isLoading: state.isProcessing || state.isLoadingReport,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<AttendanceCubit, AttendanceState>(
                    buildWhen: (previous, current) =>
                        previous.currentLocation != current.currentLocation ||
                        previous.currentLat != current.currentLat ||
                        previous.currentLng != current.currentLng ||
                        previous.selectedDate != current.selectedDate,
                    builder: (context, gpsState) {
                      return DailyInfoSection(
                        user: widget.user,
                        selectedDate: gpsState.selectedDate,
                        onDateSelected: (date) => context
                            .read<AttendanceCubit>()
                            .changeSelectedDate(date, widget.user),
                        locationLabel: gpsState.currentLocation,
                        onMapTap:
                            (gpsState.currentLat != null &&
                                gpsState.currentLng != null)
                            ? () => _openAttendanceMap(context, gpsState)
                            : null,
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Center(
                      child: SamcomTabBar(
                        controller: _tabController,
                        width: 312,
                        tabWidth: 148,
                        tabs: const [
                          Tab(text: 'Chấm công'),
                          Tab(text: 'Công việc'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        TabBarView(
                          controller: _tabController,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.paddingOf(context).bottom +
                                    kFabFilledPillHeight +
                                    (_canViewQuanSoReport
                                        ? kFabFilledPillHeight + 12
                                        : 0),
                              ),
                              child: AttendanceHistorySection(
                                isLoadingRecords: state.isLoadingRecords,
                                attendanceRecords: state.attendanceRecords,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.paddingOf(context).bottom +
                                    kFabFilledPillHeight,
                              ),
                              child: DailyWorklogsSection(
                                isLoadingWorklogs: state.isLoadingWorklogs,
                                worklogs: state.dailyWorklogs,
                                userId: widget.user.id,
                                selectedDate: state.selectedDate,
                                onWorklogAdded: () => context
                                    .read<AttendanceCubit>()
                                    .loadDailyWorklogs(widget.user),
                              ),
                            ),
                          ],
                        ),
                        ListenableBuilder(
                          listenable: _tabController,
                          builder: (context, _) {
                            final tabIndex = _tabController.index;
                            if (tabIndex == 0) {
                              if (state.isCheckingFace) {
                                return const SizedBox.shrink();
                              }
                              return Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: kNavBarHorizontalPadding,
                                    bottom: MediaQuery.paddingOf(
                                      context,
                                    ).bottom,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (_canViewQuanSoReport) ...[
                                        IntrinsicWidth(
                                          child: CustomButton(
                                            text: 'QUÂN SỐ',
                                            tooltip: 'Báo cáo quân số',
                                            icon: Icons.groups_outlined,
                                            variant:
                                                CustomButtonVariant.ctaButton,
                                            isLoading: state.isLoadingReport,
                                            onPressed: state.isLoadingReport
                                                ? null
                                                : () => _viewQuanSoReport(
                                                    context,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      AttendanceActionButtons(
                                        hasRegisteredFace:
                                            state.hasRegisteredFace,
                                        isProcessing: state.isProcessing,
                                        onTakeAttendance: () => context
                                            .read<AttendanceCubit>()
                                            .takePicture(context, widget.user),
                                        onNavigateToRegisterFace: () =>
                                            AppRouter.goToRegisterFace(
                                              context,
                                              widget.user,
                                            ),
                                        onManualAttendance:
                                            (state.hasRegisteredFace &&
                                                widget.user.departmentSlug ==
                                                    'to-ncpt-khoa-hoc-cong-nghe')
                                            ? () =>
                                                  _openManualAttendance(context)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (tabIndex == 1 &&
                                widget.user.departmentSlug ==
                                    'to-ncpt-khoa-hoc-cong-nghe') {
                              return Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: kNavBarHorizontalPadding,
                                    bottom: MediaQuery.paddingOf(
                                      context,
                                    ).bottom,
                                  ),
                                  child: IntrinsicWidth(
                                    child: CustomButton(
                                      text: 'NHẬP CÔNG VIỆC',
                                      tooltip: 'Nhập công việc',
                                      icon: Icons.add,
                                      variant: CustomButtonVariant.ctaButton,
                                      onPressed: () =>
                                          _openWorklogForm(context),
                                    ),
                                  ),
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ],
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
