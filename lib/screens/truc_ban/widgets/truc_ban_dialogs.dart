import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';
import 'package:attendancebyface/core/widgets/samcom_sheet.dart';
import 'package:attendancebyface/core/app_theme.dart';

class TrucBanDialogs {
  static void showBottomSheet<T extends Cubit>({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    Color? primaryColor,
    T? blocValue,
  }) {
    SamcomSheet.show(
      context: context,
      builder: (dialogContext) {
        Widget content = SamcomSheet(
          title: title,
          subtitle: subtitle,
          icon: icon,
          primaryColor: primaryColor,
          expandChild: true,
          child: child,
        );

        if (blocValue != null) {
          content = BlocProvider<T>.value(value: blocValue, child: content);
        }

        return content;
      },
    );
  }

  static Future<void> showCustomDialog<T extends Cubit>({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget content,
    List<Widget>? actions,
    Color? primaryColor,
    T? blocValue,
  }) async {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        Widget dialogContent = Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ColorConstants.defaultBorderRadius),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogHeader(
                  icon: icon,
                  title: title,
                  subtitle: subtitle,
                  primaryColor: primaryColor,
                ),
                Padding(padding: const EdgeInsets.all(24), child: content),
                if (actions != null) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );

        if (blocValue != null) {
          dialogContent = BlocProvider<T>.value(
            value: blocValue,
            child: dialogContent,
          );
        }

        return dialogContent;
      },
    );
  }
}
