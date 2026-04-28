import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:attendancebyface/core/widgets/custom_button.dart';
import 'package:attendancebyface/core/app_theme.dart';
import 'package:attendancebyface/core/widgets/dialog_header.dart';

class ThemeSelectionDialog extends StatefulWidget {
  final AdaptiveThemeMode currentThemeMode;
  final Function(AdaptiveThemeMode) onThemeChanged;

  const ThemeSelectionDialog({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
  });

  @override
  State<ThemeSelectionDialog> createState() => _ThemeSelectionDialogState();
}

class _ThemeSelectionDialogState extends State<ThemeSelectionDialog>
    with SingleTickerProviderStateMixin {
  late AdaptiveThemeMode _selectedTheme;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentThemeMode;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ColorConstants.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header với gradient background
              DialogHeader(
                icon: Icons.palette_outlined,
                title: 'Chọn giao diện',
                subtitle: 'Tùy chỉnh giao diện theo sở thích',
                primaryColor: primaryColor,
              ),

              // Theme options
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildThemeOption(
                      context,
                      title: 'Giao diện sáng',
                      subtitle: 'Màu sắc tươi sáng, dễ nhìn ban ngày',
                      icon: Icons.light_mode,
                      mode: AdaptiveThemeMode.light,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildThemeOption(
                      context,
                      title: 'Giao diện tối',
                      subtitle: 'Bảo vệ mắt khi sử dụng ban đêm',
                      icon: Icons.dark_mode,
                      mode: AdaptiveThemeMode.dark,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF424242), Color(0xFF616161)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildThemeOption(
                      context,
                      title: 'Theo hệ thống',
                      subtitle: 'Tự động thay đổi theo cài đặt thiết bị',
                      icon: Icons.brightness_auto,
                      mode: AdaptiveThemeMode.system,
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.1),
                          primaryColor.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Áp dụng',
                            backgroundColor: primaryColor,
                            textColor: Colors.white,
                            onPressed: _selectedTheme != widget.currentThemeMode
                                ? () {
                                    widget.onThemeChanged(_selectedTheme);
                                    Navigator.of(context).pop();
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        CustomButton(
                          text: 'Hủy',
                          buttonType: ButtonType.circular,
                          icon: Icons.close,
                          tooltip: 'Hủy',
                          width: 48,
                          height: 48,
                          backgroundColor: primaryColor,
                          textColor: primaryColor,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required AdaptiveThemeMode mode,
    required Gradient gradient,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedTheme == mode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTheme = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: ColorConstants.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.9)
                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    ColorConstants.defaultBorderRadius,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? (mode == AdaptiveThemeMode.dark
                                  ? Colors.white
                                  : theme.colorScheme.primary)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? (mode == AdaptiveThemeMode.dark
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : theme.colorScheme.primary.withValues(
                                      alpha: 0.7,
                                    ))
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
