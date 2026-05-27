import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCtrl = context.watch<LanguageController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          Text(
            'Preferences',
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Customize your BanknoteAI experience on this device.',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: 'English first, Vietnamese available',
                  trailingText: langCtrl.currentLocale.toUpperCase(),
                  onTap: () => langCtrl.toggleLanguage(),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Appearance',
                  subtitle: 'Follows your device system theme',
                  trailingText: isDark ? 'DARK' : 'LIGHT',
                  onTap: null,
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.security_rounded,
                  title: 'Security',
                  subtitle: 'Your session token is stored securely',
                  trailingText: 'JWT',
                  onTap: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: AppColors.info),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    'Theme switching is currently controlled by the device system setting. Manual theme selection can be added later through a ThemeController.',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
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
