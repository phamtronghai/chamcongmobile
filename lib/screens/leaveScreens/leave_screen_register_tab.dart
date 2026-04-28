import 'dart:async';
import 'package:attendancebyface/models/leave_request.dart';
import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/repositories/leave_repository.dart';
import 'package:attendancebyface/models/approver.dart';
import 'package:attendancebyface/screens/leaveScreens/leave_create_screen.dart';
import 'package:attendancebyface/core/widgets/custom_dropdown.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/widgets/leave_request_tile.dart';
import 'package:attendancebyface/widgets/leave_request_detail_sheet.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';

class LeaveScreenRegisterTab extends StatelessWidget {
  const LeaveScreenRegisterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (user) => _LeaveScreenRegisterTabContent(user: user),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi khi tải dữ liệu'),
                const SizedBox(height: 8),
                Text(message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<UserCubit>().refresh(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LeaveScreenRegisterTabContent extends StatefulWidget {
  final UserModel user;

  const _LeaveScreenRegisterTabContent({required this.user});

  @override
  State<_LeaveScreenRegisterTabContent> createState() =>
      _LeaveScreenRegisterTabState();
}

class _LeaveScreenRegisterTabState
    extends State<_LeaveScreenRegisterTabContent> {
  final _repo = LeaveRepository();
  bool _isLoading = true;
  List<LeaveRequest> _requests = [];
  ApproverGroups? _approverGroups;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _loadApprovers(); // Load approvers một lần
    _loadData(); // Load data theo tháng/năm
  }

  /// Load danh sách người duyệt một lần duy nhất
  Future<void> _loadApprovers() async {
    try {
      _approverGroups = await _repo.getApproverGroups();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Load danh sách đơn xin nghỉ theo tháng/năm
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Chỉ load danh sách đơn xin nghỉ
      final list = await _repo.getLeaveRequestsByTime(
        '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}',
        widget.user.id,
      );

      // Gán trực tiếp từ API, không cần filter thêm
      _requests = list;

      // debugPrint(
      //   '[LeaveRegisterTab] Loaded ${_requests.length} requests from API',
      // );
      // debugPrint(
      //   '[LeaveRegisterTab] Selected time: $_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}',
      // );

      // Debug: In ra chi tiết từng request
      // for (int i = 0; i < _requests.length; i++) {
      //   final req = _requests[i];
      //   debugPrint(
      //     '[LeaveRegisterTab] Request $i: ${req.id} - ${req.startDate} - ${req.userName} - ${req.status}',
      //   );
      // }

      if (mounted) setState(() {});
    } catch (e) {
      // debugPrint('[LeaveRegisterTab] Lỗi khi tải dữ liệu: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomDropdown<int>(
                  labelText: 'Tháng',
                  value: _selectedMonth,
                  items: List.generate(12, (i) => i + 1)
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text('Tháng ${m.toString().padLeft(2, '0')}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) async {
                    if (v == null) return;
                    setState(() => _selectedMonth = v);
                    await _loadData();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomDropdown<int>(
                  labelText: 'Năm',
                  value: _selectedYear,
                  items: List.generate(5, (i) => DateTime.now().year - 2 + i)
                      .map(
                        (y) =>
                            DropdownMenuItem(value: y, child: Text('Năm $y')),
                      )
                      .toList(),
                  onChanged: (v) async {
                    if (v == null) return;
                    setState(() => _selectedYear = v);
                    await _loadData();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Đăng ký nghỉ phép',
            icon: Icons.add_circle,
            onPressed: () async {
              // Đảm bảo có approverGroups trước khi điều hướng
              if (_approverGroups == null) {
                setState(() => _isLoading = true);
                await _loadApprovers(); // Sử dụng method đã tách riêng
                if (mounted) setState(() => _isLoading = false);
                
                // Nếu vẫn không có approvers sau khi load, return
                if (_approverGroups == null) {
                  return;
                }
              }

              // debugPrint('[LeaveRegisterTab] Navigating to LeaveCreateScreen');
              if (!mounted) return;
              final req = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      LeaveCreateScreen(approverGroups: _approverGroups!),
                ),
              );
              if (req is LeaveRequest && mounted) {
                // Reload data từ API để đảm bảo dữ liệu mới nhất
                await _loadData();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_note_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có đơn nghỉ trong tháng',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tháng $_selectedMonth/$_selectedYear',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length + 1,
        itemBuilder: (context, index) {
          // Header "Danh sách"
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Danh sách',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            );
          }

          final item = _requests[index - 1];
          return LeaveRequestTile(
            item: item,
            applicantName: item.userName.isNotEmpty
                ? item.userName
                : widget.user.name,
            applicantDepartment: item.userDepartment.isNotEmpty
                ? item.userDepartment
                : widget.user.department,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => LeaveRequestDetailSheet(
                  request: item,
                  onApprove: (req) {},
                  onReject: (req, reason) {},
                  onCancel: (updated) async {
                    // Reload data từ API để đảm bảo dữ liệu mới nhất
                    await _loadData();
                  },
                  showActions: false,
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug build state
    // debugPrint(
    //   '[LeaveRegisterTab] Build: isLoading=$_isLoading, requests=${_requests.length}',
    // );

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (_requests.isEmpty ? _buildEmpty() : _buildList()),
        ),
      ],
    );
  }
}
