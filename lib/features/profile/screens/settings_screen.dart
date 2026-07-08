import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_button.dart';
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
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.lg,
          132,
        ),
        children: [
          Text(
            context.tr('preferences'),
            style: TextStyle(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('preferencesDesc'),
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
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
                  subtitle: context.tr('languageDesc'),
                  trailing: _SegmentedLanguageSwitch(
                    currentLocale: langCtrl.currentLocale,
                    onChanged: langCtrl.changeLanguage,
                  ),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  title: context.tr('theme'),
                  subtitle: context.tr(
                    isDark ? 'darkModeActive' : 'lightModeActive',
                  ),
                  trailing: Switch.adaptive(
                    value: isDark,
                    activeColor: AppColors.primaryTeal,
                    onChanged: (_) => themeCtrl.toggleTheme(context),
                  ),
                  onTap: () => themeCtrl.toggleTheme(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          if (kDebugMode) ...[
            Text(
              context.tr('developerSettings'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('developerSettingsDesc'),
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            const _ApiServerSettingsCard(),
            const SizedBox(height: AppSizes.lg),
          ],
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(
                      isDark ? 0.20 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    context.tr('settingsSavedNotice'),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
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

class _ApiServerSettingsCard extends StatefulWidget {
  const _ApiServerSettingsCard();

  @override
  State<_ApiServerSettingsCard> createState() => _ApiServerSettingsCardState();
}

class _ApiServerSettingsCardState extends State<_ApiServerSettingsCard> {
  late final TextEditingController _urlController;
  late String _currentUrl;
  String? _errorKey;
  bool _isTesting = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = AppConfig.baseUrl;
    _urlController = TextEditingController(text: _currentUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _showResult(String key, {bool success = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr(key)),
        backgroundColor: success ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _normalizedInput() {
    final normalized = AppConfig.normalizeApiBaseUrl(_urlController.text);
    setState(() => _errorKey = normalized == null ? 'invalidApiUrl' : null);
    return normalized;
  }

  Future<void> _save() async {
    final normalized = _normalizedInput();
    if (normalized == null) {
      _showResult('invalidApiUrl', success: false);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final savedUrl = await AppConfig.saveCustomUrl(normalized);
      if (!mounted) return;
      setState(() {
        _currentUrl = savedUrl;
        _urlController.text = savedUrl;
      });
      _showResult('apiUrlSaved');
    } catch (_) {
      _showResult('invalidApiUrl', success: false);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _test() async {
    final normalized = _normalizedInput();
    if (normalized == null) {
      _showResult('invalidApiUrl', success: false);
      return;
    }

    setState(() => _isTesting = true);
    final connected = await DioClient().testConnection(normalized);
    if (!mounted) return;
    setState(() => _isTesting = false);
    _showResult(
      connected ? 'connectionSuccessful' : 'cannotConnectServer',
      success: connected,
    );
  }

  Future<void> _reset() async {
    await AppConfig.clearCustomUrl();
    if (!mounted) return;
    setState(() {
      _currentUrl = AppConfig.defaultBaseUrl;
      _urlController.text = _currentUrl;
      _errorKey = null;
    });
    _showResult('defaultUrlRestored');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: const Icon(Icons.dns_rounded, color: AppColors.info),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  context.tr('apiServer'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (AppConfig.hasSavedDevelopmentOverride)
                const Icon(Icons.tune_rounded, color: AppColors.primaryTeal),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          _ApiUrlLine(label: context.tr('currentApiUrl'), value: _currentUrl),
          const SizedBox(height: AppSizes.sm),
          _ApiUrlLine(
            label: context.tr('defaultApiUrl'),
            value: AppConfig.defaultBaseUrl,
          ),
          const SizedBox(height: AppSizes.lg),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: (_) {
              if (_errorKey != null) setState(() => _errorKey = null);
            },
            decoration: InputDecoration(
              labelText: context.tr('apiServer'),
              hintText: AppConfig.defaultDevelopmentBaseUrl,
              errorText: _errorKey == null ? null : context.tr(_errorKey!),
              prefixIcon: const Icon(Icons.link_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            context.tr('apiUrlFormatHint'),
            style: TextStyle(
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _ApiHint(
            icon: Icons.android_rounded,
            title: context.tr('emulatorUrl'),
            value: AppConfig.defaultDevelopmentBaseUrl,
          ),
          const SizedBox(height: AppSizes.sm),
          _ApiHint(
            icon: Icons.phone_android_rounded,
            title: context.tr('physicalDeviceUrl'),
            value: context.tr('useLaptopIpv4'),
          ),
          const SizedBox(height: AppSizes.lg),
          AppButton(
            text: context.tr('saveApiUrl'),
            icon: Icons.save_rounded,
            isLoading: _isSaving,
            onPressed: _isTesting || _isSaving ? null : _save,
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: context.tr('testConnection'),
                  icon: Icons.wifi_tethering_rounded,
                  type: ButtonType.outline,
                  isLoading: _isTesting,
                  onPressed: _isSaving || _isTesting ? null : _test,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: AppButton(
                  text: context.tr('resetDefault'),
                  icon: Icons.restart_alt_rounded,
                  type: ButtonType.ghost,
                  onPressed: _isSaving || _isTesting ? null : _reset,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApiUrlLine extends StatelessWidget {
  final String label;
  final String value;

  const _ApiUrlLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(
              color: AppColors.primaryTeal,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ApiHint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ApiHint({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.bgLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.info, size: 20),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                    fontSize: 11.5,
                    height: 1.3,
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

  const _SegmentedLanguageSwitch({
    required this.currentLocale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.slate100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangOption(
            label: 'EN',
            selected: currentLocale == 'en',
            onTap: () => onChanged('en'),
          ),
          _LangOption(
            label: 'VI',
            selected: currentLocale == 'vi',
            onTap: () => onChanged('vi'),
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: selected ? null : onTap,
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
            color: selected
                ? Colors.white
                : isDark
                ? AppColors.textMutedDark
                : AppColors.textMutedLight,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
