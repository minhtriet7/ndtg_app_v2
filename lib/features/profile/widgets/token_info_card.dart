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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 24),
              SizedBox(width: AppSizes.sm),
              Text(
                'Token Wallet',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MoneyFormatter.formatToken(tokenBalance),
                style: const TextStyle(
                  color: AppColors.primaryTeal,
                  fontSize: 42,
                  height: 1,
                  fontWeight: FontWeight.w900,
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Each successful AI recognition consumes 1 token.',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Top Up',
                  icon: Icons.add_card_rounded,
                  onPressed: onTopUp,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: AppButton(
                  text: 'Transactions',
                  type: ButtonType.outline,
                  icon: Icons.receipt_long_rounded,
                  onPressed: onTransactions,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
