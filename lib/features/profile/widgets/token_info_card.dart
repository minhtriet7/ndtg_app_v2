import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

class TokenInfoCard extends StatelessWidget {
  final int tokenBalance;
  final VoidCallback? onTopUp;
  final VoidCallback? onTransactions;

  const TokenInfoCard({
    super.key,
    required this.tokenBalance,
    this.onTopUp,
    this.onTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLowBalance = tokenBalance <= 2;

    return AppCard(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.tealGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withOpacity(0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.generating_tokens_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('tokenWallet'),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.tr('multiAgentScanCredits'),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    MoneyFormatter.formatToken(tokenBalance),
                    style: const TextStyle(
                      color: AppColors.primaryTeal,
                      fontSize: 44,
                      height: 0.95,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  context.tr('tokens').toLowerCase(),
                  style: const TextStyle(
                    color: AppColors.primaryTeal,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            context.tr('tokenConsumptionDesc'),
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isLowBalance) ...[
            const SizedBox(height: AppSizes.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.warning.withOpacity(0.28)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 21,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('lowTokenTitle'),
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          context.tr('lowTokenDesc'),
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            height: 1.35,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 310;

              final topUp = AppButton(
                text: context.tr('topUp'),
                icon: Icons.add_card_rounded,
                onPressed: onTopUp,
              );

              final transactions = AppButton(
                text: context.tr('transactions'),
                type: AppButtonType.outline,
                icon: Icons.receipt_long_rounded,
                onPressed: onTransactions,
              );

              if (compact) {
                return Column(
                  children: [
                    topUp,
                    const SizedBox(height: AppSizes.sm),
                    transactions,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: topUp),
                  const SizedBox(width: AppSizes.md),
                  Expanded(child: transactions),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
