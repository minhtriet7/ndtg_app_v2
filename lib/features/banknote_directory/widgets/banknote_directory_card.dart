import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/network_image_view.dart';
import '../models/banknote_directory_model.dart';

class BanknoteDirectoryCard extends StatelessWidget {
  final BanknoteDirectoryModel banknote;
  final VoidCallback? onTap;

  const BanknoteDirectoryCard({super.key, required this.banknote, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 158,
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle(context),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusXl),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: banknote.frontImageUrl.isEmpty
                      ? Icon(
                          Icons.account_balance_wallet_outlined,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                          size: 58,
                        )
                      : NetworkImageView(
                          imageUrl: banknote.frontImageUrl,
                          height: 132,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          borderRadius: AppSizes.radiusMd,
                        ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: _ImageBadge(text: banknote.currencyCode),
                ),
                if (banknote.backImageUrl.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: _ImageBadge(text: context.tr('frontAndBack')),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banknote.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  banknote.country,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: _MetaPill(
                        label: context.tr('material'),
                        value: banknote.material,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: _MetaPill(
                        label: context.tr('series'),
                        value: banknote.seriesYear,
                      ),
                    ),
                  ],
                ),
                if (banknote.features.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.md),
                  Text(
                    banknote.features.first,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (onTap != null) ...[
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Text(
                        context.tr('viewDetails'),
                        style: const TextStyle(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primaryTeal,
                        size: 15,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  final String text;

  const _ImageBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withOpacity(0.92)
            : Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryTeal,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetaPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle(context),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.isEmpty ? context.tr('unknown') : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
