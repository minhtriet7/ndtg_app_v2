import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_card.dart';
import '../../../routes/route_names.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../main/controllers/main_tab_controller.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isAdmin = auth.currentUser?.isAdmin == true;

    final actions = <QuickActionCard>[
      QuickActionCard(
        icon: Icons.document_scanner_rounded,
        title: context.tr('startScan'),
        subtitle: context.tr('multiAgentAnalysis'),
        color: AppColors.primaryTeal,
        onTap: () => context.read<MainTabController>().goScan(),
      ),
      QuickActionCard(
        icon: Icons.history_rounded,
        title: context.tr('history'),
        subtitle: context.tr('previousResults'),
        color: AppColors.secondaryBlue,
        onTap: () => context.read<MainTabController>().goHistory(),
      ),
      QuickActionCard(
        icon: Icons.public_rounded,
        title: context.tr('navigationDirectory'),
        subtitle: context.tr('seaCurrencies'),
        color: AppColors.violet,
        onTap: () => context.read<MainTabController>().goCurrency(),
      ),
      QuickActionCard(
        icon: Icons.currency_exchange_rounded,
        title: context.tr('currency'),
        subtitle: context.tr('convertCurrencies'),
        color: AppColors.info,
        onTap: () => Navigator.of(context).pushNamed(RouteNames.currency),
      ),
      QuickActionCard(
        icon: Icons.credit_card_rounded,
        title: context.tr('payment'),
        subtitle: context.tr('manageTokens'),
        color: AppColors.warning,
        onTap: () => Navigator.of(context).pushNamed(RouteNames.pricing),
      ),
      if (isAdmin)
        QuickActionCard(
          icon: Icons.admin_panel_settings_rounded,
          title: context.tr('adminLite'),
          subtitle: context.tr('systemDashboard'),
          color: AppColors.danger,
          onTap: () =>
              Navigator.of(context).pushNamed(RouteNames.adminDashboard),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('quickActions'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        GridView.builder(
          itemCount: actions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.35, // Refined proportion for bento style
            crossAxisSpacing: AppSizes.md,
            mainAxisSpacing: AppSizes.md,
          ),
          itemBuilder: (context, index) => actions[index],
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
      glowColor: color, // Set glow color in premium style
      padding: const EdgeInsets.all(AppSizes.md),
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: color.withOpacity(0.18)),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
