import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppCard extends StatefulWidget {
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
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final decoration = BoxDecoration(
      color: widget.backgroundColor ?? (isDark ? AppColors.cardDark : AppColors.cardLight),
      borderRadius: BorderRadius.circular(widget.radius),
      border: widget.hasBorder ? Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight) : null,
      boxShadow: widget.elevated
          ? [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.20) : AppColors.slate900.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ]
          : [],
    );

    final content = AnimatedScale(
      scale: widget.onTap != null && _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        margin: widget.margin,
        padding: widget.padding ?? const EdgeInsets.all(AppSizes.cardPadding),
        decoration: decoration,
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.radius),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.radius),
            child: content,
          ),
        ),
      ),
    );
  }
}
