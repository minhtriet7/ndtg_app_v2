import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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
        title: 'Start Scan',
        subtitle: 'Multi-agent analysis',
        color: AppColors.primaryTeal,
        onTap: () => context.read<MainTabController>().goScan(),
      ),
      QuickActionCard(
        icon: Icons.history_rounded,
        title: 'History',
        subtitle: 'Previous results',
        color: AppColors.info,
        onTap: () => context.read<MainTabController>().goHistory(),
      ),
      QuickActionCard(
        icon: Icons.public_rounded,
        title: 'Directory',
        subtitle: 'SEA currencies',
        color: AppColors.violet,
        onTap: () => context.read<MainTabController>().goCurrency(),
      ),
      QuickActionCard(
        icon: Icons.toll_rounded,
        title: 'Pricing',
        subtitle: 'Manage tokens',
        color: AppColors.warning,
        onTap: () => Navigator.of(context).pushNamed(RouteNames.pricing),
      ),
      if (isAdmin)
        QuickActionCard(
          icon: Icons.admin_panel_settings_rounded,
          title: 'Admin Lite',
          subtitle: 'System dashboard',
          color: AppColors.danger,
          onTap: () => Navigator.of(context).pushNamed(RouteNames.adminDashboard),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
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
            childAspectRatio: 1.22,
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
      padding: const EdgeInsets.all(AppSizes.md),
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(isDark ? 0.14 : 0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: color.withOpacity(0.12)),
                ),
                child: Icon(icon, color: color, size: 22),
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
        ],
      ),
    );
  }
}
