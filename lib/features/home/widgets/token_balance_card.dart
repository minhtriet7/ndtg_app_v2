import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../routes/route_names.dart';
import '../../main/controllers/main_tab_controller.dart';
import '../controllers/home_controller.dart';

class TokenBalanceCard extends StatelessWidget {
  const TokenBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final balance =
        controller.userInfo?.tokenBalance ?? controller.stats.tokenBalance;
    final totalScans = controller.stats.totalScans;
    final successRate = controller.stats.successRate;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withOpacity(0.85)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
        border: Border.all(
          color: isDark
              ? AppColors.violet.withOpacity(0.25)
              : AppColors.primaryTeal.withOpacity(0.15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.violet.withOpacity(0.06)
                : AppColors.primaryTeal.withOpacity(0.03),
            blurRadius: 40,
            spreadRadius: -2,
            offset: const Offset(-8, -8),
          ),
          BoxShadow(
            color: isDark
                ? AppColors.primaryTeal.withOpacity(0.10)
                : AppColors.primaryTeal.withOpacity(0.05),
            blurRadius: 40,
            spreadRadius: -2,
            offset: const Offset(8, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('tokenBalance'),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.violet.withOpacity(0.12)
                      : AppColors.primaryTeal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isDark
                        ? AppColors.violet.withOpacity(0.20)
                        : AppColors.primaryTeal.withOpacity(0.16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.violet,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      context.tr('multiAgentAi'),
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.primaryTeal,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MoneyFormatter.formatToken(balance),
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  context.tr('tokens').toLowerCase(),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              _MiniMetric(
                label: context.tr('scansLabel'),
                value: MoneyFormatter.formatToken(totalScans),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _MiniMetric(
                label: context.tr('successLabel'),
                value: '${successRate.toStringAsFixed(0)}%',
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: _GlassButton(
                  text: context.tr('topUp'),
                  foreground: Colors.white,
                  background: AppColors.primaryTeal,
                  gradient: AppColors.tealGradient,
                  onTap: () =>
                      Navigator.of(context).pushNamed(RouteNames.pricing),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _GlassButton(
                  text: context.tr('history'),
                  foreground: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  background: isDark
                      ? Colors.white.withOpacity(0.06)
                      : AppColors.slate100,
                  borderColor: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                  onTap: () => context.read<MainTabController>().goHistory(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final String text;
  final Color foreground;
  final Color background;
  final Gradient? gradient;
  final Color? borderColor;
  final VoidCallback onTap;

  const _GlassButton({
    required this.text,
    required this.foreground,
    required this.background,
    this.gradient,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: gradient != null ? null : background,
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!, width: 0.8),
            boxShadow: gradient != null
                ? [
                    BoxShadow(
                      color: AppColors.primaryTeal.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withOpacity(0.4)
              : AppColors.slate50,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
