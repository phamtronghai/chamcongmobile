import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/models/approver.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/screens/login/login_screen.dart';
import 'package:attendancebyface/screens/register_face/register_face_screen.dart';
import 'package:attendancebyface/screens/leave/leave_create_screen.dart';
import 'package:attendancebyface/screens/notification/notification_screen.dart';
import 'package:attendancebyface/screens/qr_scanner/qr_scanner_screen.dart';
import 'package:attendancebyface/screens/home/custom_navbar.dart';
import 'package:attendancebyface/core/network/error_interceptor.dart';
import 'package:attendancebyface/core/widgets/error_widget.dart';
import 'package:attendancebyface/core/cubits/attendance_cubit.dart';
import 'package:attendancebyface/screens/attendance/attendance_map_screen.dart';
import 'package:attendancebyface/screens/attendance/manual_attendance_screen.dart';
import 'package:attendancebyface/screens/attendance/pdf_viewer_screen.dart';
import 'package:attendancebyface/screens/truc_ban/camera_rtsp_screen.dart';

/// App Router sử dụng go_router để quản lý navigation
class AppRouter {
  static Widget extraMissing(String message) {
    return Builder(
      builder: (context) => Scaffold(
        body: AppErrorWidget(
          message: message,
          title: 'Không thể mở trang',
          actionText: 'Về trang chủ',
          onRetry: () => goBack(context),
        ),
      ),
    );
  }

  /// Router configuration
  static final GoRouter router = GoRouter(
    navigatorKey: ErrorInterceptor.navigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    redirect: _handleRedirect,
    routes: [
      // Root route - Login
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main app routes với nested navigation
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          final user = state.extra as UserModel?;
          if (user == null) {
            return extraMissing('Không tìm thấy thông tin người dùng');
          }
          // Default tab là attendance (index 1)
          return CustomNavBar(user: user, initialIndex: 1);
        },
      ),

      // Standalone screens
      GoRoute(
        path: '/register-face',
        name: 'register-face',
        builder: (context, state) {
          final user = state.extra as UserModel?;
          if (user == null) {
            return extraMissing('Không tìm thấy thông tin người dùng');
          }
          return RegisterFaceScreen(user: user);
        },
      ),

      GoRoute(
        path: '/leave-create',
        name: 'leave-create',
        builder: (context, state) {
          final approverGroups = state.extra as ApproverGroups?;
          if (approverGroups == null) {
            return extraMissing('Không tìm thấy thông tin người duyệt');
          }
          return LeaveCreateScreen(approverGroups: approverGroups);
        },
      ),

      GoRoute(
        path: '/notification',
        name: 'notification',
        builder: (context, state) {
          final user = state.extra as UserModel?;
          if (user == null) {
            return extraMissing('Không tìm thấy thông tin người dùng');
          }
          return NotificationScreen(user: user);
        },
      ),

      GoRoute(
        path: '/qr-scanner',
        name: 'qr-scanner',
        builder: (context, state) => const QRScannerScreen(),
      ),

      GoRoute(
        path: '/attendance-map',
        name: 'attendance-map',
        builder: (context, state) {
          final extra = state.extra as AttendanceMapExtra?;
          if (extra == null) {
            return extraMissing('Không tìm thấy toạ độ');
          }
          return AttendanceMapScreen(lat: extra.lat, lng: extra.lng);
        },
      ),

      GoRoute(
        path: '/manual-attendance',
        name: 'manual-attendance',
        builder: (context, state) {
          final extra = state.extra as ManualAttendanceExtra?;
          if (extra == null) {
            return extraMissing('Không tìm thấy thông tin chấm công thủ công');
          }
          return BlocProvider.value(
            value: extra.cubit,
            child: ManualAttendanceScreen(user: extra.user),
          );
        },
      ),

      GoRoute(
        path: '/pdf-viewer',
        name: 'pdf-viewer',
        builder: (context, state) {
          final extra = state.extra as PdfViewerExtra?;
          if (extra == null) {
            return extraMissing('Không tìm thấy file báo cáo');
          }
          return PdfViewerScreen(filePath: extra.filePath, title: extra.title);
        },
      ),

      GoRoute(
        path: '/camera-rtsp',
        name: 'camera-rtsp',
        builder: (context, state) => const CameraRTSPScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: AppErrorWidget(
        message: 'Trang không tìm thấy: ${state.uri.path}',
        title: 'Không tìm thấy trang',
        actionText: 'Về trang chủ',
        onRetry: () => goBack(context),
      ),
    ),
  );

  /// Redirect auth: hiện no-op.
  /// Guard thật (UserCubit.currentUser) sẽ làm ở Phase 4 vì phụ thuộc extra + cubit.
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    return null;
  }

  /// Helper methods cho navigation

  /// Navigate to home với user data
  static void goToHome(BuildContext context, UserModel user) {
    context.go('/home', extra: user);
  }

  /// Navigate to register face
  static void goToRegisterFace(BuildContext context, UserModel user) {
    context.push('/register-face', extra: user);
  }

  /// Navigate to leave create
  static Future<Object?> goToLeaveCreate(
    BuildContext context,
    ApproverGroups approverGroups,
  ) {
    return context.push('/leave-create', extra: approverGroups);
  }

  /// Navigate to notification (push để còn nút quay lại mặc định).
  static void goToNotification(BuildContext context, UserModel user) {
    context.push('/notification', extra: user);
  }

  /// Navigate to QR scanner
  static void goToQRScanner(BuildContext context) {
    context.push('/qr-scanner');
  }

  static void goToAttendanceMap(
    BuildContext context, {
    required double lat,
    required double lng,
  }) {
    context.push('/attendance-map', extra: AttendanceMapExtra(lat: lat, lng: lng));
  }

  static void goToManualAttendance(
    BuildContext context, {
    required UserModel user,
    required AttendanceCubit cubit,
  }) {
    context.push(
      '/manual-attendance',
      extra: ManualAttendanceExtra(user: user, cubit: cubit),
    );
  }

  static void goToPdfViewer(
    BuildContext context, {
    required String filePath,
    required String title,
  }) {
    context.push(
      '/pdf-viewer',
      extra: PdfViewerExtra(filePath: filePath, title: title),
    );
  }

  static void goToCameraRtsp(BuildContext context) {
    context.push('/camera-rtsp');
  }

  /// Navigate back
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // Nếu không thể pop, điều hướng về home với user data
      final userCubit = context.read<UserCubit>();
      final user = userCubit.currentUser;
      if (user != null) {
        context.go('/home', extra: user);
      } else {
        context.go('/');
      }
    }
  }

  /// Navigate to login và clear stack
  static void goToLogin(BuildContext context) {
    // Sử dụng go để thay thế toàn bộ stack
    context.go('/');
  }
}

class AttendanceMapExtra {
  final double lat;
  final double lng;

  const AttendanceMapExtra({required this.lat, required this.lng});
}

class ManualAttendanceExtra {
  final UserModel user;
  final AttendanceCubit cubit;

  const ManualAttendanceExtra({required this.user, required this.cubit});
}

class PdfViewerExtra {
  final String filePath;
  final String title;

  const PdfViewerExtra({required this.filePath, required this.title});
}
