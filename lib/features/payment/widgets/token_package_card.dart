import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../models/token_package_model.dart';

class TokenPackageCard extends StatelessWidget {
  final TokenPackageModel package;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onBuy;

  const TokenPackageCard({
    super.key,
    required this.package,
    required this.onBuy,
    this.isLoading = false,
    this.isEnabled = true,
  });

  String _getLocalizedName(BuildContext context, String id, String fallback) {
    if (id == 'starter') return context.tr('basicPackage');
    if (id == 'pro') return context.tr('popularPackage');
    if (id == 'enterprise') return context.tr('advancedPackage');
    return fallback;
  }

  String _getLocalizedDesc(BuildContext context, String id, String fallback) {
    if (id == 'starter') return context.tr('bestOccasional');
    if (id == 'pro') return context.tr('bestRegular');
    if (id == 'enterprise') return context.tr('bestHighVolume');
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      hasBorder: !package.isPopular,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(
            color: package.isPopular
                ? AppColors.primaryTeal.withOpacity(0.55)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: package.isPopular ? 1.5 : 1,
          ),
          boxShadow: package.isPopular
              ? [
                  BoxShadow(
                    color: AppColors.primaryTeal.withOpacity(
                      isDark ? 0.10 : 0.16,
                    ),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.tealGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLocalizedName(context, package.id, package.name),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _getLocalizedDesc(context, package.id, package.description),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (package.isPopular)
                  AppBadge(
                    text: context.tr('recommended'),
                    status: BadgeStatus.success,
                    uppercase: false,
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  MoneyFormatter.formatToken(package.totalTokens),
                  style: const TextStyle(
                    fontSize: 36,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryTeal,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    context.tr('recognitionCredits').toLowerCase(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
            if (package.bonus > 0) ...[
              const SizedBox(height: AppSizes.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.18),
                  ),
                ),
                child: Text(
                  '${MoneyFormatter.formatToken(package.tokens)} ${context.tr('base')} + ${MoneyFormatter.formatToken(package.bonus)} ${context.tr('bonus')} ${context.tr('recognitionCredits').toLowerCase()}',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    MoneyFormatter.formatVnd(package.price),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                SizedBox(
                  width: 136,
                  child: AppButton(
                    text: context.tr('buyNow'),
                    trailingIcon: Icons.arrow_forward_rounded,
                    isLoading: isLoading,
                    onPressed: isEnabled ? onBuy : null,
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
