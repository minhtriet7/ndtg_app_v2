import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../routes/route_names.dart';
import '../../main/controllers/main_tab_controller.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.22,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSizes.md,
          mainAxisSpacing: AppSizes.md,
          children: [
            QuickActionCard(
              icon: Icons.document_scanner_rounded,
              title: 'Scan Banknote',
              subtitle: 'Run multi-agent AI',
              color: AppColors.primaryTeal,
              onTap: () => context.read<MainTabController>().goScan(),
            ),
            QuickActionCard(
              icon: Icons.currency_exchange_rounded,
              title: 'Currency Converter',
              subtitle: 'Live VND rates',
              color: AppColors.info,
              onTap: () => context.read<MainTabController>().goCurrency(),
            ),
            QuickActionCard(
              icon: Icons.wallet_rounded,
              title: 'Top Up Tokens',
              subtitle: 'VietQR / SePay',
              color: AppColors.warning,
              onTap: () => Navigator.of(context).pushNamed(RouteNames.pricing),
            ),
            QuickActionCard(
              icon: Icons.feedback_rounded,
              title: 'Send Feedback',
              subtitle: 'Report an issue',
              color: AppColors.success,
              onTap: () => Navigator.of(context).pushNamed(RouteNames.feedbackForm),
            ),
          ],
        ),
      ],
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
