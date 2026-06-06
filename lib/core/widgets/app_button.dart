import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

enum ButtonType { primary, secondary, outline, ghost, text, danger }
enum AppButtonType { primary, secondary, outline, ghost, text, danger }
enum AppButtonVariant { primary, secondary, outline, ghost, text, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Object? type;
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
    final raw = variant ?? type;
    if (raw is ButtonType) return raw;
    if (raw is AppButtonType) return ButtonType.values[raw.index];
    if (raw is AppButtonVariant) return ButtonType.values[raw.index];
    return ButtonType.primary;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedType = _resolvedType;
    final disabled = onPressed == null || isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final foreground = switch (resolvedType) {
      ButtonType.primary => Colors.white,
      ButtonType.danger => Colors.white,
      ButtonType.secondary => isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ButtonType.outline => isDark ? AppColors.primaryLightTeal : AppColors.primaryTeal,
      ButtonType.ghost => isDark ? AppColors.primaryLightTeal : AppColors.primaryTeal,
      ButtonType.text => isDark ? AppColors.primaryLightTeal : AppColors.primaryTeal,
    };

    final background = switch (resolvedType) {
      ButtonType.primary => AppColors.primaryTeal,
      ButtonType.danger => AppColors.danger,
      ButtonType.secondary => isDark ? AppColors.cardDark : Colors.white,
      ButtonType.outline => Colors.transparent,
      ButtonType.ghost => (isDark ? AppColors.primaryLightTeal : AppColors.primaryTeal).withOpacity(0.10),
      ButtonType.text => Colors.transparent,
    };

    final borderSide = switch (resolvedType) {
      ButtonType.outline || ButtonType.secondary => BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.2),
      _ => BorderSide.none,
    };

    final content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(width: 19, height: 19, child: CircularProgressIndicator(strokeWidth: 2.2, color: foreground)),
          const SizedBox(width: AppSizes.sm),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: AppSizes.sm),
        ],
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.1),
          ),
        ),
        if (!isLoading && trailingIcon != null) ...[
          const SizedBox(width: AppSizes.sm),
          Icon(trailingIcon, size: 18),
        ],
      ],
    );

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        gradient: resolvedType == ButtonType.primary && !disabled ? AppColors.tealGradient : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: resolvedType == ButtonType.primary && !disabled
            ? [BoxShadow(color: AppColors.primaryTeal.withOpacity(0.24), blurRadius: 18, offset: const Offset(0, 10))]
            : [],
      ),
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: resolvedType == ButtonType.primary ? Colors.transparent : background,
          disabledBackgroundColor: background.withOpacity(0.55),
          foregroundColor: foreground,
          disabledForegroundColor: foreground.withOpacity(0.55),
          minimumSize: Size(isFullWidth ? double.infinity : 0, minHeight ?? AppSizes.defaultButtonHeight),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), side: borderSide),
        ),
        child: content,
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
