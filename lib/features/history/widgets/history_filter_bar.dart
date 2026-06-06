import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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
    if (oldWidget.searchQuery != widget.searchQuery && _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                child: const Icon(Icons.tune_rounded, color: AppColors.primaryTeal, size: 20),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  'Refine results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          AppTextField(
            label: 'Search history',
            hint: 'Country, denomination, currency...',
            controller: _searchController,
            prefixIcon: Icons.search_rounded,
            onChanged: widget.onSearchChanged,
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _DropdownShell(
                  label: 'Status',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: widget.statusFilter,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      items: const {
                        'all': 'All',
                        'completed': 'Completed',
                        'needs_review': 'Needs review',
                        'failed': 'Failed',
                      }.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value))).toList(),
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
                  label: 'Currency',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: ['all', ...widget.currencies].contains(widget.currencyFilter) ? widget.currencyFilter : 'all',
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      items: ['all', ...widget.currencies]
                          .map((code) => DropdownMenuItem(value: code, child: Text(code == 'all' ? 'All' : code)))
                          .toList(),
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
                  text: 'Reset',
                  type: AppButtonType.outline,
                  icon: Icons.refresh_rounded,
                  onPressed: widget.onReset,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: AppButton(
                  text: 'Apply',
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
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDark : AppColors.bgLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: child,
        ),
      ],
    );
  }
}
