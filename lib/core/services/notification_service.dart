import 'dart:async';
import 'dart:convert';

import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/database/app_database.dart';
import 'package:attendancebyface/core/network/error_interceptor.dart';
import 'package:attendancebyface/models/notification_item.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:attendancebyface/core/repositories/device_repository.dart';
import 'package:attendancebyface/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

// --- Persist FCM (foreground / background / mở từ notification) ---

class _ResolvedPush {
  const _ResolvedPush(this.title, this.body, this.localNotifId);
  final String title;
  final String body;
  final int localNotifId;
}

_ResolvedPush _resolvePushDisplay(RemoteMessage message) {
  final RemoteNotification? notification = message.notification;
  final AndroidNotification? android = notification?.android;

  late final String title;
  late final String body;
  late final int localNotifId;

  if (notification != null) {
    title = notification.title ?? 'Thông báo';
    body = notification.body ?? '';
    localNotifId = notification.hashCode;
  } else if (android != null) {
    title = android.channelId ?? 'Thông báo';
    body = message.data.toString();
    localNotifId = android.hashCode;
  } else {
    title =
        message.data['title'] ?? message.data['message'] ?? 'Thông báo mới';
    body =
        message.data['body'] ??
        message.data['content'] ??
        message.data.toString();
    localNotifId = message.hashCode;
  }
  return _ResolvedPush(title, body, localNotifId);
}

int _pushTypeIndexFromData(Map<String, dynamic> data) {
  final t = data['type']?.toString().toLowerCase();
  return switch (t) {
    'success' => NotificationType.success.index,
    'warning' => NotificationType.warning.index,
    'error' => NotificationType.error.index,
    'info' => NotificationType.info.index,
    _ => NotificationType.info.index,
  };
}

String _stablePushMessageId(RemoteMessage message) {
  final mid = message.messageId;
  if (mid != null && mid.isNotEmpty) return mid;
  return 'gen_${message.hashCode}_${DateTime.now().microsecondsSinceEpoch}';
}

Future<void> _persistRemoteMessageToDrift(
  RemoteMessage message,
  AppDatabase db,
) async {
  final r = _resolvePushDisplay(message);
  final data = Map<String, dynamic>.from(message.data);
  await db.upsertPushNotification(
    id: _stablePushMessageId(message),
    title: r.title,
    body: r.body,
    typeIndex: _pushTypeIndexFromData(data),
    rawData: data.isNotEmpty ? jsonEncode(data) : null,
  );
}

Future<void> _persistRemoteMessageWhenDbReady(RemoteMessage message) async {
  if (!GetIt.instance.isRegistered<AppDatabase>()) return;
  try {
    await _persistRemoteMessageToDrift(
      message,
      GetIt.instance<AppDatabase>(),
    );
  } catch (e, st) {
    debugPrint('Lưu thông báo local thất bại: $e\n$st');
  }
}

/// Top-level background handler for Firebase Messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e, st) {
    debugPrint('FCM background: Firebase init: $e\n$st');
  }

  final AppDatabase db = AppDatabase();
  try {
    await _persistRemoteMessageToDrift(message, db);
  } catch (e, st) {
    debugPrint('FCM background: lưu Drift thất bại: $e\n$st');
  } finally {
    await db.close();
  }
}

