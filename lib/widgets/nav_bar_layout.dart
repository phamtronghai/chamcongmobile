import 'package:flutter/material.dart';

/// Khớp [LiquidBottomNavBar.height] mặc định trong package `liquid_glass_navbar`.
/// Khi đổi `height:` của [LiquidBottomNavBar] trong [CustomNavBar], cập nhật giá trị này cho khớp.
const double kLiquidBottomNavBarHeight = 65;

/// Khoảng hở FAB theo từng màn (tính theo safe-area đáy).
/// - Leave / Attendance: 1x padding đáy.
/// - Trực ban: 2x padding đáy.

/// Padding ngang của vù chứa bottom nav trong shell ([CustomNavBar]).
const double kNavBarHorizontalPadding = 16;

/// Dùng cho Leave: cách đáy 1x safe-area bottom.
double leaveFabBottomInSafeArea(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom + 8;

/// Dùng khi [Stack]/[Positioned] căn theo **đáy màn hình** (không bọc [SafeArea] đáy).
double attendanceFabBottomFromScreenBottom(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom + 8;

/// Dùng cho cụm FAB Trực ban, đặt cao hơn để không che section "Mở cửa".
double trucBanFabBottomFromScreenBottom(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom * 2;
