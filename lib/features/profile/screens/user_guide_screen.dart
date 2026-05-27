import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Guide')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: const [
          _GuideHero(),
          SizedBox(height: AppSizes.lg),
          _GuideStep(
            index: '01',
            icon: Icons.camera_alt_rounded,
            title: 'Capture a clear banknote image',
            description:
            'Place the banknote on a flat surface, keep all corners visible, avoid shadows, and make sure the denomination area is not covered.',
          ),
          SizedBox(height: AppSizes.md),
          _GuideStep(
            index: '02',
            icon: Icons.document_scanner_rounded,
            title: 'Run the multi-agent AI pipeline',
            description:
            'Each analysis can consume 1 token. BanknoteAI uses computer vision, language reasoning, visual search and an aggregator to reach a final result.',
          ),
          SizedBox(height: AppSizes.md),
          _GuideStep(
            index: '03',
            icon: Icons.fact_check_rounded,
            title: 'Review confidence and consensus',
            description:
            'Check the final denomination, country, currency, confidence score and agent consensus. If the result is uncertain, scan again with better lighting.',
          ),
          SizedBox(height: AppSizes.md),
          _GuideStep(
            index: '04',
            icon: Icons.currency_exchange_rounded,
            title: 'Convert currencies using VND rates',
            description:
            'The converter uses rates stored by the backend. Market sync is handled on the server, so the mobile app never stores provider API keys.',
          ),
          SizedBox(height: AppSizes.md),
          _GuideStep(
            index: '05',
            icon: Icons.payments_rounded,
            title: 'Top up tokens securely',
            description:
            'Choose a token package, scan the VietQR/SePay code, and wait for the backend to confirm payment before tokens are added to your account.',
          ),
          SizedBox(height: AppSizes.xxl),
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
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.menu_book_rounded, color: Colors.white, size: 42),
            SizedBox(height: AppSizes.md),
            Text(
              'BanknoteAI Handbook',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              'Learn how to get accurate recognition results and manage tokens effectively.',
              style: TextStyle(
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
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, color: AppColors.primaryTeal, size: 26),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$index · $title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
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
