import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/screens/attendance/attendance_screen.dart';
import 'package:attendancebyface/screens/personal_info_screen.dart';
import 'package:attendancebyface/screens/leaveScreens/leave_screen.dart';
import 'package:attendancebyface/screens/trucBan/truc_ban_screen.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:liquid_glass_navbar/liquid_glass_navbar.dart';
import 'package:attendancebyface/widgets/nav_bar_layout.dart';

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
      const PersonalInfoScreen(),
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
          loaded: (_) {
            final screens = _buildScreens();
            const double floatingBottomInset = -20;
            const double floatingHorizontalInset = 16;
            final bottomSafe = MediaQuery.of(context).padding.bottom;
            return Scaffold(
              body: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: screens,
              ),
              extendBody: true,
              bottomNavigationBar: Padding(
                padding: EdgeInsets.fromLTRB(
                  floatingHorizontalInset,
                  0,
                  floatingHorizontalInset,
                  bottomSafe + floatingBottomInset,
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    LiquidBottomNavBar(
                      height: kLiquidBottomNavBarHeight,
                      currentIndex: _currentIndex,
                      onTap: (index) {
                        setState(() => _currentIndex = index);
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      items: const [
                        LiquidGlassNavItem(
                          icon: Icons.event_note_outlined,
                          label: 'Nghỉ phép',
                        ),
                        LiquidGlassNavItem(
                          icon: Icons.timer,
                          label: 'Chấm công',
                        ),
                        LiquidGlassNavItem(
                          icon: Icons.security_outlined,
                          label: 'Trực ban',
                        ),
                        LiquidGlassNavItem(
                          icon: Icons.person_outline,
                          label: 'Cá nhân',
                        ),
                      ],
                      backgroundColor: colorScheme.surface,
                      itemColor: colorScheme.onSurfaceVariant,
                      bubbleColor: colorScheme.primary,
                      backgroundOpacity: 0.18,
                      bubbleOpacity: 0.28,
                      blurStrength: 12,
                      borderRadius: 36,
                      iconSize: 20,
                      fontSize: 10,
                      elevation: 14,
                      bottomPadding: 0,
                      horizontalPadding: 0,
                    ),
                  ],
                ),
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
                  CustomButton(
                    text: 'Thử lại',
                    width: 140,
                    onPressed: () {
                      context.read<UserCubit>().refresh();
                    },
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
