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
      avatarUrl: '',
      role: authUser?.role ?? 'user',
      provider: 'email',
      tokenBalance: authUser?.tokenBalance ?? 0,
      totalScans: 0,
      createdAt: '',
      updatedAt: '',
    );

    final user = controller.profile ?? fallbackUser;

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
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        ProfileHeader(user: user),
        const SizedBox(height: AppSizes.lg),
        TokenInfoCard(
          tokenBalance: user.tokenBalance,
          onTopUp: () => Navigator.of(context).pushNamed(RouteNames.pricing),
          onTransactions: () => Navigator.of(context).pushNamed(RouteNames.transactions),
        ),
        const SizedBox(height: AppSizes.lg),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.edit_rounded,
                title: 'Edit Profile',
                subtitle: 'Update your name and public account information',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(user: user),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              SettingsTile(
                icon: Icons.settings_rounded,
                title: 'App Settings',
                subtitle: 'Language, theme and display preferences',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              const Divider(height: 1),
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
              const Divider(height: 1),
              SettingsTile(
                icon: Icons.feedback_rounded,
                title: 'Feedback',
                subtitle: 'Report issues or send suggestions',
                onTap: () => Navigator.of(context).pushNamed(RouteNames.feedback),
              ),
              if (user.isAdmin) ...[
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Admin Lite',
                  subtitle: 'Quick system overview for administrators',
                  iconColor: AppColors.info,
                  onTap: () => Navigator.of(context).pushNamed(RouteNames.adminDashboard),
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
        const SizedBox(height: AppSizes.xxl),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final controller = context.read<ProfileController>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to continue using BanknoteAI.'),
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
