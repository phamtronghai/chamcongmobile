import 'package:attendancebyface/models/leave_request.dart';
import 'package:attendancebyface/models/approver.dart';
import 'package:attendancebyface/core/services/approver_service.dart';
import 'package:attendancebyface/core/network/api_client.dart';

class LeaveRepository {
  final ApproverService _approverService = ApproverService();
  final ApiClient _apiClient = ApiClient();

  /// Lấy danh sách đơn xin nghỉ theo thời gian
  /// API không hỗ trợ lọc theo thời gian, trả về tất cả dữ liệu
  /// Lọc dữ liệu theo tháng/năm ở phía client
  Future<List<LeaveRequest>> getLeaveRequestsByTime(
    String yyyyMm,
    String userId,
  ) async {
    try {
      final parts = yyyyMm.split('-');
      final year = int.tryParse(parts.first) ?? DateTime.now().year;
      final month = int.tryParse(parts.last) ?? DateTime.now().month;

      // API không hỗ trợ query parameters, gọi API để lấy tất cả dữ liệu
      final response = await _apiClient.get('/leave/getLeaveByUser');

      final data = response.data;
      if (data is List) {
        final List<LeaveRequest> allRequests = [];

        // API trả về array trực tiếp của LeaveRequest objects
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            final request = LeaveRequest.fromJson(item);
            allRequests.add(request);
          }
        }

        // Lọc dữ liệu theo tháng/năm ở phía client
        final filteredRequests = allRequests.where((request) {
          try {
            // startDate đã là DateTime object
            return request.startDate.year == year &&
                request.startDate.month == month;
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

  /// Lấy danh sách người duyệt từ API thay vì JSON file
  Future<ApproverGroups> getApproverGroups() async {
    try {
      final approverGroups = await _approverService.getAllApprovers();
      return approverGroups;
    } catch (e) {
      rethrow;
    }
  }
}
