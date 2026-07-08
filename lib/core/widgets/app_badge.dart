import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

enum BadgeStatus { success, warning, error, danger, info, neutral, pending }

class AppBadge extends StatelessWidget {
  final String text;
  final BadgeStatus status;
  final IconData? icon;
  final bool uppercase;

  const AppBadge({
    super.key,
    required this.text,
    this.status = BadgeStatus.neutral,
    this.icon,
    this.uppercase = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            uppercase ? text.toUpperCase() : text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(BuildContext context, BadgeStatus status) {
    switch (status) {
      case BadgeStatus.success:
        return AppColors.success;
      case BadgeStatus.warning:
      case BadgeStatus.pending:
        return AppColors.warning;
      case BadgeStatus.error:
      case BadgeStatus.danger:
        return AppColors.danger;
      case BadgeStatus.info:
        return AppColors.info;
      case BadgeStatus.neutral:
      default:
        return AppColors.textMuted(context);
    }
  }
}
