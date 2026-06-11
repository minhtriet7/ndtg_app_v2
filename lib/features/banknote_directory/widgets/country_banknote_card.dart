import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../models/supported_country_model.dart';

class CountryBanknoteCard extends StatelessWidget {
  final SupportedCountryModel country;
  final VoidCallback onTap;

  const CountryBanknoteCard({
    super.key,
    required this.country,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstImage = country.banknotes.firstWhere(
          (item) => item.hasAnyImage,
      orElse: () => country.banknotes.first,
    );

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.tealGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryTeal.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              country.countryCode,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country.country,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${country.noteCount} supported notes · ${country.currencyCode}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _previewNotes(country),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              firstImage.hasAnyImage ? Icons.image_search_rounded : Icons.chevron_right_rounded,
              color: AppColors.primaryTeal,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _previewNotes(SupportedCountryModel country) {
    final notes = country.banknotes.take(4).map((e) => e.displayName).join(' · ');
    if (country.banknotes.length <= 4) return notes;
    return '$notes · +${country.banknotes.length - 4} more';
  }
}