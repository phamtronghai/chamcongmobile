import 'package:flutter/material.dart';

/// Khớp [LiquidBottomNavBar.height] mặc định trong package `liquid_glass_navbar`.
/// Khi đổi `height:` của [LiquidBottomNavBar] trong [CustomNavBar], cập nhật giá trị này cho khớp.
const double kLiquidBottomNavBarHeight = 65;

/// Khoảng hở giữa **cạnh trên thanh bottom nav** và **đáy FAB** — chỉnh nhỏ hơn để FAB sát nav hơn.
const double kFabBottomGap = 32;

/// Khớp padding đái bọc nav trong [CustomNavBar] (`floatingBottomInset`).
const double kNavBarFloatingBottomInset = -20;

/// Padding ngang của vùng chứa bottom nav / căn FAB trong shell ([CustomNavBar]).
const double kNavBarHorizontalPadding = 16;

/// Chiều cao pill FAB filled ([CustomButton] `minimumSize` mặc định ~56).
const double kFabFilledPillHeight = 56;

/// Khoảng cách từ **cạnh dưới vùng body** (Stack chứa FAB) tới **đáy** widget FAB:
/// padding đái chừa nav + chiều cao nav + [kFabBottomGap] (`extendBody` + [CustomNavBar]).
double fabStackBottomFromScreenBottom(BuildContext context) {
  // Dùng viewPadding: SafeArea(bottom: false) có thể zero hóa padding.bottom nhưng nav shell
  // vẫn căn theo vùng an toàn thật — nếu chỉ dùng padding, offset FAB lệch / khoảng trống sai.
  final bottomSafe = MediaQuery.viewPaddingOf(context).bottom;
  final navBottomPadding = (bottomSafe + kNavBarFloatingBottomInset).clamp(
    0.0,
    double.infinity,
  );
  return navBottomPadding + kLiquidBottomNavBarHeight + kFabBottomGap;
}
