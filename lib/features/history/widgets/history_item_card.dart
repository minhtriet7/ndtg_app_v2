import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/network_image_view.dart';
import '../../recognition/models/banknote_result_model.dart';
import '../../recognition/screens/result_detail_screen.dart';

class HistoryItemCard extends StatelessWidget {
  final BanknoteResultModel result;

  const HistoryItemCard({super.key, required this.result});

  BadgeStatus _badgeStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'completed' || normalized == 'success' || normalized == 'done') return BadgeStatus.success;
    if (normalized == 'failed' || normalized == 'error') return BadgeStatus.error;
    if (normalized == 'needs_review' || normalized == 'review') return BadgeStatus.warning;
    return BadgeStatus.info;
  }

  String get _title {
    final denomination = result.finalResult.denomination.trim();
    final currency = result.finalResult.currency.trim();
    if (denomination.toLowerCase() == 'unknown' && currency.toLowerCase() == 'unknown') return 'Unknown banknote';
    return [denomination, currency].where((item) => item.isNotEmpty).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final consensusText = result.finalResult.matchedAgents.trim().isNotEmpty
        ? result.finalResult.matchedAgents
        : 'Consensus N/A';

    return AppCard(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultDetailScreen(result: result)));
      },
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            clipBehavior: Clip.antiAlias,
            child: result.imageUrl.isNotEmpty
                ? NetworkImageView(imageUrl: result.imageUrl, borderRadius: AppSizes.radiusLg, fit: BoxFit.cover)
                : Container(
              color: AppColors.primaryTeal.withOpacity(0.08),
              child: const Icon(Icons.account_balance_rounded, color: AppColors.primaryTeal),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    AppBadge(text: result.status.replaceAll('_', ' '), status: _badgeStatus(result.status)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  result.finalResult.country.isEmpty ? 'Country not confirmed' : result.finalResult.country,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    _TinyMetric(label: '', value: consensusText),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        DateFormatter.formatDateTime(result.createdAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyMetric extends StatelessWidget {
  final String label;
  final String value;

  const _TinyMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.success.withOpacity(0.18)),
      ),
      child: Text(
        label.isEmpty ? value : '$label $value',
        style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}
