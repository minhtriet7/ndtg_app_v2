import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_badge.dart';
import '../models/currency_rate_model.dart';

class CurrencyPickerSheet extends StatefulWidget {
  final List<CurrencyRateModel> currencies;
  final CurrencyRateModel? selectedCurrency;

  const CurrencyPickerSheet({
    super.key,
    required this.currencies,
    this.selectedCurrency,
  });

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _keyword = '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = widget.currencies.where((item) {
      final keyword = _keyword.trim().toLowerCase();

      return keyword.isEmpty ||
          item.targetCurrency.toLowerCase().contains(keyword) ||
          item.currencyName.toLowerCase().contains(keyword) ||
          item.source.toLowerCase().contains(keyword) ||
          item.provider.toLowerCase().contains(keyword);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, controller) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.md,
            AppSizes.lg,
            0,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDark : AppColors.bgLight,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXxl),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.40 : 0.12),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select currency',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  AppBadge(
                    text: '${filtered.length} available',
                    status: BadgeStatus.info,
                    uppercase: false,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a rate maintained by BanknoteAI backend.',
                style: TextStyle(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _keyword = value),
                decoration: InputDecoration(
                  hintText: 'Search currency, source, provider...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _keyword.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: _clearSearch,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                  child: Text(
                    'No currencies found.',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                    : ListView.separated(
                  controller: controller,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isSelected =
                        widget.selectedCurrency?.targetCurrency ==
                            item.targetCurrency;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(item),
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryTeal.withOpacity(
                              isDark ? 0.16 : 0.08,
                            )
                                : (isDark ? AppColors.cardDark : Colors.white),
                            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryTeal
                                  : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                              width: isSelected ? 1.4 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTeal.withOpacity(
                                    isDark ? 0.18 : 0.10,
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(AppSizes.radiusLg),
                                ),
                                child: Text(
                                  item.targetCurrency.isEmpty
                                      ? '-'
                                      : item.targetCurrency.substring(0, 1),
                                  style: const TextStyle(
                                    color: AppColors.primaryTeal,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSizes.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.targetCurrency,
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.currencyName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${item.source} · ${item.provider}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.textMutedDark
                                            : AppColors.textMutedLight,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primaryTeal,
                                )
                              else if (item.isStale)
                                const AppBadge(
                                  text: 'Stale',
                                  status: BadgeStatus.warning,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}