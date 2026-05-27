import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../main/controllers/main_tab_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_scan_card.dart';
import '../widgets/token_balance_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _requestedInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_requestedInitialLoad) return;
    _requestedInitialLoad = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeController>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryTeal,
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.md,
                    AppSizes.lg,
                    AppSizes.sm,
                  ),
                  child: _HomeHeader(isDark: isDark),
                ),
              ),
              if (controller.error != null && !controller.hasLoadedOnce)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorState(
                    message: controller.error!,
                    onRetry: controller.refresh,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.lg,
                      AppSizes.md,
                      AppSizes.lg,
                      110,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.isLoading && controller.userInfo == null)
                          const LoadingSkeleton(height: 260, borderRadius: AppSizes.radiusXl)
                        else
                          const TokenBalanceCard(),
                        const SizedBox(height: AppSizes.xl),
                        const QuickActionGrid(),
                        const SizedBox(height: AppSizes.xl),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Recent Scans',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.read<MainTabController>().goHistory(),
                              child: const Text(
                                'View all',
                                style: TextStyle(
                                  color: AppColors.primaryTeal,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm),
                        if (controller.isLoading && controller.recentScans.isEmpty)
                          const LoadingSkeletonList(itemCount: 3, itemHeight: 86)
                        else
                          const RecentScansList(),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final bool isDark;

  const _HomeHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeController>();
    final user = home.userInfo;
    final name = user?.fullName.trim().isNotEmpty == true ? user!.fullName : 'there';

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_none_rounded,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
