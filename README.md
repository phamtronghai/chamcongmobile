# 📱 Chấm Công Bằng Khuôn Mặt

Ứng dụng Flutter đa nền tảng (Android, iOS) cho phép người dùng thực hiện chấm công thông qua nhận diện khuôn mặt với các tính năng bảo mật và quản lý tiên tiến.

---

## ✨ Tính năng chính

### 🔐 **Xác thực & Bảo mật**

- **Đăng nhập đa phương thức**: Username/Password, Face ID, Touch ID
- **Bảo mật thiết bị**: Phát hiện root/jailbreak, giả mạo vị trí, thiết bị giả lập
- **Mã hóa dữ liệu**: Secure Storage cho thông tin nhạy cảm
- **Token-based authentication**: JWT với auto-refresh

### 👤 **Quản lý người dùng**

- **Đăng ký khuôn mặt**: Chụp và lưu trữ dữ liệu sinh trắc học
- **Thông tin cá nhân**: Quản lý profile, đổi mật khẩu
- **Phân quyền**: Hỗ trợ nhiều vai trò (nhân viên, trưởng phòng, ban giám đốc)

### ⏰ **Chấm công thông minh**

- **Nhận diện khuôn mặt**: AI-powered face recognition
- **Định vị GPS**: Theo dõi vị trí chấm công chính xác
- **Lịch sử chi tiết**: Xem lại các lần chấm công với địa chỉ
- **Thời gian thực**: Hiển thị thời gian server để tham khảo

### 📋 **Quản lý nghỉ phép**

- **Đăng ký nghỉ phép**: Tạo đơn xin nghỉ với lý do chi tiết
- **Phê duyệt**: Hệ thống phê duyệt theo cấp bậc
- **Theo dõi trạng thái**: Cập nhật real-time trạng thái đơn

### 🔔 **Thông báo & Giao diện**

- **Push notifications**: Firebase Cloud Messaging
- **Theme động**: Light/Dark mode với adaptive theme
- **Font tùy chỉnh**: Overpass font family
- **Responsive UI**: Tối ưu cho nhiều kích thước màn hình

---

## 🏗️ Kiến trúc dự án

### 📁 **Cấu trúc thư mục**

```
lib/
├── core/                    # Hạ tầng cốt lõi
│   ├── app_config.dart      # Cấu hình ứng dụng
│   ├── app_theme.dart       # Theme và styling
│   ├── cubits/              # State management (BLoC)
│   ├── network/             # API client, interceptors
│   ├── repositories/        # Data layer abstraction
│   ├── services/           # Business logic services
│   ├── storage/            # Secure storage & keys
│   ├── utils/              # Helper utilities
│   └── widgets/            # Core UI components
├── models/                 # Data models (Freezed)
├── screens/               # UI screens
├── widgets/               # Reusable UI components
└── main.dart              # App entry point
```

### 🎯 **Patterns & Architecture**

- **Feature-Based Architecture**: Tổ chức theo tính năng
- **Repository Pattern**: Tách biệt data layer
- **BLoC/Cubit**: State management với sealed classes
- **Dependency Injection**: get_it cho service locator
- **Freezed**: Immutable data classes với code generation

---

## 🛠️ Công nghệ sử dụng

### 📱 **Flutter Framework**

- **SDK**: Dart 3.8.1+
- **Platform**: Android (API 21+), iOS (15.6+)
- **Architecture**: ARM64, x86_64

### 🔧 **Core Dependencies**

| **Category**         | **Package**              | **Version** | **Mục đích**               |
| -------------------- | ------------------------ | ----------- | -------------------------- |
| **State Management** | `flutter_bloc`           | ^8.1.6      | BLoC pattern               |
| **HTTP Client**      | `dio`                    | ^5.8.0+1    | API calls với interceptors |
| **Authentication**   | `local_auth`             | 2.3.0       | Biometric auth             |
| **Storage**          | `flutter_secure_storage` | ^9.2.4      | Secure data storage        |
| **Location**         | `geolocator`             | ^14.0.1     | GPS positioning            |
| **Camera**           | `camera`                 | ^0.11.1     | Face capture               |
| **Maps**             | `maplibre_gl`            | ^0.22.0     | Interactive maps           |
| **Theme**            | `adaptive_theme`         | ^3.6.0      | Dynamic theming            |
| **Notifications**    | `firebase_messaging`     | ^16.0.0     | Push notifications         |
| **QR Scanner**       | `mobile_scanner`         | ^7.0.1      | QR code scanning           |
| **Device Security**  | `safe_device`            | ^1.1.7      | Security detection         |

### 🔨 **Development Tools**

| **Tool**                 | **Purpose**                           |
| ------------------------ | ------------------------------------- |
| `freezed`                | Code generation cho immutable classes |
| `build_runner`           | Code generation runner                |
| `flutter_lints`          | Static analysis                       |
| `flutter_launcher_icons` | App icon generation                   |
| `flutter_native_splash`  | Splash screen                         |

---

## 🚀 Cài đặt & Chạy

### **Prerequisites**

- Flutter SDK 3.8.1+
- Dart SDK 3.8.1+
- Android Studio / Xcode
- Firebase project setup

### **Setup**

1. **Clone repository**

```bash
git clone <repository-url>
cd attendancebyface
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Firebase**

   - Thêm `google-services.json` (Android)
   - Thêm `GoogleService-Info.plist` (iOS)

4. **Run app**

```bash
# Debug mode
flutter run

# Release build
flutter build apk --release
flutter build ios --release
```

---

## 📱 Màn hình chính

### 🔐 **Authentication Flow**

- `LoginScreen`: Đăng nhập với organization selection
- `RegisterFaceScreen`: Đăng ký khuôn mặt

### 🏠 **Main Navigation**

- `AttendanceScreen`: Chấm công chính với face recognition
- `HistoryScreen`: Lịch sử chấm công chi tiết
- `LeaveScreen`: Quản lý nghỉ phép (đăng ký/phê duyệt)
- `SettingsScreen`: Cài đặt ứng dụng
- `PersonalInfoScreen`: Thông tin cá nhân

### 🔧 **Utility Screens**

- `NotificationScreen`: Quản lý thông báo
- `QRScannerScreen`: Quét QR code căn cước
- `CameraScreen`: Chụp ảnh khuôn mặt

---

## 🔒 Bảo mật

### **Device Security Checks**

- Root/Jailbreak detection
- Emulator detection
- Location spoofing detection
- Debug mode detection

### **Data Protection**

- AES encryption cho sensitive data
- Secure token storage
- Biometric authentication
- Certificate pinning

### **API Security**

- JWT token authentication
- Request/Response interceptors
- Error handling với retry logic
- Rate limiting

---

## 📊 Performance

### **Optimizations**

- Lazy loading cho large lists
- Image caching với CachedNetworkImage
- Efficient state management với BLoC
- Memory leak prevention

### **Monitoring**

- Firebase Analytics integration
- Crash reporting
- Performance monitoring
- User behavior tracking

---

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Coverage report
flutter test --coverage
```

---

## 📄 License

© 2025 Bản quyền thuộc về **SAMCOM**  
Phát triển bởi **Tổ nghiên cứu Phát triển Khoa học Công nghệ**

---

## 🤝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📞 Support

- **Email**: support@samcom.vn
- **Documentation**: [Wiki](link-to-wiki)
- **Issues**: [GitHub Issues](link-to-issues)

---

_Built with ❤️ using Flutter_
