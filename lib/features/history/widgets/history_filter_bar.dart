import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';

class HistoryFilterBar extends StatefulWidget {
  final String searchQuery;
  final String statusFilter;
  final String currencyFilter;
  final List<String> currencies;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onCurrencyChanged;
  final VoidCallback onApply;
  final VoidCallback onReset;

  const HistoryFilterBar({
    super.key,
    required this.searchQuery,
    required this.statusFilter,
    required this.currencyFilter,
    required this.currencies,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onCurrencyChanged,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<HistoryFilterBar> createState() => _HistoryFilterBarState();
}

class _HistoryFilterBarState extends State<HistoryFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant HistoryFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reset() {
    _searchController.clear();
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSizes.lg),
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  context.tr('refineResults'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          AppTextField(
            label: context.tr('searchHistory'),
            hint: context.tr('searchHistoryHint'),
            controller: _searchController,
            prefixIcon: Icons.search_rounded,
            onChanged: widget.onSearchChanged,
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _DropdownShell(
                  label: context.tr('statusLabel'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _safeStatusValue(widget.statusFilter),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      items: ['all', 'completed', 'needs_review', 'failed'].map(
                        (status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status == 'all'
                                  ? context.tr('all')
                                  : context.trStatus(status),
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) widget.onStatusChanged(value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _DropdownShell(
                  label: context.tr('currencyLabel'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _safeCurrencyValue(
                        widget.currencyFilter,
                        widget.currencies,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      items: ['all', ...widget.currencies].map((code) {
                        return DropdownMenuItem(
                          value: code,
                          child: Text(code == 'all' ? context.tr('all') : code),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) widget.onCurrencyChanged(value);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: context.tr('reset'),
                  type: AppButtonType.outline,
                  icon: Icons.refresh_rounded,
                  onPressed: _reset,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: AppButton(
                  text: context.tr('apply'),
                  icon: Icons.check_rounded,
                  onPressed: widget.onApply,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _safeStatusValue(String value) {
    const allowed = ['all', 'completed', 'needs_review', 'failed'];
    return allowed.contains(value) ? value : 'all';
  }

  String _safeCurrencyValue(String value, List<String> currencies) {
    final allowed = ['all', ...currencies];
    return allowed.contains(value) ? value : 'all';
  }
}

class _DropdownShell extends StatelessWidget {
  final String label;
  final Widget child;

  const _DropdownShell({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDark : AppColors.bgLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}
