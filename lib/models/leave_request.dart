import 'approver.dart';

enum LeaveType { morning, afternoon, fullDay }

enum LeaveStatus {
  pending, // Đang chờ
  departmentApproved, // Đã duyệt phòng ban (chờ BGĐ)
  approved, // Đã duyệt hoàn toàn
  rejected, // Bị từ chối
  cancelled, // Đã hủy
}

enum ApprovalWorkflow {
  departmentOnly, // Chỉ cần duyệt phòng ban (1 ngày, không phải trưởng/phó phòng)
  boardOnly, // Chỉ cần duyệt ban giám đốc (trưởng/phó phòng xin nghỉ, không phân biệt số ngày)
  bothLevels, // Cần duyệt cả 2 cấp (2 ngày trở lên, không phải trưởng/phó phòng)
}

class LeaveRequest {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final LeaveType leaveType;
  final String reason;
  final String? location; // Địa điểm nghỉ phép
  final LeaveStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? rejectionReason;

  // Thông tin người tạo đơn từ API
  final String? userId;
  final String? nameApplicant;
  final String? department;
  final String? departmentApprovedName;
  final String? boardApprovedName;

  // Workflow approval
  final ApprovalWorkflow workflow;
  final String? workflowString;
  final DateTime? departmentApprovedAt;
  final String? departmentApprovedId;
  final DateTime? boardApprovedAt;
  final String? boardApprovedId;

