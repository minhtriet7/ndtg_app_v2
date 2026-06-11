import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class CountryFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CountryFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.tealGradient : null,
            color: selected ? null : (isDark ? AppColors.cardDark : Colors.white),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: AppColors.primaryTeal.withOpacity(0.20),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}