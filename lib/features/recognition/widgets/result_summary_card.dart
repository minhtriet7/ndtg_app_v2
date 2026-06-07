import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../models/banknote_result_model.dart';
import 'consensus_badge.dart';

class ResultSummaryCard extends StatelessWidget {
  final BanknoteResultModel? result;
  final String? title;
  final String? subtitle;
  final String? consensus;
  final int? matched;
  final int? total;
  final String? label;

  const ResultSummaryCard({
    super.key,
    this.result,
    this.title,
    this.subtitle,
    this.consensus,
    this.matched,
    this.total,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final finalResult = result?.finalResult;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayTitle = title ??
        (finalResult == null ? 'Unknown Banknote' : finalResult.displayTitle);

    final displaySubtitle = subtitle ??
        (finalResult == null
            ? 'Recognition result'
            : finalResult.country);

    final displayConsensus = consensus ??
        finalResult?.matchedAgents ??
        (matched != null && total != null ? '$matched/$total agents' : 'N/A');

    final isCompleted = finalResult?.isCompleted == true;
    final statusColor = isCompleted ? AppColors.success : AppColors.warning;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: isCompleted ? AppColors.tealGradient : null,
              color: isCompleted ? null : AppColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(isDark ? 0.10 : 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.priority_high_rounded,
              color: isCompleted ? Colors.white : AppColors.warning,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            displayTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: isCompleted ? AppColors.primaryTeal : AppColors.warning,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            displaySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          ConsensusBadge(consensus: displayConsensus),
          if (finalResult != null && finalResult.decisionReason.isNotEmpty) ...[
            const SizedBox(height: AppSizes.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Text(
                finalResult.decisionReason,
                textAlign: TextAlign.left,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (label != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              label!,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}