import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        Widget content = Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              DialogHeader(
                icon: icon,
                title: title,
                subtitle: subtitle,
                primaryColor: primaryColor,
              ),
              // Content
              Expanded(child: child),
            ],
          ),
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
            borderRadius: BorderRadius.circular(24),
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