/// Service to manage push notifications (FCM) and local notifications.
///
/// Thông báo FCM được lưu Drift khi: app foreground (`onMessage`), nền
/// (`firebaseMessagingBackgroundHandler` — Android/data message), mở app từ
/// push (`onMessageOpenedApp`, `getInitialMessage`).
///
/// Trạng thái “đã/chưa đăng ký” theo FCM token trên UI dùng [SamcomChip]
/// tại [NotificationScreen] (`lib/screens/notification_screen.dart`).
class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// High importance channel id used for Android notifications
  static const String _androidChannelId = 'high_importance_channel';
  static const String _androidChannelName = 'High Importance Notifications';
  static const String _androidChannelDescription =
      'This channel is used for important notifications.';

  bool _initialized = false;
  final DeviceRepository _deviceRepository = DeviceRepository();
  String? _currentUserId;

  Future<void> initialize() async {
    if (_initialized) return;

    await _initializeLocalNotifications();
    await _configureFirebaseMessaging();

    _initialized = true;
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.notificationResponseType ==
            NotificationResponseType.selectedNotification) {
          openNotificationScreenFromTap();
        }
      },
    );

    final NotificationAppLaunchDetails? launchDetails =
        await _localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      openNotificationScreenFromTap();
    }

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: _androidChannelDescription,
      importance: Importance.high,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImplementation?.createNotificationChannel(channel);

    // Android 13+ requires runtime notification permission
    final bool? notificationsEnabled = await androidImplementation
        ?.areNotificationsEnabled();
    if (notificationsEnabled == false) {
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> _configureFirebaseMessaging() async {
    // Cấu hình FCM delegate cho iOS (sau khi Firebase đã khởi tạo)
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // FCM delegate đã được cấu hình trong AppDelegate.swift
      // Chỉ cần đảm bảo Firebase đã sẵn sàng
    }

    // Kiểm tra quyền hiện tại (không yêu cầu quyền ở đây)
    await _messaging.getNotificationSettings();

    // Foreground presentation on iOS/macOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final r = _resolvePushDisplay(message);

      await _persistRemoteMessageWhenDbReady(message);

      await _showLocalNotification(
        id: r.localNotifId,
        title: r.title,
        body: r.body,
        payload: message.data.isNotEmpty ? message.data.toString() : null,
      );
    }, onError: (error) {});

    // Mở app từ thông báo (nền / màn khóa): lưu Drift rồi điều hướng
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _persistRemoteMessageWhenDbReady(message);
      openNotificationScreenFromTap();
    }, onError: (error) {});

    // Cold start sau khi user chạm thông báo FCM
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      await _persistRemoteMessageWhenDbReady(initialMessage);
      openNotificationScreenFromTap();
    }
  }

  /// Mở [NotificationScreen] (`/notification`) sau khi Navigator + UserCubit sẵn sàng.
  void openNotificationScreenFromTap() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? ctx =
          ErrorInterceptor.navigatorKey.currentContext;
      if (ctx == null) {
        debugPrint('Mở thông báo: Navigator chưa gắn context');
        return;
      }
      UserModel? user;
      try {
        user = ctx.read<UserCubit>().currentUser;
      } catch (e) {
        debugPrint('Mở thông báo: không đọc UserCubit: $e');
        return;
      }
      if (user == null) {
        AppRouter.router.go('/');
        return;
      }
      AppRouter.router.go('/notification', extra: user);
    });
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: _androidChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true, // Hiển thị alert
      presentBadge: true, // Hiển thị badge
      presentSound: true, // Phát âm thanh
      categoryIdentifier: 'fcm_message', // Category để xử lý action
      threadIdentifier: 'fcm_thread', // Thread identifier
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  /// Xin quyền lần đầu và đăng ký FCM token lên server
  Future<void> requestPermissionAndSyncToken({required String userId}) async {
    _currentUserId = userId;

    // Kiểm tra quyền hiện tại trước
    final NotificationSettings currentSettings = await _messaging
        .getNotificationSettings();

    // Chỉ yêu cầu quyền nếu chưa được cấp
    if (currentSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
    }

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final bool isApple =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    if (isApple && defaultTargetPlatform == TargetPlatform.iOS) {
      // APNs token có thể đến trễ sau didRegister; chờ ngắn trước khi bỏ qua đồng bộ
      String? apnsToken;
      for (var i = 0; i < 24; i++) {
        try {
          apnsToken = await _messaging.getAPNSToken();
          if (apnsToken != null && apnsToken.isNotEmpty) break;
        } catch (_) {}
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      if (apnsToken == null || apnsToken.isEmpty) {
        debugPrint(
          'FCM: không lấy được APNs token sau ~6s — kiểm tra Push capability & provisioning profile',
        );
        return;
      }
    }

    // Lấy FCM token và đăng ký lên server
    final String? token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _deviceRepository.registerFcmToken(token: token, userId: userId);

        // Lắng nghe token refresh
        _setupTokenRefreshListener();
      } catch (e) {
        debugPrint('Lỗi khi đăng ký FCM token: $e');
      }
    } else {}
  }

  /// Thiết lập listener cho token refresh
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((String newToken) async {
      if (_currentUserId != null) {
        try {
          await _deviceRepository.registerFcmToken(
            token: newToken,
            userId: _currentUserId!,
          );
        } catch (e) {
          debugPrint('Lỗi khi đăng ký FCM token: $e');
        }
      }
    });
  }

  /// Hủy đăng ký FCM token khi logout
  Future<void> unregisterFcmToken() async {
    if (_currentUserId == null) return;

    try {
      final String? token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _deviceRepository.unregisterFcmToken(token: token);
      }
    } catch (e) {
      debugPrint('Lỗi khi hủy đăng ký FCM token: $e');
    }

    _currentUserId = null;
  }
}
