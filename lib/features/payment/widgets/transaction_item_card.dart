import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../models/transaction_model.dart';

class TransactionItemCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionItemCard({super.key, required this.transaction});

  BadgeStatus _badgeStatus() {
    if (transaction.isSuccess) return BadgeStatus.success;
    if (transaction.isFailed) return BadgeStatus.error;
    if (transaction.isPending) return BadgeStatus.warning;
    return BadgeStatus.neutral;
  }

  IconData _icon() {
    if (transaction.isSuccess) return Icons.check_rounded;
    if (transaction.isFailed) return Icons.close_rounded;
    return Icons.schedule_rounded;
  }

  Color _color() {
    if (transaction.isSuccess) return AppColors.success;
    if (transaction.isFailed) return AppColors.danger;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _color().withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: _color().withOpacity(0.12)),
            ),
            child: Icon(_icon(), color: _color()),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.transactionCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  DateFormatter.formatDateTime(transaction.createdAt),
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Text(
                  '+${MoneyFormatter.formatToken(transaction.tokensAdded)} tokens • ${transaction.gateway.toUpperCase()}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primaryTeal),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(MoneyFormatter.formatVnd(transaction.amount), style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              const SizedBox(height: 8),
              AppBadge(text: transaction.status, status: _badgeStatus()),
            ],
          ),
        ],
      ),
    );
  }
}
