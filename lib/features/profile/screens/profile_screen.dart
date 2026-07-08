import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../routes/route_names.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../main/controllers/main_tab_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/user_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_tile.dart';
import '../widgets/token_info_card.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController()..fetchProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final auth = context.watch<AuthController>();
    final authUser = auth.currentUser;

    final fallbackUser = UserModel(
      id: authUser?.id ?? '',
      email: authUser?.email ?? '',
      fullName: authUser?.fullName ?? 'BanknoteAI User',
      phone: '',
      avatarUrl: authUser?.avatarUrl ?? '',
      role: authUser?.role ?? 'user',
      provider: authUser?.provider ?? 'email',
      tokenBalance: authUser?.tokenBalance ?? 0,
      totalScans: 0,
      createdAt: '',
      updatedAt: '',
    );

    var user = controller.profile ?? fallbackUser;

    if (authUser != null) {
      final authRole = authUser.role.toLowerCase().trim();
      final profileRole = user.role.toLowerCase().trim();

      if (authRole == 'admin' && profileRole != authRole) {
        user = user.copyWith(role: authUser.role);
      }

      if (user.avatarUrl.isEmpty && authUser.avatarUrl.isNotEmpty) {
        user = user.copyWith(avatarUrl: authUser.avatarUrl);
      }

      if (user.tokenBalance == 0 && authUser.tokenBalance > 0) {
        user = user.copyWith(tokenBalance: authUser.tokenBalance);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('profile')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: controller.fetchProfile,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: controller.fetchProfile,
        child: _buildBody(
          context,
          controller,
          user,
          isAccountActive: authUser?.isActive,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProfileController controller,
    UserModel user, {
    bool? isAccountActive,
  }) {
    if (controller.isLoading && controller.profile == null) {
      return ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          Text(
            context.tr('loadingProfile'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSizes.md),
          const LoadingSkeleton(height: 210, borderRadius: AppSizes.radiusLg),
          const SizedBox(height: AppSizes.lg),
          const LoadingSkeleton(height: 180, borderRadius: AppSizes.radiusLg),
          const SizedBox(height: AppSizes.lg),
          const LoadingSkeleton(height: 260, borderRadius: AppSizes.radiusLg),
        ],
      );
    }

    if (controller.error != null && controller.profile == null) {
      return ErrorState(
        title: context.tr('failedProfile'),
        message: controller.error!,
        onRetry: controller.fetchProfile,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.lg,
        148,
      ),
      children: [
        ProfileHeader(user: user, isAccountActive: isAccountActive),
        const SizedBox(height: AppSizes.lg),
        TokenInfoCard(
          tokenBalance: user.tokenBalance,
          onTopUp: () => Navigator.of(context).pushNamed(RouteNames.pricing),
          onTransactions: () =>
              Navigator.of(context).pushNamed(RouteNames.transactions),
        ),
        if (user.isAdmin) ...[
          const SizedBox(height: AppSizes.lg),
          _AdminAccessCard(
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.adminDashboard),
          ),
        ],
        const SizedBox(height: AppSizes.lg),
        _ProfileMenuSection(
          title: context.tr('accountSection'),
          items: [
            SettingsTile(
              icon: Icons.edit_outlined,
              title: context.tr('editProfile'),
              subtitle: context.tr('editProfileDesc'),
              onTap: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(user: user),
                  ),
                );

                if (changed == true && context.mounted) {
                  await controller.fetchProfile();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        _ProfileMenuSection(
          title: context.tr('recognitionSection'),
          items: [
            SettingsTile(
              icon: Icons.history_rounded,
              title: context.tr('recognitionHistory'),
              subtitle: context.tr('recognitionHistoryDesc'),
              onTap: () => context.read<MainTabController>().goHistory(),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        _ProfileMenuSection(
          title: context.tr('paymentSection'),
          items: [
            SettingsTile(
              icon: Icons.account_balance_wallet_outlined,
              title: context.tr('topUpTokens'),
              subtitle: context.tr('topUpTokensDesc'),
              onTap: () => Navigator.of(context).pushNamed(RouteNames.pricing),
            ),
            SettingsTile(
              icon: Icons.receipt_long_outlined,
              title: context.tr('transactions'),
              subtitle: context.tr('transactionsDesc'),
              onTap: () =>
                  Navigator.of(context).pushNamed(RouteNames.transactions),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        _ProfileMenuSection(
          title: context.tr('settingsSection'),
          items: [
            SettingsTile(
              icon: Icons.settings_outlined,
              title: context.tr('settings'),
              subtitle: context.tr('settingsDesc'),
              onTap: () => Navigator.of(context).pushNamed(RouteNames.settings),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        _ProfileMenuSection(
          title: context.tr('supportSection'),
          items: [
            SettingsTile(
              icon: Icons.help_outline_rounded,
              title: context.tr('userGuide'),
              subtitle: context.tr('userGuideDesc'),
              onTap: () =>
                  Navigator.of(context).pushNamed(RouteNames.userGuide),
            ),
            SettingsTile(
              icon: Icons.feedback_outlined,
              title: context.tr('feedback'),
              subtitle: context.tr('feedbackDesc'),
              onTap: () => Navigator.of(context).pushNamed(RouteNames.feedback),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        _ProfileMenuSection(
          title: context.tr('systemSection'),
          items: [
            SettingsTile(
              icon: Icons.account_tree_outlined,
              title: context.tr('systemArchitecture'),
              subtitle: context.tr('systemArchitectureDesc'),
              onTap: () => Navigator.of(
                context,
              ).pushNamed(RouteNames.systemArchitecture),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.lg),
        Text(
          context.tr('dangerZone'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.danger,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: SettingsTile(
            icon: Icons.logout_rounded,
            title: context.tr('signOut'),
            subtitle: context.tr('signOutDesc'),
            danger: true,
            onTap: () => _confirmLogout(context),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final controller = context.read<ProfileController>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('signOutQuestion')),
        content: Text(context.tr('signOutConfirmDesc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(context.tr('signOut')),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await controller.logout(context);
    }
  }
}

class _AdminAccessCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AdminAccessCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.primaryDarkTeal, AppColors.surfaceSubtleDark]
                : [AppColors.sectionTintLight, AppColors.surfaceSubtleLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isDark
                ? AppColors.violet.withOpacity(0.35)
                : AppColors.warning.withOpacity(0.30),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(isDark ? 0.20 : 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('adminLite'),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('adminManagementDesc'),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}

class _ProfileMenuSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _ProfileMenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSizes.xs),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                items[index],
                if (index < items.length - 1) const _SectionDivider(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
