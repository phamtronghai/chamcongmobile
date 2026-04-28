import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:attendancebyface/core/repositories/device_repository.dart';

/// Top-level background handler for Firebase Messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Khởi tạo Firebase nếu cần
  try {
    // Intentionally minimal; initialize services here if needed in the future.
  } catch (e) {
    debugPrint('Lỗi khi xử lý background message: $e');
  }
}

/// Service to manage push notifications (FCM) and local notifications.
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
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );

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
      final RemoteNotification? notification = message.notification;
      final AndroidNotification? android = notification?.android;

      // Fallback: Hiển thị local notification cho TẤT CẢ message types
      // để dễ debug và kiểm thử trên iOS
      if (notification != null) {
        // Có notification payload - hiển thị trực tiếp
        await _showLocalNotification(
          id: notification.hashCode,
          title: notification.title ?? 'Thông báo',
          body: notification.body ?? '',
          payload: message.data.isNotEmpty ? message.data.toString() : null,
        );
      } else if (android != null) {
        // Android specific notification
        await _showLocalNotification(
          id: android.hashCode,
          title: android.channelId ?? 'Thông báo',
          body: message.data.toString(),
          payload: message.data.isNotEmpty ? message.data.toString() : null,
        );
      } else {
        // Data-only message hoặc message không có notification payload
        // Fallback: Tạo local notification từ data hoặc messageId
        final String title =
            message.data['title'] ?? message.data['message'] ?? 'Thông báo mới';
        final String body =
            message.data['body'] ??
            message.data['content'] ??
            message.data.toString();

        await _showLocalNotification(
          id: message.hashCode,
          title: title,
          body: body,
          payload: message.data.isNotEmpty ? message.data.toString() : null,
        );
      }
    }, onError: (error) {});

    // Opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // TODO: route based on message.data if needed
    }, onError: (error) {});

    // App opened from a terminated state via notification
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {}
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

    if (isApple) {
      // iOS/macOS: bắt buộc có APNs token trước khi gọi FCM API
      String? apnsToken;
      try {
        apnsToken = await _messaging.getAPNSToken();
        if (apnsToken?.isEmpty ?? true) {
          return;
        }
      } catch (e) {
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
