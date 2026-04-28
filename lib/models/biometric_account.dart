/// Model để lưu thông tin tài khoản sinh trắc học
class BiometricAccount {
  final String id;
  final String username;
  final String password;
  final String name;
  final String avatar;
  final String baseUrl;
  final String organizationName;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  BiometricAccount({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.avatar,
    required this.baseUrl,
    required this.organizationName,
    required this.createdAt,
    this.lastUsedAt,
  });

  /// Tạo ID mới từ timestamp
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Tạo từ JSON
  factory BiometricAccount.fromJson(Map<String, dynamic> json) {
    return BiometricAccount(
      id: json['id'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      baseUrl: json['baseUrl'] as String,
      organizationName: json['organizationName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
    );
  }

  /// Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'avatar': avatar,
      'baseUrl': baseUrl,
      'organizationName': organizationName,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  /// Copy với các thay đổi
  BiometricAccount copyWith({
    String? id,
    String? username,
    String? password,
    String? name,
    String? avatar,
    String? baseUrl,
    String? organizationName,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return BiometricAccount(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      baseUrl: baseUrl ?? this.baseUrl,
      organizationName: organizationName ?? this.organizationName,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  /// Cập nhật thời gian sử dụng gần nhất
  BiometricAccount markAsUsed() {
    return copyWith(lastUsedAt: DateTime.now());
  }

  /// Kiểm tra xem có trùng với tài khoản khác không (username + baseUrl)
  bool isDuplicateOf(BiometricAccount other) {
    return username == other.username && baseUrl == other.baseUrl;
  }
}

