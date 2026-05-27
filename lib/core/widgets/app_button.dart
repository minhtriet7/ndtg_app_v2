import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

enum ButtonType { primary, secondary, outline, ghost, text, danger }

// Compatibility enum for files that call AppButton(type: AppButtonType.outline)
enum AppButtonType { primary, secondary, outline, ghost, text, danger }

// Compatibility enum for files that call AppButton(variant: AppButtonVariant.outline)
enum AppButtonVariant { primary, secondary, outline, ghost, text, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  /// Accepts ButtonType, AppButtonType, or AppButtonVariant.
  final Object? type;

  /// Accepts ButtonType, AppButtonType, or AppButtonVariant.
  final Object? variant;

  final bool isLoading;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isFullWidth;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type,
    this.variant,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.isFullWidth = true,
    this.minHeight,
    this.padding,
  });

  ButtonType get _resolvedType {
    final Object? raw = variant ?? type;

    if (raw is ButtonType) return raw;

    if (raw is AppButtonType) {
      switch (raw) {
        case AppButtonType.primary:
          return ButtonType.primary;
        case AppButtonType.secondary:
          return ButtonType.secondary;
        case AppButtonType.outline:
          return ButtonType.outline;
        case AppButtonType.ghost:
          return ButtonType.ghost;
        case AppButtonType.text:
          return ButtonType.text;
        case AppButtonType.danger:
          return ButtonType.danger;
      }
    }

    if (raw is AppButtonVariant) {
      switch (raw) {
        case AppButtonVariant.primary:
          return ButtonType.primary;
        case AppButtonVariant.secondary:
          return ButtonType.secondary;
        case AppButtonVariant.outline:
          return ButtonType.outline;
        case AppButtonVariant.ghost:
          return ButtonType.ghost;
        case AppButtonVariant.text:
          return ButtonType.text;
        case AppButtonVariant.danger:
          return ButtonType.danger;
      }
    }

    return ButtonType.primary;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedType = _resolvedType;
    final bool disabled = onPressed == null || isLoading;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color foreground = switch (resolvedType) {
      ButtonType.primary => Colors.white,
      ButtonType.danger => Colors.white,
      ButtonType.secondary => isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ButtonType.outline => AppColors.primaryTeal,
      ButtonType.ghost => AppColors.primaryTeal,
      ButtonType.text => AppColors.primaryTeal,
    };

    final Color background = switch (resolvedType) {
      ButtonType.primary => AppColors.primaryTeal,
      ButtonType.danger => AppColors.danger,
      ButtonType.secondary => isDark ? AppColors.borderDark : AppColors.borderLight,
      ButtonType.outline => Colors.transparent,
      ButtonType.ghost => AppColors.primaryTeal.withOpacity(0.08),
      ButtonType.text => Colors.transparent,
    };

    final BorderSide borderSide = switch (resolvedType) {
      ButtonType.outline => const BorderSide(
        color: AppColors.primaryTeal,
        width: 1.3,
      ),
      _ => BorderSide.none,
    };

    final Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 19,
            height: 19,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: foreground,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
        ] else if (icon != null) ...[
          Icon(icon, size: 19),
          const SizedBox(width: AppSizes.sm),
        ],
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),
        ),
        if (!isLoading && trailingIcon != null) ...[
          const SizedBox(width: AppSizes.sm),
          Icon(trailingIcon, size: 18),
        ],
      ],
    );

    final Widget button = ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: background,
        disabledBackgroundColor: background.withOpacity(0.55),
        foregroundColor: foreground,
        disabledForegroundColor: foreground.withOpacity(0.55),
        minimumSize: Size(
          isFullWidth ? double.infinity : 0,
          minHeight ?? AppSizes.defaultButtonHeight,
        ),
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.sm,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          side: borderSide,
        ),
      ),
      child: content,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
