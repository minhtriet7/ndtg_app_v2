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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finalResult = result?.finalResult;
    final displayTitle = title ?? (finalResult == null ? 'Unknown Banknote' : '${finalResult.denomination} ${finalResult.currency}');
    final displaySubtitle = subtitle ?? finalResult?.country ?? 'Recognition result';
    final displayConsensus = consensus ?? finalResult?.matchedAgents ?? (matched != null && total != null ? '$matched/$total Matched' : 'N/A');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: AppColors.tealGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: AppColors.primaryTeal.withOpacity(0.22), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            displayTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primaryTeal, letterSpacing: -0.8),
          ),
          const SizedBox(height: 6),
          Text(
            displaySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSizes.md),
          ConsensusBadge(consensus: displayConsensus),
          if (label != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(label!, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
          ],
        ],
      ),
    );
  }
}
