import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_badge.dart';

class ConsensusBadge extends StatelessWidget {
  final String consensus;
  final double? confidence;

  const ConsensusBadge({
    super.key,
    required this.consensus,
    this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final status = _resolveStatus();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: _background(status),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: _foreground(status).withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(status), color: _foreground(status), size: 16),
          const SizedBox(width: AppSizes.xs),
          Text(
            consensus,
            style: TextStyle(
              color: _foreground(status),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  BadgeStatus _resolveStatus() {
    final normalized = consensus.toLowerCase();

    if (normalized.contains('3/3') ||
        normalized.contains('matched') ||
        (confidence != null && confidence! >= 0.75)) {
      return BadgeStatus.success;
    }

    if (normalized.contains('2/3') ||
        normalized.contains('review') ||
        (confidence != null && confidence! >= 0.45)) {
      return BadgeStatus.warning;
    }

    return BadgeStatus.error;
  }

  Color _foreground(BadgeStatus status) {
    switch (status) {
      case BadgeStatus.success:
        return AppColors.success;
      case BadgeStatus.warning:
      case BadgeStatus.pending:
        return AppColors.warning;
      case BadgeStatus.error:
        return AppColors.danger;
      case BadgeStatus.info:
        return AppColors.info;
      case BadgeStatus.neutral:
      default:
        return AppColors.textSecondaryLight;
    }
  }

  Color _background(BadgeStatus status) {
    return _foreground(status).withOpacity(0.10);
  }

  IconData _icon(BadgeStatus status) {
    switch (status) {
      case BadgeStatus.success:
        return Icons.verified_rounded;
      case BadgeStatus.warning:
      case BadgeStatus.pending:
        return Icons.warning_amber_rounded;
      case BadgeStatus.error:
        return Icons.error_outline_rounded;
      case BadgeStatus.info:
        return Icons.info_outline_rounded;
      case BadgeStatus.neutral:
      default:
        return Icons.circle_outlined;
    }
  }
}