  LeaveRequest({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    required this.reason,
    this.location,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.rejectionReason,
    this.userId,
    this.nameApplicant,
    this.department,
    this.departmentApprovedName,
    this.boardApprovedName,
    this.workflow = ApprovalWorkflow.departmentOnly,
    this.workflowString,
    this.departmentApprovedAt,
    this.departmentApprovedId,
    this.boardApprovedAt,
    this.boardApprovedId,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    LeaveType parseType(String v) {
      switch (v) {
        case 'morning':
          return LeaveType.morning;
        case 'afternoon':
          return LeaveType.afternoon;
        case 'full_day':
        default:
          return LeaveType.fullDay;
      }
    }

    LeaveStatus parseStatus(String v) {
      switch (v) {
        case 'department_approved':
          return LeaveStatus.departmentApproved;
        case 'approved':
          return LeaveStatus.approved;
        case 'rejected':
          return LeaveStatus.rejected;
        case 'cancelled':
          return LeaveStatus.cancelled;
        case 'pending':
        default:
          return LeaveStatus.pending;
      }
    }

    ApprovalWorkflow parseWorkflow(String v) {
      switch (v) {
        case 'board_only':
          return ApprovalWorkflow.boardOnly;
        case 'both_levels':
          return ApprovalWorkflow.bothLevels;
        case 'department_only':
        default:
          return ApprovalWorkflow.departmentOnly;
      }
    }

    DateTime parseDate(dynamic v) => DateTime.parse((v as String).trim());
    DateTime? parseDateNullable(dynamic v) =>
        v == null ? null : DateTime.parse((v as String).trim());

    final String id = (json['id'] ?? '') as String;
    final String? startDateStr =
        (json['startDate'] ?? json['start_date']) as String?;
    final String? endDateStr = (json['endDate'] ?? json['end_date']) as String?;
    final String leaveTypeStr =
        (json['leaveType'] ?? json['leave_type'] ?? 'full_day') as String;
    final String? createdAtStr =
        (json['createdAt'] ?? json['created_at']) as String?;
    final String? approvedAtStr =
        (json['approvedAt'] ?? json['approved_at']) as String?;
    final String? deptApprovedAtStr =
        (json['departmentApprovedAt'] ?? json['department_approved_at'])
            as String?;
    final String? boardApprovedAtStr =
        (json['boardApprovedAt'] ?? json['board_approved_at']) as String?;
    return LeaveRequest(
      id: id,
      startDate: parseDate(startDateStr ?? ''),
      endDate: parseDate(endDateStr ?? ''),
      leaveType: parseType(leaveTypeStr),
      reason: json['reason'] as String? ?? '',
      location: json['location'] as String?,
      status: parseStatus(json['status'] as String? ?? 'pending'),
      createdAt: parseDate(createdAtStr ?? DateTime.now().toIso8601String()),
      approvedAt: parseDateNullable(approvedAtStr),
      rejectionReason:
          (json['rejectionReason'] ?? json['rejection_reason']) as String?,
      userId: json['userId'] as String?,
      nameApplicant:
          (json['nameApplicant'] ?? json['applicantName']) as String?,
      department: (json['department'] ?? json['applicantDepartment']) as String?,
      departmentApprovedName: json['departmentApprovedName'] as String?,
      boardApprovedName: json['boardApprovedName'] as String?,
      workflow: parseWorkflow(
        (json['workflow'] as String?) ?? 'department_only',
      ),
      workflowString: json['workflow'] as String?,
      departmentApprovedAt: parseDateNullable(deptApprovedAtStr),
      departmentApprovedId: json['departmentApprovedId'] as String?,
      boardApprovedAt: parseDateNullable(boardApprovedAtStr),
      boardApprovedId: json['boardApprovedId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'leaveType': leaveType.name,
      'reason': reason,
      'location': location,
      'status': _statusToString(status),
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'userId': userId,
      'nameApplicant': nameApplicant,
      'department': department,
      'departmentApprovedName': departmentApprovedName,
      'boardApprovedName': boardApprovedName,
      'workflow': workflowString ?? _workflowToString(workflow),
      'departmentApprovedAt': departmentApprovedAt?.toIso8601String(),
      'departmentApprovedId': departmentApprovedId,
      'boardApprovedAt': boardApprovedAt?.toIso8601String(),
      'boardApprovedId': boardApprovedId,
    };
  }

  /// Convert LeaveStatus enum to database string value
  static String _statusToString(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return 'pending';
      case LeaveStatus.departmentApproved:
        return 'department_approved';
      case LeaveStatus.approved:
        return 'approved';
      case LeaveStatus.rejected:
        return 'rejected';
      case LeaveStatus.cancelled:
        return 'cancelled';
    }
  }

  /// Convert ApprovalWorkflow enum to database string value
  static String _workflowToString(ApprovalWorkflow workflow) {
    switch (workflow) {
      case ApprovalWorkflow.departmentOnly:
        return 'department_only';
      case ApprovalWorkflow.boardOnly:
        return 'board_only';
      case ApprovalWorkflow.bothLevels:
        return 'both_levels';
    }
  }

  /// Lấy tên của user từ API
  String get userName => nameApplicant ?? '';

  /// Lấy phòng ban của user từ API
  String get userDepartment => department ?? '';

  /// Kiểm tra tính hợp lệ của đơn nghỉ phép
  bool get isValid {
    // Kiểm tra ngày bắt đầu không được trong quá khứ
    if (startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return false;
    }
    // Kiểm tra ngày kết thúc không được trước ngày bắt đầu
    if (endDate.isBefore(startDate)) {
      return false;
    }
    // Kiểm tra lý do không được rỗng
    if (reason.trim().isEmpty) {
      return false;
    }
    return true;
  }

  /// Lấy thông báo lỗi validation
  String? get validationError {
    if (startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Ngày nghỉ không được trong quá khứ';
    }
    if (endDate.isBefore(startDate)) {
      return 'Ngày kết thúc không được trước ngày bắt đầu';
    }
    if (reason.trim().isEmpty) {
      return 'Vui lòng nhập lý do nghỉ phép';
    }
    return null;
  }

  /// Kiểm tra xem user có phải là trưởng/phó phòng không
  bool get isManager {
    // Logic có thể được cập nhật khi có thêm thông tin position từ API
    return false;
  }

  /// Tính số ngày nghỉ (bao gồm cả nửa ngày)
  double get totalDays {
    final days = endDate.difference(startDate).inDays + 1;
    if (days == 1 &&
        (leaveType == LeaveType.morning || leaveType == LeaveType.afternoon)) {
      return 0.5;
    }
    return days.toDouble();
  }

  /// Kiểm tra xem đơn có cần duyệt 2 cấp không
  bool get needsTwoLevelApproval {
    return workflow == ApprovalWorkflow.bothLevels;
  }

  /// Kiểm tra xem đơn có thể được duyệt cấp tiếp theo không
  bool get canProceedToNextLevel {
    switch (workflow) {
      case ApprovalWorkflow.departmentOnly:
        // Chỉ cần duyệt phòng ban, không có cấp tiếp theo
        return false;
      case ApprovalWorkflow.boardOnly:
        // Chỉ cần duyệt BGĐ, không có cấp tiếp theo
        return false;
      case ApprovalWorkflow.bothLevels:
        // Cần duyệt 2 cấp: phòng ban -> BGĐ
        return status == LeaveStatus.departmentApproved;
    }
  }

  /// Kiểm tra xem đơn có thể được duyệt bởi cấp nào
  bool canBeApprovedBy(ApprovalLevel level) {
    switch (workflow) {
      case ApprovalWorkflow.departmentOnly:
        // Chỉ có thể duyệt cấp phòng ban
        return level == ApprovalLevel.department &&
            status == LeaveStatus.pending;
      case ApprovalWorkflow.boardOnly:
        // Chỉ có thể duyệt cấp BGĐ
        return level == ApprovalLevel.board && status == LeaveStatus.pending;
      case ApprovalWorkflow.bothLevels:
        // Cấp phòng ban: chỉ khi đang chờ
        if (level == ApprovalLevel.department) {
          return status == LeaveStatus.pending;
        }
        // Cấp BGĐ: chỉ khi đã được phòng ban duyệt
        if (level == ApprovalLevel.board) {
          return status == LeaveStatus.departmentApproved;
        }
        return false;
    }
  }

  /// Duyệt đơn theo cấp độ
  LeaveRequest approveBy(
    ApprovalLevel level,
    String approverId,
    String approverName,
  ) {
    if (!canBeApprovedBy(level)) {
      throw Exception('Không thể duyệt đơn ở trạng thái hiện tại');
    }

    switch (workflow) {
      case ApprovalWorkflow.departmentOnly:
        if (level == ApprovalLevel.department) {
          return copyWith(
            status: LeaveStatus.approved,
            approvedAt: DateTime.now(),
            departmentApprovedAt: DateTime.now(),
            departmentApprovedId: approverId,
          );
        }
        break;

      case ApprovalWorkflow.boardOnly:
        if (level == ApprovalLevel.board) {
          return copyWith(
            status: LeaveStatus.approved,
            approvedAt: DateTime.now(),
            boardApprovedAt: DateTime.now(),
            boardApprovedId: approverId,
          );
        }
        break;

      case ApprovalWorkflow.bothLevels:
        if (level == ApprovalLevel.department) {
          return copyWith(
            status: LeaveStatus.departmentApproved,
            departmentApprovedAt: DateTime.now(),
            departmentApprovedId: approverId,
          );
        } else if (level == ApprovalLevel.board) {
          return copyWith(
            status: LeaveStatus.approved,
            approvedAt: DateTime.now(),
            boardApprovedAt: DateTime.now(),
            boardApprovedId: approverId,
          );
        }
        break;
    }

    throw Exception('Không thể duyệt đơn với cấp độ này');
  }

  /// Từ chối đơn
  LeaveRequest reject(String approverId, String approverName, String reason) {
    if (status != LeaveStatus.pending &&
        status != LeaveStatus.departmentApproved) {
      throw Exception('Không thể từ chối đơn ở trạng thái hiện tại');
    }

    return copyWith(
      status: LeaveStatus.rejected,
      rejectionReason: reason,
      approvedAt: DateTime.now(),
    );
  }

  /// Xem xét lại đơn bị từ chối (quay về pending)
  LeaveRequest reconsider() {
    if (status != LeaveStatus.rejected) {
      throw Exception('Chỉ có thể xem xét lại đơn đã bị từ chối');
    }

    return copyWith(
      status: LeaveStatus.pending,
      rejectionReason: null, // Xóa lý do từ chối cũ
    );
  }

  /// Tạo bản sao với các thay đổi
  LeaveRequest copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    LeaveType? leaveType,
    String? reason,
    String? location,
    LeaveStatus? status,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? rejectionReason,
    String? userId,
    String? nameApplicant,
    String? department,
    String? departmentApprovedName,
    String? boardApprovedName,
    ApprovalWorkflow? workflow,
    String? workflowString,
    DateTime? departmentApprovedAt,
    String? departmentApprovedId,
    DateTime? boardApprovedAt,
    String? boardApprovedId,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      leaveType: leaveType ?? this.leaveType,
      reason: reason ?? this.reason,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      userId: userId ?? this.userId,
      nameApplicant: nameApplicant ?? this.nameApplicant,
      department: department ?? this.department,
      departmentApprovedName:
          departmentApprovedName ?? this.departmentApprovedName,
      boardApprovedName: boardApprovedName ?? this.boardApprovedName,
      workflow: workflow ?? this.workflow,
      workflowString: workflowString ?? this.workflowString,
      departmentApprovedAt: departmentApprovedAt ?? this.departmentApprovedAt,
      departmentApprovedId: departmentApprovedId ?? this.departmentApprovedId,
      boardApprovedAt: boardApprovedAt ?? this.boardApprovedAt,
      boardApprovedId: boardApprovedId ?? this.boardApprovedId,
    );
  }

  /// Lấy trạng thái hiển thị cho người dùng
  String get displayStatus {
    switch (status) {
      case LeaveStatus.pending:
        return 'Đang chờ duyệt';
      case LeaveStatus.departmentApproved:
        return workflow == ApprovalWorkflow.bothLevels
            ? 'Đã duyệt phòng ban, chờ BGĐ'
            : 'Đã duyệt';
      case LeaveStatus.approved:
        return 'Đã duyệt hoàn toàn';
      case LeaveStatus.rejected:
        return 'Bị từ chối';
      case LeaveStatus.cancelled:
        return 'Đã hủy';
    }
  }

  /// Tạo LeaveRequest mới với workflow tự động xác định
  factory LeaveRequest.create({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required LeaveType leaveType,
    required String reason,
    String? location,
    required bool isManager, // Người tạo có phải trưởng/phó phòng không
  }) {
    ApprovalWorkflow workflow;
    if (isManager) {
      // Trưởng/phó phòng luôn cần duyệt BGĐ (không phân biệt số ngày)
      workflow = ApprovalWorkflow.boardOnly;
    } else {
      // Nhân viên thường: 1 ngày duyệt phòng ban, 2+ ngày duyệt 2 cấp
      final days = endDate.difference(startDate).inDays + 1;
      if (days > 1) {
        workflow = ApprovalWorkflow.bothLevels;
      } else {
        workflow = ApprovalWorkflow.departmentOnly;
      }
    }

    return LeaveRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: startDate,
      endDate: endDate,
      leaveType: leaveType,
      reason: reason,
      location: location,
      status: LeaveStatus.pending,
      createdAt: DateTime.now(),
      workflow: workflow,
    );
  }
}
