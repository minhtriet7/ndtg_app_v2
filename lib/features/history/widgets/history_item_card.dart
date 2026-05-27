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

  const HistoryItemCard({
    super.key,
    required this.result,
  });

  BadgeStatus _badgeStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'completed' || normalized == 'success' || normalized == 'done') {
      return BadgeStatus.success;
    }
    if (normalized == 'failed' || normalized == 'error') return BadgeStatus.error;
    if (normalized == 'needs_review' || normalized == 'review') return BadgeStatus.warning;
    return BadgeStatus.info;
  }

  String get _title {
    final denomination = result.finalResult.denomination;
    final currency = result.finalResult.currency;
    if (denomination.toLowerCase() == 'unknown' && currency.toLowerCase() == 'unknown') {
      return 'Unknown banknote';
    }
    return '$denomination $currency';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ResultDetailScreen(result: result)),
        );
      },
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: result.imageUrl.isNotEmpty
                ? NetworkImageView(imageUrl: result.imageUrl, borderRadius: AppSizes.radiusMd)
                : Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(Icons.image_not_supported_outlined),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.finalResult.country,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormatter.formatDateTime(result.createdAt),
                  style: TextStyle(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppBadge(text: result.status.replaceAll('_', ' '), status: _badgeStatus(result.status)),
              const SizedBox(height: AppSizes.sm),
              Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            ],
          ),
        ],
      ),
    );
  }
}
