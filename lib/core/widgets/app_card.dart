import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool hasBorder;
  final bool elevated;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.hasBorder = true,
    this.elevated = true,
    this.radius = AppSizes.radiusXl,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final decoration = BoxDecoration(
      color: backgroundColor ?? (isDark ? AppColors.cardDark : AppColors.cardLight),
      borderRadius: BorderRadius.circular(radius),
      border: hasBorder
          ? Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        width: 1,
      )
          : null,
      boxShadow: elevated && !isDark
          ? [
        BoxShadow(
          color: Colors.black.withOpacity(0.045),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ]
          : [],
    );

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSizes.cardPadding),
      decoration: decoration,
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}
