import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../../routes/route_names.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/user_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_tile.dart';
import '../widgets/token_info_card.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'user_guide_screen.dart';

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

      if ((authRole == 'admin' ||
          authRole == 'superadmin' ||
          authRole == 'owner') &&
          profileRole != authRole) {
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
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.fetchProfile,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryTeal,
        onRefresh: controller.fetchProfile,
        child: _buildBody(context, controller, user),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      ProfileController controller,
      UserModel user,
      ) {
    if (controller.isLoading && controller.profile == null) {
      return ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: const [
          LoadingSkeleton(height: 210, borderRadius: AppSizes.radiusLg),
          SizedBox(height: AppSizes.lg),
          LoadingSkeleton(height: 180, borderRadius: AppSizes.radiusLg),
          SizedBox(height: AppSizes.lg),
          LoadingSkeleton(height: 260, borderRadius: AppSizes.radiusLg),
        ],
      );
    }

    if (controller.error != null && controller.profile == null) {
      return ErrorState(
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
        ProfileHeader(user: user),
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
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.edit_rounded,
                title: 'Edit Profile',
                subtitle: 'Update your name, phone, and avatar URL',
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


              const _SectionDivider(),
              SettingsTile(
                icon: Icons.menu_book_rounded,
                title: 'User Guide',
                subtitle: 'Learn how to scan banknotes accurately',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UserGuideScreen()),
                  );
                },
              ),
              const _SectionDivider(),
              SettingsTile(
                icon: Icons.feedback_rounded,
                title: 'Feedback',
                subtitle: 'Report issues or send suggestions',
                onTap: () => Navigator.of(context).pushNamed(RouteNames.feedback),
              ),
              if (user.isAdmin) ...[
                const _SectionDivider(),
                SettingsTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Admin Lite',
                  subtitle: 'Open management dashboard',
                  iconColor: AppColors.danger,
                  trailingText: 'ADMIN',
                  onTap: () =>
                      Navigator.of(context).pushNamed(RouteNames.adminDashboard),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        AppCard(
          padding: EdgeInsets.zero,
          child: SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            subtitle: 'End the current session on this device',
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
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to sign in again to continue using BanknoteAI.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Sign Out'),
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
                ? [const Color(0xFF312E81), const Color(0xFF0F172A)]
                : [const Color(0xFFFFFBEB), const Color(0xFFFFF7ED)],
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
                    'Admin Lite',
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
                    'Manage payments, feedback, and system health.',
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
              color:
              isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
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