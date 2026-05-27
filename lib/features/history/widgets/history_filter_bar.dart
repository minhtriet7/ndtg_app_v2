import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: [
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
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(child: AppButton(text: 'Reset', type: AppButtonType.outline, icon: Icons.refresh_rounded, onPressed: widget.onReset)),
              const SizedBox(width: AppSizes.md),
              Expanded(child: AppButton(text: 'Apply', icon: Icons.filter_alt_rounded, onPressed: widget.onApply)),
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
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDark : AppColors.bgLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: child,
        ),
      ],
    );
  }
}
