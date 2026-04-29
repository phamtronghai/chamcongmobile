import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:attendancebyface/models/approver.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/screens/login_screen.dart';
import 'package:attendancebyface/screens/register_face_screen.dart';
import 'package:attendancebyface/screens/personal_info_screen.dart';
import 'package:attendancebyface/screens/leaveScreens/leave_create_screen.dart';
import 'package:attendancebyface/screens/notification_screen.dart';
import 'package:attendancebyface/screens/qr_scanner_screen.dart';
import 'package:attendancebyface/screens/camera_screen.dart';
import 'package:attendancebyface/screens/trucBan/truc_ban_screen.dart';
import 'package:attendancebyface/screens/trucBan/camera_rtsp_screen.dart';
import 'package:attendancebyface/widgets/custom_navbar.dart';
import 'package:attendancebyface/core/network/error_interceptor.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';

/// App Router sử dụng go_router để quản lý navigation
class AppRouter {
  /// Router configuration
  static final GoRouter router = GoRouter(
    navigatorKey: ErrorInterceptor.navigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
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
            return const Scaffold(
              body: Center(
                child: Text('Lỗi: Không tìm thấy thông tin người dùng'),
              ),
            );
          }
          // Default tab là attendance (index 1)
          return CustomNavBar(user: user, initialIndex: 1);
        },
        routes: [
          // Attendance tab (default)
          GoRoute(
            path: 'attendance',
            name: 'attendance',
            builder: (context, state) {
              final user = state.extra as UserModel?;
              if (user == null) {
                return const Scaffold(
                  body: Center(
                    child: Text('Lỗi: Không tìm thấy thông tin người dùng'),
                  ),
                );
              }
              return CustomNavBar(user: user, initialIndex: 1);
            },
          ),

          // Leave tab
          GoRoute(
            path: 'leave',
            name: 'leave',
            builder: (context, state) {
              final user = state.extra as UserModel?;
              if (user == null) {
                return const Scaffold(
                  body: Center(
                    child: Text('Lỗi: Không tìm thấy thông tin người dùng'),
                  ),
                );
              }
              return CustomNavBar(user: user, initialIndex: 0);
            },
          ),

          // Personal info tab
          GoRoute(
            path: 'personal',
            name: 'personal',
            builder: (context, state) {
              final user = state.extra as UserModel?;
              if (user == null) {
                return const Scaffold(
                  body: Center(
                    child: Text('Lỗi: Không tìm thấy thông tin người dùng'),
                  ),
                );
              }
              return CustomNavBar(user: user, initialIndex: 3);
            },
          ),
        ],
      ),

      // Standalone screens
      GoRoute(
        path: '/register-face',
        name: 'register-face',
        builder: (context, state) {
          final user = state.extra as UserModel?;
          if (user == null) {
            return const Scaffold(
              body: Center(
                child: Text('Lỗi: Không tìm thấy thông tin người dùng'),
              ),
            );
          }
          return RegisterFaceScreen(user: user);
        },
      ),

      GoRoute(
        path: '/personal-info',
        name: 'personal-info',
        builder: (context, state) => const PersonalInfoScreen(),
      ),

      GoRoute(
        path: '/leave-create',
        name: 'leave-create',
        builder: (context, state) {
          final approverGroups = state.extra as ApproverGroups?;
          if (approverGroups == null) {
            return const Scaffold(
              body: Center(
                child: Text('Lỗi: Không tìm thấy thông tin người duyệt'),
              ),
            );
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
            return const Scaffold(
              body: Center(
                child: Text('Lỗi: Không tìm thấy thông tin người dùng'),
              ),
            );
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
        path: '/camera',
        name: 'camera',
        builder: (context, state) => const CameraScreen(),
      ),

      GoRoute(
        path: '/truc-ban',
        name: 'truc-ban',
        builder: (context, state) => const TrucBanScreen(),
        routes: [
           GoRoute(
            path: 'camera',
            name: 'truc-ban-camera',
            builder: (context, state) => const CameraRTSPScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Trang không tìm thấy: ${state.uri.path}'),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Về trang chủ',
              width: 180,
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Xử lý redirect logic cho authentication
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    // Nếu đang ở login screen, không redirect
    if (state.uri.path == '/') {
      return null;
    }

    return null;
  }

  /// Helper methods cho navigation

  /// Navigate to home với user data
  static void goToHome(BuildContext context, UserModel user) {
    context.go('/home', extra: user);
  }

  /// Navigate to specific tab trong home (chỉ dùng cho deep linking)
  static void goToHomeTab(BuildContext context, UserModel user, int tabIndex) {
    String path = '/home';
    switch (tabIndex) {
      case 0:
        path = '/home/leave';
        break;
      case 1:
        path = '/home/attendance';
        break;
      case 2:
        path = '/home/personal';
        break;
      case 3:
        path = '/home/personal';
        break;
    }
    context.go(path, extra: user);
  }

  /// Navigate to register face
  static void goToRegisterFace(BuildContext context, UserModel user) {
    context.go('/register-face', extra: user);
  }

  /// Navigate to personal info
  static void goToPersonalInfo(BuildContext context) {
    context.go('/personal-info');
  }

  /// Navigate to leave create
  static void goToLeaveCreate(
    BuildContext context,
    ApproverGroups approverGroups,
  ) {
    context.go('/leave-create', extra: approverGroups);
  }

  /// Navigate to notification
  static void goToNotification(BuildContext context, UserModel user) {
    context.go('/notification', extra: user);
  }

  /// Navigate to QR scanner
  static void goToQRScanner(BuildContext context) {
    context.go('/qr-scanner');
  }

  /// Navigate to camera
  static void goToCamera(BuildContext context) {
    context.go('/camera');
  }

  /// Navigate to map screen
  static void goToMap(
    BuildContext context, {
    double? lat,
    double? lng,
    String? location,
  }) {
    context.go('/map', extra: {'lat': lat, 'lng': lng, 'location': location});
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
