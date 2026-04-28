import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/screens/attendance_screen.dart';
import 'package:attendancebyface/screens/settings_screen.dart';
import 'package:attendancebyface/screens/leaveScreens/leave_screen.dart';
import 'package:attendancebyface/screens/trucBan/truc_ban_screen.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';

class CustomNavBar extends StatefulWidget {
  final UserModel user;
  final int? initialIndex;

  const CustomNavBar({super.key, required this.user, this.initialIndex});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  // Constants
  static const int _defaultPageIndex = 1;

  /// Controller to handle PageView
  late final PageController _pageController;

  /// Current selected index
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    // Số screens hiện tại
    const int screenCount = 4;
    
    // Đảm bảo initialIndex trong khoảng hợp lệ (0 đến screenCount-1)
    int initialIndex = widget.initialIndex ?? _defaultPageIndex;
    if (initialIndex >= screenCount) {
      initialIndex = _defaultPageIndex;
    }
    
    _currentIndex = initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Load user data vào Cubit khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userCubit = context.read<UserCubit>();
      userCubit.loadUserDataFromUser(widget.user);
    });
  }

  /// Tạo danh sách screens
  List<Widget> _buildScreens() {
    return [
      const LeaveScreen(),
      const AttendanceScreen(),
      TrucBanScreen(isActive: _currentIndex == 2),
      const SettingsScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return state.when(
          initial: () => const LoadingOverlay(
            isLoading: true,
            child: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
          loading: () => const LoadingOverlay(
            isLoading: true,
            child: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
          loaded: (user) {
            final screens = _buildScreens();
            return Scaffold(
              body: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: screens,
              ),
              extendBody: true,
              bottomNavigationBar: CircleNavBar(
                activeIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                padding: const EdgeInsets.all(16),
                cornerRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
                elevation: 10,
                color: colorScheme.surface,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    colorScheme.surfaceContainer,
                    colorScheme.surfaceContainerHighest,
                  ],
                ),
                circleGradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                activeIcons: [
                  Icon(Icons.event_note_rounded, color: colorScheme.onPrimary),
                  Container(
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: Image.asset(
                      'assets/images/logoToNCPTKHCN.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Icon(Icons.security, color: colorScheme.onPrimary),
                  Icon(Icons.settings, color: colorScheme.onPrimary),
                ],
                inactiveIcons: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nghỉ phép',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chấm công',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.security_outlined,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Trực ban',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cài đặt',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          error: (message) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi khi tải dữ liệu',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserCubit>().refresh();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
