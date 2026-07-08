import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_card.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('userGuide'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.lg,
          132,
        ),
        children: [
          const _GuideHero(),
          const SizedBox(height: AppSizes.lg),
          _GuideSectionTitle(title: context.tr('recognitionWorkflow')),
          const SizedBox(height: AppSizes.md),
          _GuideStep(
            index: '01',
            icon: Icons.camera_alt_rounded,
            title: context.tr('guideCaptureTitle'),
            description: context.tr('guideCaptureDesc'),
          ),
          const SizedBox(height: AppSizes.md),
          _GuideStep(
            index: '02',
            icon: Icons.document_scanner_rounded,
            title: context.tr('guidePipelineTitle'),
            description: context.tr('guidePipelineDesc'),
          ),
          const SizedBox(height: AppSizes.md),
          _GuideStep(
            index: '03',
            icon: Icons.fact_check_rounded,
            title: context.tr('guideConsensusTitle'),
            description: context.tr('guideConsensusDesc'),
          ),
          const SizedBox(height: AppSizes.xl),
          _GuideSectionTitle(title: context.tr('walletAndTools')),
          const SizedBox(height: AppSizes.md),
          _GuideStep(
            index: '04',
            icon: Icons.public_rounded,
            title: context.tr('guideDirectoryTitle'),
            description: context.tr('guideDirectoryDesc'),
          ),
          const SizedBox(height: AppSizes.md),
          _GuideStep(
            index: '05',
            icon: Icons.currency_exchange_rounded,
            title: context.tr('guideCurrencyTitle'),
            description: context.tr('guideCurrencyDesc'),
          ),
          const SizedBox(height: AppSizes.md),
          _GuideStep(
            index: '06',
            icon: Icons.payments_rounded,
            title: context.tr('guideTopUpTitle'),
            description: context.tr('guideTopUpDesc'),
          ),
          const SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }
}

class _GuideHero extends StatelessWidget {
  const _GuideHero();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hasBorder: false,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          gradient: AppColors.tealGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(0.22),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.menu_book_rounded, color: Colors.white, size: 42),
            const SizedBox(height: AppSizes.md),
            Text(
              context.tr('banknoteAiHandbook'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              context.tr('guideHeroDesc'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideSectionTitle extends StatelessWidget {
  final String title;

  const _GuideSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.4,
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String index;
  final IconData icon;
  final String title;
  final String description;

  const _GuideStep({
    required this.index,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: AppColors.primaryTeal.withOpacity(0.12),
              ),
            ),
            child: Icon(icon, color: AppColors.primaryTeal, size: 26),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  index,
                  style: const TextStyle(
                    color: AppColors.primaryTeal,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
