import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/base_empty_state.dart';
import 'package:attendancebyface/core/widgets/custom_app_bar.dart';
import 'package:attendancebyface/models/admin_org_models.dart';
import 'package:attendancebyface/screens/admin/admin_employee_sheet.dart';
import 'package:flutter/material.dart';

/// Grid toàn bộ nhân viên của một phòng ban.
class AdminDepartmentEmployeesScreen extends StatelessWidget {
  final String departmentName;
  final List<AdminEmployee> employees;
  final String Function(String?) absoluteUrl;

  const AdminDepartmentEmployeesScreen({
    super.key,
    required this.departmentName,
    required this.employees,
    required this.absoluteUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: departmentName),
      body: SafeArea(
        child: employees.isEmpty
            ? const BaseEmptyState(
                icon: Icons.people_outline,
                title: 'Chưa có nhân viên',
              )
            : GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  MediaQuery.paddingOf(context).bottom + 24,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final emp = employees[index];
                  return _EmployeeGridTile(
                    employee: emp,
                    imageUrl: absoluteUrl(emp.image),
                    onTap: () => AdminEmployeeSheet.show(
                      context,
                      emp,
                      imageUrl: absoluteUrl(emp.image),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EmployeeGridTile extends StatelessWidget {
  final AdminEmployee employee;
  final String imageUrl;
  final VoidCallback onTap;

  const _EmployeeGridTile({
    required this.employee,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = imageUrl.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
              child: hasImage
                  ? null
                  : Text(
                      _initials(employee.name),
                      style: TextConstants.appTextSemiBold.copyWith(
                        color: colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                employee.name.isEmpty ? '—' : employee.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextConstants.appTextMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
