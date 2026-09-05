import 'package:attendancebyface/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/screens/admin/admin_screen.dart';
import 'package:attendancebyface/screens/attendance/attendance_screen.dart';
import 'package:attendancebyface/screens/leave/leave_screen.dart';
import 'package:attendancebyface/screens/truc_ban/truc_ban_screen.dart';
import 'package:attendancebyface/core/cubits/user_cubit.dart';
import 'package:attendancebyface/core/cubits/user_state.dart';
import 'package:attendancebyface/core/widgets/loading_overlay.dart';
import 'package:attendancebyface/core/widgets/error_widget.dart';
import 'package:liquid_glass_navbar/liquid_glass_navbar.dart';
import 'package:attendancebyface/core/app_theme.dart';

/// Padding ngang của FAB và bottom nav.
const double kNavBarHorizontalPadding = 16;

/// Chiều cao pill FAB filled.
const double kFabFilledPillHeight = ButtonConstants.heightButton;

/// Chiều rộng mỗi item trong navbar để navbar luôn ôm sát nội dung (fit-content).
const double kNavItemWidth = 96.0;

List<LiquidGlassNavItem> _navItemsFor(UserModel user) {
  final items = <LiquidGlassNavItem>[
    const LiquidGlassNavItem(
      icon: Icons.event_note_outlined,
      label: 'Nghỉ phép',
    ),
    const LiquidGlassNavItem(icon: Icons.timer, label: 'Chấm công'),
    const LiquidGlassNavItem(icon: Icons.security_outlined, label: 'Trực ban'),
  ];
  if (user.role == 'admin') {
    items.add(
      const LiquidGlassNavItem(icon: Icons.manage_accounts, label: 'Quản trị'),
    );
  }
  return items;
}

class CustomNavBar extends StatefulWidget {
  final UserModel user;
  final int? initialIndex;

  const CustomNavBar({super.key, required this.user, this.initialIndex});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  static const int _defaultPageIndex = 1;

  late final PageController _pageController;
  late int _currentIndex;
  late final List<Widget?> _screens;
  late final List<LiquidGlassNavItem> _navItems;

  int get _screenCount => _navItems.length;

  @override
  void initState() {
    super.initState();

    _navItems = _navItemsFor(widget.user);

    int initialIndex = widget.initialIndex ?? _defaultPageIndex;
    if (initialIndex >= _screenCount) {
      initialIndex = _defaultPageIndex;
    }

    _currentIndex = initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _screens = List<Widget?>.filled(_screenCount, null);
    _ensureScreen(_currentIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userCubit = context.read<UserCubit>();
      userCubit.loadUserDataFromUser(widget.user);
    });
  }

  void _ensureScreen(int index) {
    switch (index) {
      case 0:
        _screens[0] ??= const LeaveScreen();
      case 1:
        _screens[1] ??= const AttendanceScreen();
      case 2:
        _screens[2] = TrucBanScreen(isActive: _currentIndex == 2);
      case 3:
        if (_screenCount > 3) {
          _screens[3] ??= const AdminScreen();
        }
    }
  }

  void _onTabTap(int index) {
    setState(() {
      _currentIndex = index;
      _ensureScreen(index);
      if (_screens.length > 2 && _screens[2] != null) {
        _screens[2] = TrucBanScreen(isActive: index == 2);
      }
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  List<Widget> _pageChildren() {
    return List<Widget>.generate(_screenCount, (index) {
      return _screens[index] ?? const SizedBox.shrink();
    });
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
            final double navBarBottomPad =
                (MediaQuery.viewPaddingOf(context).bottom - 20).clamp(
                  0.0,
                  double.infinity,
                );
            final double navTotalHeight = 65 + navBarBottomPad + 32;
            return Scaffold(
              resizeToAvoidBottomInset: false,
              body: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: MediaQuery.of(
                    context,
                  ).padding.copyWith(bottom: navTotalHeight),
                ),
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _pageChildren(),
                ),
              ),
              extendBody: true,
              bottomNavigationBar: Padding(
                padding: EdgeInsets.fromLTRB(
                  kNavBarHorizontalPadding,
                  0,
                  kNavBarHorizontalPadding,
                  navBarBottomPad,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: _navItems.length * kNavItemWidth,
                    child: LiquidBottomNavBar(
                      height: 65,
                      bubbleWidth: kNavItemWidth,
                      currentIndex: _currentIndex,
                      onTap: _onTabTap,
                      items: _navItems,
                      backgroundColor: colorScheme.surface,
                      itemColor: colorScheme.onSurfaceVariant,
                      bubbleColor: colorScheme.primary,
                      backgroundOpacity: 0.18,
                      bubbleOpacity: 0.28,
                      blurStrength: 12,
                      borderRadius: ColorConstants.defaultBorderRadius,
                      iconSize: 20,
                      fontSize: 12,
                      elevation: 14,
                      bottomPadding: 0,
                      horizontalPadding: 0,
                    ),
                  ),
                ),
              ),
            );
          },
          error: (message) => Scaffold(body: AppErrorWidget(message: message)),
        );
      },
    );
  }
}
