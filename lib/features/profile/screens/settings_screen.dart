import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCtrl = context.watch<LanguageController>();
    final themeCtrl = context.watch<ThemeController>();
    final isDark = themeCtrl.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.lg, AppSizes.lg, 132),
        children: [
          Text(
            context.tr('preferences'),
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('preferencesDesc'),
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          AppCard(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.language_rounded,
                  title: context.tr('language'),
                  subtitle: 'Choose English or Vietnamese',
                  trailing: _SegmentedLanguageSwitch(
                    currentLocale: langCtrl.currentLocale,
                    onChanged: langCtrl.changeLanguage,
                  ),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  title: context.tr('theme'),
                  subtitle: isDark ? 'Dark mode is active' : 'Light mode is active',
                  trailingText: isDark ? 'DARK' : 'LIGHT',
                  onTap: () => themeCtrl.toggleTheme(context),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.security_rounded,
                  title: context.tr('security'),
                  subtitle: context.tr('securityDesc'),
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
                    color: AppColors.primaryTeal.withOpacity(isDark ? 0.20 : 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: AppColors.primaryTeal),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    'Language and theme changes are saved on this device and apply immediately to supported screens.',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
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

class _SegmentedLanguageSwitch extends StatelessWidget {
  final String currentLocale;
  final ValueChanged<String> onChanged;

  const _SegmentedLanguageSwitch({required this.currentLocale, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.slate100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangOption(label: 'EN', selected: currentLocale == 'en', onTap: () => onChanged('en')),
          _LangOption(label: 'VI', selected: currentLocale == 'vi', onTap: () => onChanged('vi')),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.tealGradient : null,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textMutedLight,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
