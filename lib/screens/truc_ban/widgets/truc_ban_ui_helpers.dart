import 'package:flutter/material.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/models/truc_ban_enums.dart';

class TrucBanUIHelpers {
  static Color getTrangThaiColor(TrangThaiRaNgoai trangThai) {
    switch (trangThai) {
      case TrangThaiRaNgoai.choDuyet:
        return ColorConstants.warningColor;
      case TrangThaiRaNgoai.daDuyet:
        return ColorConstants.successColor;
      case TrangThaiRaNgoai.tuChoi:
        return ColorConstants.errorColor;
    }
  }

  static IconData getTrangThaiIcon(TrangThaiRaNgoai trangThai) {
    switch (trangThai) {
      case TrangThaiRaNgoai.choDuyet:
        return Icons.hourglass_empty;
      case TrangThaiRaNgoai.daDuyet:
        return Icons.check_circle;
      case TrangThaiRaNgoai.tuChoi:
        return Icons.cancel;
    }
  }

  static Color getRoleColor(NhomQuyen role, ColorScheme colorScheme) {
    switch (role) {
      case NhomQuyen.binhThuong:
        return colorScheme.onSurface.withValues(alpha: 0.45);
      case NhomQuyen.trucBan:
        return colorScheme.primary;
      case NhomQuyen.lanhDaoPhong:
        return ColorConstants.infoColor;
      case NhomQuyen.lanhDao:
        return ColorConstants.infoColor;
    }
  }

  static IconData getRoleIcon(NhomQuyen role) {
    switch (role) {
      case NhomQuyen.binhThuong:
        return Icons.person_outline;
      case NhomQuyen.trucBan:
        return Icons.security;
      case NhomQuyen.lanhDaoPhong:
        return Icons.supervisor_account;
      case NhomQuyen.lanhDao:
        return Icons.admin_panel_settings;
    }
  }

  static String getRoleDescription(NhomQuyen role) {
    switch (role) {
      case NhomQuyen.binhThuong:
        return 'Xem lịch trực, đăng ký khách, ra ngoài';
      case NhomQuyen.trucBan:
        return 'Xem khách đơn vị, camera';
      case NhomQuyen.lanhDaoPhong:
        return 'Duyệt yêu cầu ra ngoài';
      case NhomQuyen.lanhDao:
        return 'Xem khách toàn đơn vị, camera';
    }
  }
}
