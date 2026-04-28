class UserModel {
  final String id;
  final String name;
  final String email;
  final String image;
  final String role;
  final bool? banned;
  final String username;
  final String position;
  final String? phone;
  final String department;
  final String departmentSlug;
  final String
  canApprove; // nv - nhân viên, tp - Trưởng/phó phòng, bgd - Ban Giám đốc
  final bool isFaceRegistered; // Đã đăng ký khuôn mặt chưa
  final bool isCitizenRegistered; // Đã đăng ký căn cước chưa
  // Thông tin căn cước (nếu đã đăng ký)
  final String? citizenNumber; // số CCCD
  final String? oldIdNumber; // số CMT cũ
  final String? fullNameOnCitizen; // họ tên trên CCCD
  final String? dateOfBirth; // YYYY-MM-DD
  final String? gender; // Nam/Nữ
  final String? address; // địa chỉ
  final String? issuedDate; // YYYY-MM-DD

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.role,
    this.banned,
    required this.username,
    required this.position,
    this.phone,
    required this.department,
    required this.departmentSlug,
    required this.canApprove,
    this.isFaceRegistered = false,
    this.isCitizenRegistered = false,
    this.citizenNumber,
    this.oldIdNumber,
    this.fullNameOnCitizen,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.issuedDate,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? image,
    String? role,
    bool? banned,
    String? username,
    String? position,
    String? phone,
    String? department,
    String? departmentSlug,
    String? canApprove,
    bool? isFaceRegistered,
    bool? isCitizenRegistered,
    String? citizenNumber,
    String? oldIdNumber,
    String? fullNameOnCitizen,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? issuedDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      role: role ?? this.role,
      banned: banned ?? this.banned,
      username: username ?? this.username,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      departmentSlug: departmentSlug ?? this.departmentSlug,
      canApprove: canApprove ?? this.canApprove,
      isFaceRegistered: isFaceRegistered ?? this.isFaceRegistered,
      isCitizenRegistered: isCitizenRegistered ?? this.isCitizenRegistered,
      citizenNumber: citizenNumber ?? this.citizenNumber,
      oldIdNumber: oldIdNumber ?? this.oldIdNumber,
      fullNameOnCitizen: fullNameOnCitizen ?? this.fullNameOnCitizen,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      issuedDate: issuedDate ?? this.issuedDate,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      image: json['image'] as String? ?? '',
      role: json['role'] as String? ?? '',
      banned: json['banned'] as bool?,
      username: json['username'] as String? ?? '',
      position: json['position'] as String? ?? '',
      phone: json['phone'] as String?,
      department: json['department'] as String? ?? '',
      departmentSlug: json['department_slug'] as String? ?? '',
      canApprove: json['can_approve'] as String? ?? 'nv',
      isFaceRegistered: json['isFaceRegistered'] as bool? ?? false,
      isCitizenRegistered: json['isCitizenRegistered'] as bool? ?? false,
      citizenNumber: json['citizenNumber'] as String?,
      oldIdNumber: json['oldIdNumber'] as String?,
      fullNameOnCitizen: json['fullName'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      issuedDate: json['issuedDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'role': role,
      'banned': banned,
      'username': username,
      'position': position,
      'phone': phone,
      'department': department,
      'department_slug': departmentSlug,
      'can_approve': canApprove,
      'isFaceRegistered': isFaceRegistered,
      'isCitizenRegistered': isCitizenRegistered,
      'citizenNumber': citizenNumber,
      'oldIdNumber': oldIdNumber,
      'fullName': fullNameOnCitizen,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'address': address,
      'issuedDate': issuedDate,
    };
  }
}
