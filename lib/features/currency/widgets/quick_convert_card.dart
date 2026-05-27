import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../models/currency_rate_model.dart';

class QuickConvertCard extends StatelessWidget {
  final CurrencyRateModel rate;
  final double amount;

  const QuickConvertCard({super.key, required this.rate, this.amount = 100});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vnd = amount * rate.effectiveRateToVnd;
    return AppCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(MoneyFormatter.formatCurrencyAmount(amount, rate.targetCurrency), style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSizes.sm),
          Text(MoneyFormatter.formatVnd(vnd), style: const TextStyle(color: AppColors.primaryTeal, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(rate.currencyName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight, fontSize: 12)),
        ],
      ),
    );
  }
}
