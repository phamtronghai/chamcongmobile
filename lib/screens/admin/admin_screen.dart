import 'package:attendancebyface/core/app_router.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/services/admin_service.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/core/widgets/error_widget.dart';
import 'package:attendancebyface/models/admin_org_models.dart';
import 'package:attendancebyface/screens/admin/admin_department_employees_screen.dart';
import 'package:attendancebyface/screens/admin/admin_employee_sheet.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tab Quản trị: danh sách phòng ban + AvatarStack nhân viên.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminService _service = AdminService();

  List<AdminDepartment> _departments = const [];
  bool _loading = true;
  String? _error;

  /// Cache employees theo slug; null = chưa load.
  final Map<String, List<AdminEmployee>?> _employeesBySlug = {};
  final Set<String> _loadingSlugs = {};
  final Set<String> _errorSlugs = {};

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.fetchDepartments();
      if (!mounted) return;
      setState(() {
        _departments = list;
        _loading = false;
        _employeesBySlug.clear();
        _loadingSlugs.clear();
        _errorSlugs.clear();
      });
      // Prefetch song song có giới hạn
      _prefetchEmployees(list);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      });
    }
  }

  Future<void> _prefetchEmployees(List<AdminDepartment> depts) async {
    const concurrency = 3;
    for (var i = 0; i < depts.length; i += concurrency) {
      final batch = depts.skip(i).take(concurrency);
      await Future.wait(batch.map((d) => _loadEmployees(d.slug)));
      if (!mounted) return;
    }
  }

  Future<void> _loadEmployees(String slug) async {
    if (_employeesBySlug.containsKey(slug) || _loadingSlugs.contains(slug)) {
      return;
    }
    setState(() {
      _loadingSlugs.add(slug);
      _errorSlugs.remove(slug);
    });
    try {
      final list = await _service.fetchEmployees(slug);
      if (!mounted) return;
      setState(() {
        _employeesBySlug[slug] = list;
        _loadingSlugs.remove(slug);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingSlugs.remove(slug);
        _errorSlugs.add(slug);
        _employeesBySlug[slug] = null;
      });
    }
  }

  void _openEmployee(AdminEmployee employee) {
    AdminEmployeeSheet.show(
      context,
      employee,
      imageUrl: _service.toAbsoluteUrl(employee.image),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quản trị',
        showAvatar: true,
        onNotificationTap: () {
          final user = context.read<UserCubit>().currentUser;
          if (user != null) {
            AppRouter.goToNotification(context, user);
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _loadDepartments);
    }
    if (_departments.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadDepartments,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            BaseEmptyState(
              icon: Icons.apartment_outlined,
              title: 'Chưa có phòng ban',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDepartments,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        itemCount: _departments.length,
        itemBuilder: (context, index) {
          final dept = _departments[index];
          return _DepartmentSection(
            department: dept,
            employees: _employeesBySlug[dept.slug],
            isLoading: _loadingSlugs.contains(dept.slug),
            hasError: _errorSlugs.contains(dept.slug),
            absoluteUrl: _service.toAbsoluteUrl,
            onRetry: () {
              _employeesBySlug.remove(dept.slug);
              _loadEmployees(dept.slug);
            },
            onEmployeeTap: _openEmployee,
          );
        },
      ),
    );
  }
}

class _DepartmentSection extends StatelessWidget {
  final AdminDepartment department;
  final List<AdminEmployee>? employees;
  final bool isLoading;
  final bool hasError;
  final String Function(String?) absoluteUrl;
  final VoidCallback onRetry;
  final void Function(AdminEmployee) onEmployeeTap;

  const _DepartmentSection({
    required this.department,
    required this.employees,
    required this.isLoading,
    required this.hasError,
    required this.absoluteUrl,
    required this.onRetry,
    required this.onEmployeeTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            department.department,
            style: TextConstants.appTextBold.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          _buildAvatars(context),
        ],
      ),
    );
  }

  Widget _buildAvatars(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading || employees == null && !hasError) {
      return const SizedBox(
        height: 52,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (hasError) {
      return SizedBox(
        height: 52,
        child: Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Tải lại'),
          ),
        ),
      );
    }

    final list = employees ?? const <AdminEmployee>[];
    if (list.isEmpty) {
      return const BaseEmptyState(
        icon: Icons.people_outline,
        title: 'Chưa có nhân viên',
      );
    }

    final border = BorderSide(color: colorScheme.surface, width: 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          width: double.infinity,
          child: WidgetStack(
            positions:
                RestrictedPositions(maxCoverage: 0.35, minCoverage: 0.12),
            buildInfoWidget: (surplus, ctx) => BorderedCircleAvatar(
              border: border,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '+$surplus',
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
            stackedWidgets: [
              for (final emp in list)
                Builder(
                  builder: (ctx) {
                    final image = _avatarImage(emp);
                    return GestureDetector(
                      onTap: () => onEmployeeTap(emp),
                      child: BorderedCircleAvatar(
                        border: border,
                        backgroundImage: image,
                        backgroundColor:
                            image == null ? colorScheme.primary : null,
                        child: image == null
                            ? Text(
                                _initials(emp.name),
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AdminDepartmentEmployeesScreen(
                    departmentName: department.department,
                    employees: list,
                    absoluteUrl: absoluteUrl,
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Xem tất cả',
                  style: TextConstants.appTextSemiBold.copyWith(
                    fontSize: 13,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? _avatarImage(AdminEmployee emp) {
    final url = absoluteUrl(emp.image);
    if (url.isEmpty) return null;
    return NetworkImage(url);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
