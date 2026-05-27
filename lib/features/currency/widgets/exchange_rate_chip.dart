import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/money_formatter.dart';
import '../models/currency_rate_model.dart';

class ExchangeRateChip extends StatelessWidget {
  final CurrencyRateModel rate;

  const ExchangeRateChip({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('1 ${rate.targetCurrency}', style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.w900)),
          const SizedBox(width: 6),
          Text('= ${MoneyFormatter.formatVnd(rate.effectiveRateToVnd)}', style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
