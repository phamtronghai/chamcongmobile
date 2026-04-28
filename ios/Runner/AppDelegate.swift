import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase được khởi tạo trong Flutter main.dart
    // FCM delegate sẽ được cấu hình từ Flutter sau khi Firebase khởi tạo
    
    // Đăng ký remote notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")
    
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}

// MARK: - UNUserNotificationCenterDelegate
// FlutterAppDelegate đã implement UNUserNotificationCenterDelegate
// Nên chỉ cần override các method cần thiết
extension AppDelegate {
  // Hiển thị notification khi app ở foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    
    // Xử lý FCM message
    if let messageID = userInfo["gcm.message_id"] {
      print("Message ID: \(messageID)")
    }
    
    // Hiển thị notification ngay cả khi app ở foreground
    completionHandler([[.alert, .badge, .sound]])
  }
  
  // Xử lý khi user tap vào notification
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    
    // Xử lý FCM message
    if let messageID = userInfo["gcm.message_id"] {
      print("Message ID: \(messageID)")
    }
    
    // Gọi super để FlutterAppDelegate xử lý
    super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
}

// MARK: - APNs token forwarding (bắt buộc khi tắt AppDelegate proxy)
extension AppDelegate {
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Chuyển APNs device token cho Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken
    // Forward cho FlutterAppDelegate
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
  
  // MARK: - Remote Notification Handling (theo tài liệu Firebase)
  override func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    print("📱 didReceiveRemoteNotification: \(userInfo)")
    
    // Xử lý FCM message
    if let messageID = userInfo["gcm.message_id"] {
      print("📱 FCM Message ID: \(messageID)")
    }
    
    // Export delivery metrics to BigQuery (theo tài liệu Firebase)
    Messaging.messaging().appDidReceiveMessage(userInfo)
    
    // Gọi super để FlutterAppDelegate xử lý
    super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    
    // Hoàn thành background fetch
    completionHandler(.newData)
  }
}
