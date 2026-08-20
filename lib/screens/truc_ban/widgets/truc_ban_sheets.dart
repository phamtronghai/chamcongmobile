import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';

class TrucBanSheets {
  static Future<void> showSheet<T extends Cubit>({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget content,
    Color? primaryColor,
    T? blocValue,
  }) {
    return SamcomSheet.show(
      context: context,
      builder: (sheetContext) {
        Widget sheet = SamcomSheet(
          title: title,
          subtitle: subtitle,
          icon: icon,
          primaryColor: primaryColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: content,
          ),
        );

        if (blocValue != null) {
          sheet = BlocProvider<T>.value(value: blocValue, child: sheet);
        }

        return sheet;
      },
    );
  }
}
