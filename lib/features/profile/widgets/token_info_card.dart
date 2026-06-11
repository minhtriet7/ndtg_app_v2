import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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
                      'Token Wallet',
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
                      'Multi-agent scan credits',
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
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  'tokens',
                  style: TextStyle(
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
            'Each successful recognition consumes 1 token. Top up when your balance is low.',
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 310;

              final topUp = AppButton(
                text: 'Top Up',
                icon: Icons.add_card_rounded,
                onPressed: onTopUp,
              );

              final transactions = AppButton(
                text: 'Transactions',
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