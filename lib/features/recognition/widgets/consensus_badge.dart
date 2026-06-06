import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_badge.dart';

class ConsensusBadge extends StatelessWidget {
  final String consensus;
  final double? confidence;

  const ConsensusBadge({super.key, required this.consensus, this.confidence});

  @override
  Widget build(BuildContext context) {
    final status = _resolveStatus();
    final color = _foreground(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        consensus,
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12),
      ),
    );
  }

  BadgeStatus _resolveStatus() {
    final normalized = consensus.toLowerCase();
    if (normalized.contains('3/3') || normalized.contains('matched') || (confidence != null && confidence! >= 0.75)) return BadgeStatus.success;
    if (normalized.contains('2/3') || normalized.contains('review') || (confidence != null && confidence! >= 0.45)) return BadgeStatus.warning;
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
}
