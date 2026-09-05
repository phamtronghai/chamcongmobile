/// Phòng ban từ GET /api/slug
class AdminDepartment {
  final String slug;
  final String department;

  const AdminDepartment({required this.slug, required this.department});

  factory AdminDepartment.fromJson(Map<String, dynamic> json) {
    return AdminDepartment(
      slug: json['slug'] as String? ?? '',
      department: json['department'] as String? ?? '',
    );
  }
}

/// Nhân viên tổ chức từ GET /employees?slug=
///
/// Không render: workName, approval_last_month, approval_this_month.
/// [userId] / [departmentSlug] dùng cho hành động admin, không hiện trên UI chi tiết.
class AdminEmployee {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String position;
  final String department;
  final String departmentSlug;
  final String? image;
  final num countYear;
  final num countLastMonth;
  final num countThisMonth;
  final num workCount;

  const AdminEmployee({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    required this.position,
    required this.department,
    required this.departmentSlug,
    this.image,
    required this.countYear,
    required this.countLastMonth,
    required this.countThisMonth,
    required this.workCount,
  });

  factory AdminEmployee.fromJson(
    Map<String, dynamic> json, {
    String departmentSlug = '',
  }) {
    return AdminEmployee(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      position: json['position'] as String? ?? '',
      department: json['department'] as String? ?? '',
      departmentSlug:
          json['department_slug'] as String? ?? departmentSlug,
      image: json['image'] as String?,
      countYear: json['count_year'] as num? ?? 0,
      countLastMonth: json['count_last_month'] as num? ?? 0,
      countThisMonth: json['count_this_month'] as num? ?? 0,
      workCount: json['work_count'] as num? ?? 0,
    );
  }
}
