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
  String _keyword = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = widget.currencies.where((item) {
      final keyword = _keyword.toLowerCase();
      return keyword.isEmpty || item.targetCurrency.toLowerCase().contains(keyword) || item.currencyName.toLowerCase().contains(keyword);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Container(
          padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.md, AppSizes.lg, 0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDark : AppColors.bgLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
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
              Text('Select currency', style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: AppSizes.md),
              TextField(
                onChanged: (value) => setState(() => _keyword = value),
                decoration: const InputDecoration(hintText: 'Search currency...', prefixIcon: Icon(Icons.search_rounded)),
              ),
              const SizedBox(height: AppSizes.md),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isSelected = widget.selectedCurrency?.targetCurrency == item.targetCurrency;
                    return ListTile(
                      onTap: () => Navigator.of(context).pop(item),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        side: BorderSide(color: isSelected ? AppColors.primaryTeal : (isDark ? AppColors.borderDark : AppColors.borderLight)),
                      ),
                      tileColor: isDark ? AppColors.cardDark : Colors.white,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryTeal.withOpacity(0.12),
                        child: Text(item.targetCurrency.substring(0, 1), style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w900)),
                      ),
                      title: Text(item.targetCurrency, style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text(item.currencyName),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryTeal)
                          : item.isStale
                          ? const AppBadge(text: 'Stale', status: BadgeStatus.warning)
                          : null,
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
