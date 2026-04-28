enum ApproverRole {
  departmentManager, // Trưởng/phó phòng
  boardOfDirector, // Ban giám đốc
}

enum ApprovalLevel {
  department, // Cấp phòng ban
  board, // Cấp ban giám đốc
}

class Approver {
  final String id;
  final String name;
  final String position;
  final String? image; // Cho phép null

  Approver({
    required this.id,
    required this.name,
    required this.position,
    this.image, // Không bắt buộc
  });

  factory Approver.fromJson(Map<String, dynamic> json) {
    return Approver(
      id: json['id'] as String,
      name: json['name'] as String,
      position: json['position'] as String,
      image: json['image'] as String?, // Cho phép null
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'position': position, 'image': image};
  }

  /// Xác định role dựa trên position
  ApproverRole get role {
    final pos = position.toLowerCase();
    if (pos.contains('giám đốc') || pos.contains('chủ tịch')) {
      return ApproverRole.boardOfDirector;
    }
    return ApproverRole.departmentManager;
  }

  /// Kiểm tra xem approver có thể duyệt cấp độ nào
  bool canApproveLevel(ApprovalLevel level) {
    switch (level) {
      case ApprovalLevel.department:
        return role == ApproverRole.departmentManager ||
            role == ApproverRole.boardOfDirector;
      case ApprovalLevel.board:
        return role == ApproverRole.boardOfDirector;
    }
  }

  /// Kiểm tra xem có phải ban giám đốc không
  bool get isBoardMember => role == ApproverRole.boardOfDirector;

  /// Kiểm tra xem có phải trưởng/phó phòng không
  bool get isDepartmentManager => role == ApproverRole.departmentManager;

  /// Lấy avatar URL đầy đủ
  String? get fullImageUrl {
    if (image == null) return null;
    if (image!.startsWith('http')) return image;
    // Có thể cần base URL từ ApiClient
    return image; // Tạm thời return as-is
  }
}

class ApproverGroups {
  final List<Approver> departmentManagers;
  final List<Approver> boardOfDirectors;

  ApproverGroups({
    required this.departmentManagers,
    required this.boardOfDirectors,
  });

  factory ApproverGroups.fromJson(Map<String, dynamic> json) {
    final dept = (json['department_managers'] as List<dynamic>? ?? [])
        .map((e) => Approver.fromJson(e as Map<String, dynamic>))
        .toList();
    final bod = (json['board_of_directors'] as List<dynamic>? ?? [])
        .map((e) => Approver.fromJson(e as Map<String, dynamic>))
        .toList();

    return ApproverGroups(departmentManagers: dept, boardOfDirectors: bod);
  }

  /// Tạo ApproverGroups từ 2 list riêng biệt
  factory ApproverGroups.fromLists({
    required List<Approver> managers,
    required List<Approver> directors,
  }) {
    return ApproverGroups(
      departmentManagers: managers,
      boardOfDirectors: directors,
    );
  }

  /// Lấy tất cả approver có thể duyệt cấp độ cụ thể
  List<Approver> getApproversForLevel(ApprovalLevel level) {
    final allApprovers = [...departmentManagers, ...boardOfDirectors];
    return allApprovers.where((a) => a.canApproveLevel(level)).toList();
  }

  /// Lấy tất cả approvers
  List<Approver> get allApprovers => [
    ...departmentManagers,
    ...boardOfDirectors,
  ];

  /// Tìm approver theo ID
  Approver? findById(String id) {
    return allApprovers.firstWhere(
      (approver) => approver.id == id,
      orElse: () => throw StateError('Approver not found'),
    );
  }

  /// Tìm approver theo ID (safe)
  Approver? findByIdSafe(String id) {
    try {
      return allApprovers.firstWhere((approver) => approver.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Lấy số lượng approvers theo role
  int get departmentManagerCount => departmentManagers.length;
  int get boardDirectorCount => boardOfDirectors.length;
  int get totalCount => allApprovers.length;
}
