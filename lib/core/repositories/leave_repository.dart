import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendancebyface/models/leave_request.dart';
import 'package:attendancebyface/models/approver.dart';
import 'package:attendancebyface/core/services/approver_service.dart';
import 'package:attendancebyface/core/network/api_client.dart';

class LeaveRepository {
  final ApproverService _approverService = ApproverService();
  final ApiClient _apiClient = ApiClient();

  static final DateFormat _apiDateFmt = DateFormat('yyyy-MM-dd');

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _statusToApi(LeaveStatus status) {
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

  /// Lấy danh sách đơn xin nghỉ theo khoảng ngày (lọc client).
  /// API không hỗ trợ query thời gian — gọi `/leave/getLeaveByUser` rồi giữ đơn có
  /// `startDate` (phần ngày) nằm trong [range] (biên inclusive).
  Future<List<LeaveRequest>> getLeaveRequestsInRange(
    DateTimeRange range,
    String _,
  ) async {
    try {
      final start = _dateOnly(range.start);
      final end = _dateOnly(range.end);

      final response = await _apiClient.get('/leave/getLeaveByUser');

      final data = response.data;
      if (data is List) {
        final List<LeaveRequest> allRequests = [];

        for (final item in data) {
          if (item is Map<String, dynamic>) {
            final request = LeaveRequest.fromJson(item);
            allRequests.add(request);
          }
        }

        final filteredRequests = allRequests.where((request) {
          try {
            final sd = _dateOnly(request.startDate);
            return !sd.isBefore(start) && !sd.isAfter(end);
          } catch (e) {
            return false;
          }
        }).toList();

        return filteredRequests;
      }

      return [];
    } catch (error) {
      rethrow;
    }
  }

  /// Lấy lịch sử đơn nghỉ phép toàn công ty (Ban giám đốc).
  Future<List<LeaveRequest>> getBoardLeaveHistory({
    required DateTime startDate,
    required DateTime endDate,
    LeaveStatus? status,
  }) async {
    final query = <String, dynamic>{
      'startDate': _apiDateFmt.format(_dateOnly(startDate)),
      'endDate': _apiDateFmt.format(_dateOnly(endDate)),
    };
    if (status != null) {
      query['status'] = _statusToApi(status);
    }

    final response = await _apiClient.get(
      '/leave/boardGetListLeaveHistory',
      queryParameters: query,
    );

    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(LeaveRequest.fromJson)
          .toList();
    }
    return [];
  }

  /// Lấy danh sách người duyệt từ API thay vì JSON file
  Future<ApproverGroups> getApproverGroups() async {
    final approverGroups = await _approverService.getAllApprovers();
    return approverGroups;
  }
}
