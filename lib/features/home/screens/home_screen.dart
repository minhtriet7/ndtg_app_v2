import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/theme_controller.dart';
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

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryTeal,
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.md,
                    AppSizes.lg,
                    AppSizes.sm,
                  ),
                  child: _HomeHeader(),
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
                      132,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.isLoading && controller.userInfo == null)
                          const LoadingSkeleton(
                            height: 260,
                            borderRadius: AppSizes.radiusXl,
                          )
                        else
                          const TokenBalanceCard(),
                        const SizedBox(height: AppSizes.xl),
                        const QuickActionGrid(),
                        const SizedBox(height: AppSizes.xl),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.tr('recentScans'),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.4,
                                    ),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.read<MainTabController>().goHistory(),
                              child: Text(context.tr('viewAll')),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm),
                        if (controller.isLoading &&
                            controller.recentScans.isEmpty)
                          const LoadingSkeletonList(
                            itemCount: 3,
                            itemHeight: 86,
                          )
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
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final home = context.watch<HomeController>();
    final user = home.userInfo;
    final name = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName
        : context.tr('defaultUserName');

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withOpacity(0.22),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_outlined,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('workspaceTitle'),
                style: TextStyle(
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${context.tr('welcomeBack')}, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        const _LanguagePill(),
        const SizedBox(width: AppSizes.sm),
        const _ThemePill(),
      ],
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill();

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = language.currentLocale.toUpperCase();

    return InkWell(
      onTap: language.toggleLanguage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label == 'EN' ? 'VI' : 'EN',
              style: TextStyle(
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePill extends StatelessWidget {
  const _ThemePill();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDarkMode(context);

    return InkWell(
      onTap: () => theme.toggleTheme(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: 18,
          color: isDark ? AppColors.warning : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
